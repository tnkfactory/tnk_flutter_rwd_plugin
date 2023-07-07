package com.tnkfactory.flutter.rwd.tnk_flutter_rwd


import android.app.Activity
import android.app.Service
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.tnkfactory.ad.ServiceCallback
import com.tnkfactory.ad.TnkAdConfig
import com.tnkfactory.ad.TnkOfferwall
import com.tnkfactory.ad.TnkSession
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** TnkFlutterRwdPlugin */
class TnkFlutterRwdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mActivity: Activity
    private lateinit var offerwall: TnkOfferwall


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
                    offerwall.setCOPPA(call.argument("coppa") as? Boolean ?: false)
                    result.success("success")
                }
                "setUserName" -> {
                    offerwall.setUserName( call.argument("user_name") as? String ?: "")
                    result.success("success")
                }
                "showAdList" -> {
                    Log.d("start >>>>> ", "start")
                    offerwall.startOfferwallActivity(mActivity)
//                    TnkSession.showAdListByType(mActivity, call.argument("title") ?: "충전소", AdListType.ALL, AdListType.PPI, AdListType.CPS)
                    result.success("success")
                }
                "showATTPopup" -> {
                    result.success("success")
                }
                "getEarnPoint" -> {
                    offerwall.getEarnPoint() {
                        result.success(it)
                        Log.d(">>getEarnPoint >> ", "$it")
                    }
                }
                "setNoUsePointIcon" -> {
                    TnkAdConfig.usePointUnit = true
                    result.success("success")
                }
                "setNoUsePrivacyAlert" ->{
                    result.success("success")
                }
                "getQueryPoint" -> {
                    TnkSession.queryPoint(mActivity, object :ServiceCallback(){
                        override fun onReturn(context: Context?, point: Any?) {
                            result.success(point as Int)
                            Log.d(">>getQueryPoint >> ", "$point")
                        }
                    })

                }
                "purchaseItem" -> {

                    val cost = call.argument("cost") as? Int ?: 0
                    val itemId = call.argument("item_id") as? String
                    Log.d("param", "$cost //  $itemId")

                    TnkSession.purchaseItem(mActivity, cost, itemId,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context, pArr: Any) {
                                val ret = pArr as LongArray
                                if (ret[1] < 0) {
                                    //error
                                    Log.d("purchaseItem error", "current point = " + ret[0] + ", transaction id = " + ret[1] )// error
                                    result.success("fail")
                                } else {
                                    Log.d("purchaseItem", "current point = " + ret[0] + ", transaction id = " + ret[1] )
                                    result.success("success")
                                }
                            }
                        })
                }
                "withdrawPoints" -> {

                    val description = call.argument("description") as? String ?: ""

                    TnkSession.withdrawPoints(mActivity, description,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context, point: Any) {
                                val pPoint = point as Int
                                Log.d("withdrawPoints", "withdraw point = $pPoint")
                                result.success("success")
                            }
                        })
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
        offerwall = TnkOfferwall(mActivity)
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
