package com.tnkfactory.flutter.rwd.tnk_flutter_rwd

import android.app.Activity
import androidx.annotation.NonNull

import com.tnkfactory.ad.AdListType
import com.tnkfactory.ad.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.tnkfactory.ad.TnkSession
import java.lang.Exception

/** TnkFlutterRwdPlugin */
class TnkFlutterRwdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mActivity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tnk_flutter_rwd")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        try {
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "setCOPPA" -> {
                    TnkSession.setCOPPA(mActivity, call.argument("coppa") as? Boolean ?: false)
                    result.success("success")
                }
                "setUserName" -> {
                    TnkSession.setUserName(mActivity, call.argument("user_name") as? String ?: "")
                    result.success("success")
                }
                "showAdList" -> {
                    TnkSession.showAdListByType(mActivity, call.argument("title") ?: "충전소", AdListType.ALL, AdListType.PPI, AdListType.CPS)
                    result.success("success")
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.success(e.message)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
//        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
//        TODO("Not yet implemented")
    }
}
