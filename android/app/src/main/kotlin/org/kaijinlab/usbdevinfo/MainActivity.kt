package org.kaijinlab.usbdevinfo

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
  private var bridge: UsbBridge? = null
  private var pendingIntent: Intent? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    pendingIntent = intent
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    bridge = UsbBridge(this, flutterEngine.dartExecutor.binaryMessenger).also {
      it.start()
      it.handleIntent(pendingIntent ?: intent)
    }
    pendingIntent = null
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    if (bridge != null) {
      bridge?.handleIntent(intent)
    } else {
      pendingIntent = intent
    }
  }

  override fun onDestroy() {
    bridge?.stop()
    bridge = null
    super.onDestroy()
  }
}
