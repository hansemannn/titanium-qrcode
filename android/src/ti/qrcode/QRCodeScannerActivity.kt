package ti.qrcode

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.google.zxing.Result
import me.dm7.barcodescanner.zxing.ZXingScannerView

class QRCodeScannerActivity : Activity(), ZXingScannerView.ResultHandler {

    private var scannerView: ZXingScannerView? = null

    public override fun onCreate(state: Bundle?) {
        super.onCreate(state)

        scannerView = ZXingScannerView(this)
        setContentView(scannerView)
    }

    public override fun onResume() {
        super.onResume()

        scannerView?.setResultHandler(this)
        scannerView?.startCamera()
    }

    public override fun onPause() {
        super.onPause()

        scannerView?.stopCamera() // Stop camera on pause
    }

    override fun handleResult(rawResult: Result) {
        val resultIntent = Intent()

        resultIntent.putExtra("text", rawResult.text)
        setResult(RESULT_OK, resultIntent)
        finish()
    }
}