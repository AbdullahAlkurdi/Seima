package com.example.seima

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val WIDGET_CHANNEL = "com.example.seima/widget"
        private const val SHARING_CHANNEL = "com.seima/sharing"
        var pendingAction: String? = null
        var pendingShareContent: String? = null
        var pendingShareSource: String? = null
        private var widgetChannel: MethodChannel? = null
        private var sharingChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingAction" -> {
                        val action = pendingAction
                        pendingAction = null
                        result.success(action)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        sharingChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARING_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingShare" -> {
                        val content = pendingShareContent
                        val source = pendingShareSource
                        pendingShareContent = null
                        pendingShareSource = null
                        if (content != null && source != null) {
                            result.success("$content|||$source")
                        } else {
                            result.success(content)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
        pendingAction = intent?.getStringExtra(SeimaWidgetProvider.EXTRA_WIDGET_ACTION)
        handleShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val action = intent.getStringExtra(SeimaWidgetProvider.EXTRA_WIDGET_ACTION)
        if (action != null) {
            pendingAction = action
            widgetChannel?.invokeMethod("onPendingAction", action)
        }
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SEND -> {
                if (intent.type == "text/plain" || intent.type == "application/json") {
                    val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    if (sharedText != null) {
                        pendingShareContent = sharedText
                        pendingShareSource = intent.`package`
                        sharingChannel?.invokeMethod("onPendingShare", null)
                    }
                }
            }
        }
    }
}
