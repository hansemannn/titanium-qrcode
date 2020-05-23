package ti.qrcode

import android.app.Activity
import android.content.Intent
import com.google.zxing.BarcodeFormat
import com.google.zxing.MultiFormatWriter
import com.google.zxing.WriterException
import com.journeyapps.barcodescanner.BarcodeEncoder
import org.appcelerator.kroll.KrollDict
import org.appcelerator.kroll.KrollFunction
import org.appcelerator.kroll.KrollModule
import org.appcelerator.kroll.annotations.Kroll.method
import org.appcelerator.kroll.annotations.Kroll.module
import org.appcelerator.titanium.TiApplication
import org.appcelerator.titanium.TiBlob
import org.appcelerator.titanium.util.TiActivityResultHandler
import org.appcelerator.titanium.util.TiActivitySupport

@module(name = "TitaniumQrcode", id = "ti.qrcode")
class TitaniumQrcodeModule : KrollModule(), TiActivityResultHandler {
    private var _currentScanCallback: KrollFunction? = null
    private var _requestCode = 0

    @method
    fun fromString(text: String?): TiBlob? {
        val multiFormatWriter = MultiFormatWriter()
        return try {
            val bitMatrix = multiFormatWriter.encode(text, BarcodeFormat.QR_CODE, 450, 450)
            val barcodeEncoder = BarcodeEncoder()
            val bitmap = barcodeEncoder.createBitmap(bitMatrix)

            TiBlob.blobFromImage(bitmap)
        } catch (e: WriterException) {
            e.printStackTrace()
            
            null
        }
    }

    @method
    fun scan(callback: KrollFunction?) {
        _currentScanCallback = callback

        val activity = TiApplication.getInstance().currentActivity
        val support = activity as TiActivitySupport
        _requestCode = support.uniqueResultCode

        val scanIntent = Intent(activity, QRCodeScannerActivity::class.java)
        support.launchActivityForResult(scanIntent, _requestCode, this)
    }

    override fun onResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode != Activity.RESULT_OK || data == null || _currentScanCallback == null) {
            return
        }

        data.getStringExtra("text")?.let { text ->
            val event = KrollDict()

            event["text"] = text
            event["success"] = true

            this._currentScanCallback?.let { it.callAsync(getKrollObject(), event) }
        }
    }

    override fun onError(activity: Activity, i: Int, e: Exception) {
        val event = KrollDict()
        event["success"] = false

        this._currentScanCallback?.let { it.callAsync(getKrollObject(), event) }
    }
}