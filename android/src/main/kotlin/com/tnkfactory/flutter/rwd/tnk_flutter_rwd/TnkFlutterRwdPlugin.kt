package com.tnkfactory.flutter.rwd.tnk_flutter_rwd


import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.tnkfactory.ad.*
import com.tnkfactory.ad.basic.AdPlacementView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject


/** TnkFlutterRwdPlugin */
class TnkFlutterRwdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mActivity: Activity
    private lateinit var offerwall: TnkOfferwall
    private lateinit var placementView: AdPlacementView

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tnk_flutter_rwd")
        channel.setMethodCallHandler(this)
        setTnkAnalytics()
    }

    fun setTnkAnalytics() {
        TnkAdAnalytics.setEventListener(object : TnkAdAnalytics.TnkAdEVentListener {
            override fun onEvent(event: String, params: HashMap<String, String>) {
                val jParams = JSONArray()
                params.keys.forEach {
                    jParams.put(
                        JSONObject().put(it, params[it])
                    )
                }
                val jEvent = JSONObject()
                jEvent.put("event", event)
                jEvent.put("params", jParams)
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("tnkAnalytics", jEvent.toString())
                }
            }
        })
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        try {
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${Build.VERSION.RELEASE}")
                }

                "setCOPPA" -> {
                    offerwall.setCOPPA(call.argument("coppa") as? Boolean ?: false)
                    result.success("success")
                }

                "setUserName" -> {
                    offerwall.setUserName(call.argument("user_name") as? String ?: "")
                    result.success("success")
                }

                "setCategoryAndFilter" -> {
                    TnkAdConfig.headerConfig.startCategory = call.argument("category") as? Int ?: 0
                    TnkAdConfig.headerConfig.startFilter = call.argument("filter") as? Int ?: 0
                    result.success("success")
                }

                "showAdList" -> {
                    var appId = call.argument("app_id") ?: 0
                    if (appId != 0) {
                        offerwall.startOfferwallActivity(mActivity, appId.toLong())
                    } else {
                        offerwall.startOfferwallActivity(mActivity)
                    }
                    result.success("success")
                }

                "showATTPopup" -> {
                    result.success("success")
                }

                "getEarnPoint" -> {
                    offerwall.getEarnPoint() {
                        result.success(it)
                    }
                }

                "setNoUsePointIcon" -> {
                    TnkAdConfig.usePointUnit = true
                    result.success("success")
                }

                "setNoUsePrivacyAlert" -> {
                    TnkAdConfig.useTermsPopup = false
                    result.success("success")
                }

                "getQueryPoint" -> {
                    TnkSession.queryPoint(mActivity, object : ServiceCallback() {
                        override fun onReturn(context: Context?, point: Any?) {
                            Log.d("jameson, getQueryPoint", "point = $point")
                            result.success(point as Int)
                        }
                    })

                }

                "purchaseItem" -> {

                    val cost = call.argument("cost") as? Int ?: 0
                    val itemId = call.argument("item_id") as? String
                    Log.d("param", "$cost //  $itemId")

                    TnkSession.purchaseItem(
                        mActivity, cost, itemId,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context, pArr: Any) {
                                val ret = pArr as LongArray
                                if (ret[1] < 0) {
                                    //error
                                    result.success("fail")
                                } else {
                                    result.success("success")
                                }
                            }
                        })
                }

                "withdrawPoints" -> {

                    val description = call.argument("description") as? String ?: ""

                    TnkSession.withdrawPoints(
                        mActivity, description,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context, point: Any) {
                                val pPoint = point as Int
                                Log.d("withdrawPoints", "withdraw point = $pPoint")
                                result.success("success")
                            }
                        })
                }

                "onItemClick" -> {
                    placementView.onItemClick(
                        (call.argument("app_id") as? String ?: "0").toLong()
                    ) { success, errorMessage ->
                        JSONObject().apply {
                            if (success) {
                                put("res_code", "1")
                                put("res_message", "success")
                            } else {
                                put("res_code", "-1")
                                put("res_message", errorMessage)
                            }
                        }.also {
                            result.success(it.toString())
                        }
                    }
                }

                "getPlacementJsonData" -> {
                    placementView = offerwall.getAdPlacementView(mActivity)

                    placementView.placementEventListener = object : PlacementEventListener {
                        override fun didAdDataLoaded(placementId: String, customData: String?) {
                            try {
                                if (placementView.adList.size > 1) {
                                    JSONObject().apply {
                                        put("pub_info", JSONObject(placementView.getPubInfoJson()))
                                        put("ad_list", JSONArray(placementView.getAdListJson()))
                                        put("res_code", "1")
                                        put("res_message", "success")
                                    }.also {
                                        result.success(it.toString())
                                    }
                                    return
                                }
                            } catch (e: Exception) {

                            }
                            JSONObject().apply {
                                put("res_code", "-99")
                                put("res_message", "광고 로드 실패 id " + placementId)
                            }.also {
                                result.success(it.toString())
                            }
                            return
                        }

                        override fun didAdItemClicked(appId: String, appName: String) {
                        }

                        override fun didFailedToLoad(placementId: String) {
                            JSONObject().apply {
                                put("res_code", "-99")
                                put("res_message", "광고 로드 실패 id " + placementId)
                            }.also {
                                result.success(it.toString())
                            }
                        }

                        override fun didMoreLinkClicked() {
                        }
                    }
                    placementView.loadAdList(call.argument("placement_id") as? String ?: "")
                }

                "setUseTermsPopup" -> {
                    TnkAdConfig.useTermsPopup = call.argument("use_yn") as? Boolean ?: false
                }

                //fun getEventLink(eventId: Long, onResult: (EventLinkVo?) -> Unit) {
                //fun openEventWebView(eventId: Long)
                "getEventLink" -> {

                }

                "openEventWebView" -> {
//                    val eventId: Int = (call.argument("eventId") as? Int ?: 0)
//                    TnkEventActivity.startActivity(mActivity, eventId.toLong())
                }

                "showCustomTapActivity" -> {
//                    val iUrl: String = (call.argument("url") as? String ?: "")
//                    val depp_link = (call.argument("deep_link") as? String ?: "")
//
//                    val customTabsIntent = CustomTabsIntent.Builder().build()
//                    var finalUrl = iUrl
//                        .replace("{pub_id_hex}", TnkCore.sessionInfo.applicationId ?: "")
//                        .replace("{adid}", Settings.getAdid(mActivity))
//                        .replace("{md_user_nm}", Settings.getMediaUserName(mActivity) ?: "")
//                    if (!TextUtils.isEmpty(depp_link) && depp_link != "0") {
//                        finalUrl += ("&" + "depp_link" + "=" + depp_link)
//                    }
//
//                    TnkCustomTabActivityHelper.openCustomTab(
//                        mActivity, customTabsIntent, Uri.parse(finalUrl), TnkWebviewFallback()
//                    )
                }

                "setCustomUnitIcon" -> {
                    call.argument<HashMap<String, String>>("map")?.let {
                        val res = setCustomUnitIcon(it)
                        if (res) {
                            result.success("success")
                        } else {
                            result.success("error")
                        }
                    } ?: result.success("fail")

                }
                // 광고 상세 화면 출력(상세 없는 타입도 상세화면 출력)
                "presentAdDetailView" -> {
                    val appId = (call.argument("app_id") as? Int ?: 0)
                    val actionId = (call.argument("action_id") as? Int ?: 0)

                    offerwall.adDetail(mActivity, appId.toLong(), actionId, { isSuccess, error ->
                        JSONObject().apply {
                            if (isSuccess) {
                                put("res_code", "1")
                                put("res_message", "success")
                            } else {
                                put("res_code", "" + (error?.code ?: "99"))
                                put("res_message", "" + (error?.message ?: "error"))
                            }
                        }.also {
                            result.success(it.toString())
                        }
                    })

                }

                // 광고 참여(상세화면의 참여버튼 효과)
                "adJoin" -> {
                    val appId = (call.argument("app_id") as? Int ?: 0)
                    val actionId = (call.argument("action_id") as? Int ?: 0)

//                    Handler(Looper.getMainLooper()).post{
                    offerwall.adJoin(mActivity, appId.toLong(), actionId, { isSuccess, error ->
                        JSONObject().apply {
                            if (isSuccess) {
                                put("res_code", "1")
                                put("res_message", "success")
                            } else {
                                put("res_code", "" + (error?.code ?: "99"))
                                put("res_message", "" + (error?.message ?: "error"))
                            }
                        }.also {
                            result.success(it.toString())
                        }
                    })
//                    }


                }

                // 광고 타입에 따라 참여 or 상세 호출
                "adAction" -> {
                    val appId = (call.argument("app_id") as? Int ?: 0)
                    val actionId = (call.argument("action_id") as? Int ?: 0)

                    offerwall.adAction(mActivity, appId.toLong(), actionId, { isSuccess, error ->
                        JSONObject().apply {
                            if (isSuccess) {
                                put("res_code", "1")
                                put("res_message", "success")
                            } else {
                                put("res_code", "" + (error?.code ?: "99"))
                                put("res_message", "" + (error?.message ?: "error"))
                            }
                        }.also {
                            result.success(it.toString())
                        }
                    })
                }

            }
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(e.message)
        }
    }

    fun setCustomUnitIcon(param: HashMap<String, String>): Boolean {
        val option = param["option"] ?: "2"

        TnkAdConfig.pointEffectType = when (option) {
            "1" -> TNK_POINT_EFFECT_TYPE.ICON_N_UNIT    // 재화 이이콘, 단위 둘다 표시
            "2" -> TNK_POINT_EFFECT_TYPE.ICON           // 재화 아이콘만 표시
            "3" -> TNK_POINT_EFFECT_TYPE.UNIT           // 재화 단위만 표시
            "4" -> TNK_POINT_EFFECT_TYPE.NONE           // 둘다 표시 안함
            else -> return false
        }
        return true
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
