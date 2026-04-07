package org.kaijinlab.usbdevinfo

import android.content.Intent
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
  private var bridge: UsbBridge? = null
  private var pendingIntent: Intent? = null
  private var activeRuntimePermission: String? = null
  private lateinit var runtimePermissionLauncher: ActivityResultLauncher<String>

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    runtimePermissionLauncher =
      registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        val permission = activeRuntimePermission
        activeRuntimePermission = null
        if (permission != null) {
          bridge?.onRuntimePermissionResult(permission, granted)
        }
      }
    pendingIntent = intent
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    bridge = UsbBridge(
      activity = this,
      messenger = flutterEngine.dartExecutor.binaryMessenger,
      requestRuntimePermission = { permission ->
        activeRuntimePermission = permission
        runtimePermissionLauncher.launch(permission)
      }
    ).also {
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
