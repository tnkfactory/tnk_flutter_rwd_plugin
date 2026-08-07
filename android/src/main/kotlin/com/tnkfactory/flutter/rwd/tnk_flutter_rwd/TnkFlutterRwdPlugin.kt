package com.tnkfactory.flutter.rwd.tnk_flutter_rwd


import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import com.tnkfactory.ad.*
import com.tnkfactory.ad.basic.AdPlacementView
import com.tnkfactory.ad.off.TnkOffNavi
import com.tnkfactory.ad.rwd.Settings
import com.tnkfactory.ad.rwd.TnkCore
import com.tnkfactory.ad.rwd.Utils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicBoolean

private const val LOG_TAG = "TnkFlutterRwdPlugin"

// 비동기 응답 대기 한계 시간. SDK 콜백이 유실되어도 Flutter 쪽 await 가 영구히 멈추지 않도록 한다.
private const val DEFAULT_TIMEOUT_MS = 30_000L

/**
 * MethodChannel.Result 를 감싸서 아래를 보장한다.
 *
 * 1. 응답은 정확히 한 번만 전달된다. (중복 응답 시 발생하는 "Reply already submitted" 방지)
 * 2. 응답은 항상 메인(플랫폼) 스레드에서 전달된다.
 * 3. timeoutMs 안에 응답이 없으면 timeoutValue 로 대신 응답한다. (무한 대기 방지)
 *
 * Dart 쪽에 PlatformException 처리가 없으므로 실패도 success() 로 전달한다.
 * 실패 여부는 각 메소드의 기존 반환 규약(res_code / "fail" / -1)으로 표현한다.
 */
private class SafeResult(
    private val raw: Result,
    private val method: String,
    timeoutMs: Long = 0L,
    timeoutValue: Any? = null,
) {
    private val replied = AtomicBoolean(false)
    private val handler = Handler(Looper.getMainLooper())
    private var timeoutTask: Runnable? = null

    init {
        if (timeoutMs > 0L) {
            timeoutTask = Runnable {
                Log.w(LOG_TAG, "$method: 응답 시간(${timeoutMs}ms) 초과. 기본값으로 응답한다.")
                success(timeoutValue)
            }.also { handler.postDelayed(it, timeoutMs) }
        }
    }

    fun success(value: Any?) = reply { raw.success(value) }

    fun notImplemented() = reply { raw.notImplemented() }

    private fun reply(block: () -> Unit) {
        if (!replied.compareAndSet(false, true)) {
            // 이미 응답했다. SDK 콜백이 두 번 호출되는 경우가 여기로 들어온다.
            Log.w(LOG_TAG, "$method: 중복 응답을 무시한다.")
            return
        }
        timeoutTask?.let { handler.removeCallbacks(it) }
        timeoutTask = null

        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            handler.post(block)
        }
    }
}

/** {"res_code":..., "res_message":...} 형태의 응답 문자열을 만든다. */
private fun jsonResult(code: String, message: String): String =
    JSONObject().put("res_code", code).put("res_message", message).toString()

private val JSON_FAIL = jsonResult("-1", "fail")


/** TnkFlutterRwdPlugin */
class TnkFlutterRwdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val TAG = this.javaClass.simpleName

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null
    private var mActivity: Activity? = null
    private var offerwall: TnkOfferwall? = null
    private var placementView: AdPlacementView? = null
    private var tnkNavi: TnkOffNavi? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tnk_flutter_rwd").also {
            it.setMethodCallHandler(this)
        }
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
                Log.d(TAG, "$jEvent")
                Handler(Looper.getMainLooper()).post {
                    // 엔진이 이미 분리된 뒤에도 호출될 수 있으므로 channel 을 확인한다.
                    channel?.invokeMethod("tnkAnalytics", jEvent.toString())
                }
            }
        })
    }

    /** 엔진 분리 시 static 리스너가 플러그인/Activity 를 붙잡지 않도록 no-op 으로 되돌린다. */
    private fun clearTnkAnalytics() {
        TnkAdAnalytics.setEventListener(object : TnkAdAnalytics.TnkAdEVentListener {
            override fun onEvent(event: String, params: HashMap<String, String>) {}
        })
    }

    // 사용자 상호작용(약관 팝업 등)이 끼어들지 않는 메소드에만 타임아웃을 건다.
    // 팝업이 뜨는 메소드는 사용자가 오래 머무를 수 있어 타임아웃이 오탐이 된다.
    private fun timeoutValueOf(method: String): Any? = when (method) {
        "getEarnPoint", "getQueryPoint" -> -1
        "getPlacementJsonData", "onItemClick" -> JSON_FAIL
        "purchaseItem", "withdrawPoints", "openEventWebView", "showEventWebPage" -> "fail"
        else -> null
    }

    private fun timeoutMsOf(method: String): Long = when (method) {
        "getEarnPoint", "getQueryPoint", "getPlacementJsonData", "onItemClick",
        "purchaseItem", "withdrawPoints", "openEventWebView", "showEventWebPage" -> DEFAULT_TIMEOUT_MS

        else -> 0L
    }

    /** Dart 가 보내는 정수는 크기에 따라 Integer/Long 으로 도착하므로 Number 로 받는다. */
    private fun MethodCall.longArg(key: String, default: Long = 0L): Long =
        (argument(key) as? Number)?.toLong() ?: default

    private fun MethodCall.intArg(key: String, default: Int = 0): Int =
        (argument(key) as? Number)?.toInt() ?: default

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {

        val result = SafeResult(rawResult, call.method, timeoutMsOf(call.method), timeoutValueOf(call.method))

        try {
            if (call.method == "getPlatformVersion") {
                result.success("Android ${Build.VERSION.RELEASE}")
                return
            }

            // Activity 에 attach 되기 전/후에 호출되면 예전에는 lateinit 예외가 났다.
            val activity = mActivity
            val offerwall = this.offerwall
            if (activity == null || offerwall == null) {
                Log.w(TAG, "${call.method}: Activity 에 attach 되지 않은 상태이다.")
                result.success(notAttachedValueOf(call.method))
                return
            }

            when (call.method) {

                "setCOPPA" -> {
                    offerwall.setCOPPA(call.argument("coppa") as? Boolean ?: false)
                    result.success("success")
                }

                "setUserName" -> {
                    offerwall.setUserName(call.argument("user_name") as? String ?: "")
                    result.success("success")
                }

                "setCategoryAndFilter" -> {
                    TnkAdConfig.headerConfig.startCategory = call.intArg("category")
                    TnkAdConfig.headerConfig.startFilter = call.intArg("filter")
                    result.success("success")
                }

                "showAdList" -> {
                    val appId = call.longArg("app_id")
                    if (appId != 0L) {
                        offerwall.startOfferwallActivity(activity, appId)
                    } else {
                        offerwall.startOfferwallActivity(activity)
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
                    // usePointUnit 은 pointEffectType setter 가 파생시키는 값이라 직접 대입하면
                    // 두 값이 어긋난다. (렌더링 코드가 두 값을 섞어서 읽는다.)
                    TnkAdConfig.pointEffectType = TNK_POINT_EFFECT_TYPE.UNIT
                    result.success("success")
                }

                "setNoUsePrivacyAlert" -> {
                    TnkAdConfig.useTermsPopup = false
                    result.success("success")
                }

                "getQueryPoint" -> {
                    TnkSession.queryPoint(activity, object : ServiceCallback() {
                        override fun onReturn(context: Context?, point: Any?) {
                            Log.d(TAG, "getQueryPoint point = $point")
                            // as Int 로 캐스팅하면 예외가 invokeAsync 에 잡혀 onError 로 흘러가고
                            // 응답이 사라진다. 안전 캐스팅 후 직접 판단한다.
                            result.success((point as? Number)?.toInt() ?: -1)
                        }

                        override fun onError(context: Context?, ex: Throwable?) {
                            Log.w(TAG, "getQueryPoint error : ${ex?.message}")
                            result.success(-1)
                        }
                    })
                }

                "purchaseItem" -> {
                    val cost = call.intArg("cost")
                    val itemId = call.argument("item_id") as? String
                    Log.d(TAG, "purchaseItem $cost // $itemId")

                    TnkSession.purchaseItem(
                        activity, cost, itemId,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context?, pArr: Any?) {
                                val ret = pArr as? LongArray
                                if (ret == null || ret.size < 2 || ret[1] < 0) {
                                    result.success("fail")
                                } else {
                                    result.success("success")
                                }
                            }

                            override fun onError(context: Context?, ex: Throwable?) {
                                Log.w(TAG, "purchaseItem error : ${ex?.message}")
                                result.success("fail")
                            }
                        })
                }

                "withdrawPoints" -> {
                    val description = call.argument("description") as? String ?: ""

                    TnkSession.withdrawPoints(
                        activity, description,
                        object : ServiceCallback() {
                            override fun onReturn(context: Context?, point: Any?) {
                                Log.d(TAG, "withdraw point = $point")
                                result.success("success")
                            }

                            override fun onError(context: Context?, ex: Throwable?) {
                                Log.w(TAG, "withdrawPoints error : ${ex?.message}")
                                result.success("fail")
                            }
                        })
                }

                "onItemClick" -> {
                    val view = placementView
                    if (view == null) {
                        result.success(jsonResult("-1", "getPlacementJsonData 를 먼저 호출해야 합니다."))
                        return
                    }
                    val appId = (call.argument("app_id") as? String)?.toLongOrNull()
                        ?: call.longArg("app_id", -1L)
                    if (appId <= 0L) {
                        result.success(jsonResult("-1", "app_id 가 올바르지 않습니다."))
                        return
                    }
                    // SDK 의 onItemClick 은 목록에 없는 appId 면 콜백을 호출하지 않는다.
                    if (view.adList.none { it.appId == appId }) {
                        result.success(jsonResult("-1", "목록에 없는 광고입니다. app_id = $appId"))
                        return
                    }
                    view.onItemClick(appId) { success, errorMessage ->
                        if (success) {
                            result.success(jsonResult("1", "success"))
                        } else {
                            result.success(jsonResult("-1", errorMessage))
                        }
                    }
                }

                "getPlacementJsonData" -> {
                    val view = offerwall.getAdPlacementView(activity)
                    placementView = view

                    view.placementEventListener = object : PlacementEventListener {
                        override fun didAdDataLoaded(placementId: String, customData: String?) {
                            // 광고가 1건일 때도 정상 응답해야 한다. (기존 size > 1 은 1건을 실패로 처리했다)
                            val payload = try {
                                if (view.adList.size > 0) {
                                    JSONObject().apply {
                                        // getPubInfoJson() 은 null 을 반환할 수 있다.
                                        put("pub_info", JSONObject(view.getPubInfoJson() ?: "{}"))
                                        put("ad_list", JSONArray(view.getAdListJson()))
                                        put("res_code", "1")
                                        put("res_message", "success")
                                    }.toString()
                                } else {
                                    null
                                }
                            } catch (e: Exception) {
                                Log.w(TAG, "getPlacementJsonData parse error : ${e.message}")
                                null
                            }
                            result.success(payload ?: jsonResult("-99", "광고 로드 실패 id $placementId"))
                        }

                        override fun didAdItemClicked(appId: String, appName: String) {
                        }

                        override fun didFailedToLoad(placementId: String) {
                            // SDK 가 이 콜백을 IO 스레드에서 호출하는 경로가 있다.
                            // SafeResult 가 메인 스레드로 넘겨준다.
                            result.success(jsonResult("-99", "광고 로드 실패 id $placementId"))
                        }

                        override fun didMoreLinkClicked() {
                        }
                    }
                    view.loadAdList(call.argument("placement_id") as? String ?: "")
                }

                "setUseTermsPopup" -> {
                    TnkAdConfig.useTermsPopup = call.argument("use_yn") as? Boolean ?: false
                    result.success("success")
                }

                "setUserTermsAgree" -> {
                    val agree = call.argument("agree") as? Boolean ?: false
                    Settings.setAgreePrivacy(activity, agree)
                    result.success("success")
                }

                "isUserTermsAgree" -> {
                    result.success(Settings.isAgreePrivacy(activity))
                }

                "openEventWebView" -> {
                    val eventId = call.longArg("eventId")
                    TnkSession.runOnIoThread {
                        // getEventLink 는 호출 스레드에서 동기로 동작하고 콜백도 같은 스레드에서 온다.
                        try {
                            offerwall.getEventLink(eventId) { eventVo ->
                                val link = eventVo?.mkt_app_id
                                if (link.isNullOrEmpty()) {
                                    Log.d(TAG, "이벤트 정보가 존재하지 않습니다.")
                                    result.success("fail")
                                } else {
                                    TnkSession.runOnMainThread {
                                        TnkWebEventActivity.start(activity, link)
                                    }
                                    result.success("success")
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "openEventWebView error : ${e.message}")
                            result.success("fail")
                        }
                    }
                }

                "showCustomTapActivity" -> {
                    // 구현부가 비활성화되어 있으므로 실패로 응답한다.
                    result.success("fail")
                }

                "setCustomUnitIcon" -> {
                    call.argument<HashMap<String, String>>("map")?.let {
                        if (setCustomUnitIcon(it)) {
                            result.success("success")
                        } else {
                            result.success("error")
                        }
                    } ?: result.success("fail")
                }

                // 광고 상세 화면 출력(상세 없는 타입도 상세화면 출력)
                "presentAdDetailView" -> {
                    val appId = call.longArg("app_id")
                    val actionId = call.intArg("action_id")

                    withTermsAgreed(offerwall, activity, result) {
                        offerwall.adDetail(activity, appId, actionId) { isSuccess, error ->
                            result.success(adCallbackJson(isSuccess, error))
                        }
                    }
                }

                // 광고 참여(상세화면의 참여버튼 효과)
                "adJoin" -> {
                    val appId = call.longArg("app_id")
                    val actionId = call.intArg("action_id")

                    withTermsAgreed(offerwall, activity, result) {
                        offerwall.adJoin(activity, appId, actionId) { isSuccess, error ->
                            result.success(adCallbackJson(isSuccess, error))
                        }
                    }
                }

                // 광고 타입에 따라 참여 or 상세 호출
                "adAction" -> {
                    val appId = call.longArg("app_id")
                    val actionId = call.intArg("action_id")

                    // adAction 은 내부에서 약관 다이얼로그를 띄울 수 있으므로 IO 스레드에서 부르면 안 된다.
                    withTermsAgreed(offerwall, activity, result) {
                        offerwall.adAction(activity, appId, actionId) { isSuccess, error ->
                            result.success(adCallbackJson(isSuccess, error))
                        }
                    }
                }

                "setPubCustomUi" -> {
                    result.success("no use in android..")
                }

                "showEventWebPage" -> {
                    val param = call.argument<HashMap<String, String>>("map")
                    if (param == null) {
                        result.success("fail to show.. please check parameter")
                        return
                    }
                    val eventId = (param["event_id"] ?: "").toLongOrNull()
                    if (eventId == null) {
                        result.success("fail to show.. please check eventId")
                        return
                    }

                    TnkSession.runOnIoThread {
                        try {
                            offerwall.getEventLink(eventId) { eventVo ->
                                if (eventVo != null) {
                                    TnkSession.runOnMainThread {
                                        TnkWebEventActivity.start(activity, eventVo.mkt_app_id)
                                    }
                                    result.success("showEventWebPage")
                                } else {
                                    TnkSession.runOnMainThread {
                                        Toast.makeText(activity, "이벤트 URL을 가져오지 못했습니다.", Toast.LENGTH_SHORT).show()
                                    }
                                    result.success("fail")
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "showEventWebPage error : ${e.message}")
                            result.success("fail")
                        }
                    }
                }

                "showMyEarnPointList" -> {
                    val navi = tnkNavi
                    if (navi == null) {
                        result.success(FRAGMENT_ACTIVITY_REQUIRED)
                        return
                    }
                    TnkSession.runOnMainThread {
                        // 이 블록은 try/catch 밖에서 실행되므로 여기서 직접 막는다.
                        try {
                            navi.moveToMyMenu(1)
                            result.success("show MyEarnPointList")
                        } catch (e: Exception) {
                            Log.w(TAG, "showMyEarnPointList error : ${e.message}")
                            result.success("fail")
                        }
                    }
                }

                "showAdListWithPlacement" -> {
                    try {
                        val placementId = (call.argument("placement_id") as? String ?: "")
                        val categoryId = call.intArg("category_id")
                        val filterId = call.intArg("filter_id")

                        Settings.setPlacementId(activity, placementId)

                        TnkCore.offRepository.adListCacheClear()
                        TnkAdConfig.headerConfig.startCategory = categoryId
                        TnkAdConfig.headerConfig.startFilterID = filterId

                        offerwall.startOfferwallActivity(activity)

                        result.success("showAdListWithPlacement")
                    } catch (e: Exception) {
                        e.printStackTrace()
                        // 예전에는 여기서 응답을 보내지 않아 Flutter 가 무한 대기했다.
                        result.success("fail")
                    }
                }

                else -> result.notImplemented()

            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Dart 쪽에 PlatformException 처리가 없어 result.error() 를 쓰지 않는다.
            result.success(e.message ?: "fail")
        }
    }

    /**
     * 약관에 동의한 상태를 보장한 뒤 [onAgreed] 를 실행한다.
     *
     * SDK 의 adDetail/adJoin/adAction 은 약관 팝업에서 취소하면 콜백을 호출하지 않아
     * Flutter 가 영구히 대기한다. 그래서 팝업을 여기서 먼저 처리하고 취소를 직접 응답한다.
     * (동의하면 Settings 에 저장되므로 이어지는 SDK 호출은 팝업을 다시 띄우지 않는다.)
     */
    private fun withTermsAgreed(
        offerwall: TnkOfferwall,
        activity: Activity,
        result: SafeResult,
        onAgreed: () -> Unit,
    ) {
        if (Settings.isAgreePrivacy(activity)) {
            onAgreed()
            return
        }
        if (offerwall.tnkContext == null) {
            // FragmentActivity 가 아니면 SDK 가 팝업을 띄우지 못하고 콜백도 오지 않는다.
            result.success(jsonResult("-1", FRAGMENT_ACTIVITY_REQUIRED))
            return
        }
        offerwall.showTermsDialog(activity) { isTermsAgreed ->
            if (isTermsAgreed) {
                onAgreed()
            } else {
                result.success(jsonResult("-2", "약관 동의를 취소했습니다."))
            }
        }
    }

    private fun adCallbackJson(isSuccess: Boolean, error: TnkError?): String =
        if (isSuccess) {
            jsonResult("1", "success")
        } else {
            jsonResult("" + (error?.code ?: "99"), "" + (error?.message ?: "error"))
        }

    /** Activity 미연결 상태에서 각 메소드가 기대하는 형태로 실패를 알린다. */
    private fun notAttachedValueOf(method: String): Any? = when (method) {
        "getEarnPoint", "getQueryPoint" -> -1
        "isUserTermsAgree" -> false
        "getPlacementJsonData", "onItemClick", "presentAdDetailView", "adJoin", "adAction" ->
            jsonResult("-1", "Activity 에 attach 되지 않았습니다.")

        else -> "fail"
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
        Log.d(TAG, "onDetachedFromEngine")
        channel?.setMethodCallHandler(null)
        channel = null
        clearTnkAnalytics()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        bindActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        unbindActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        // 회전 후 새 Activity 로 교체하지 않으면 파괴된 Activity 를 계속 참조하게 된다.
        bindActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        unbindActivity()
    }

    private fun bindActivity(activity: Activity) {
        mActivity = activity
        offerwall = TnkOfferwall(activity)
        // FlutterActivity 는 FragmentActivity 를 상속하지 않는다.
        // 예전에는 여기서 ClassCastException 이 나 플러그인 attach 시점에 앱이 죽었다.
        tnkNavi = (activity as? FragmentActivity)?.let { TnkOffNavi(it) }
        if (activity !is FragmentActivity) {
            Log.e(TAG, FRAGMENT_ACTIVITY_REQUIRED)
        }
    }

    private fun unbindActivity() {
        placementView?.placementEventListener = null
        placementView = null
        tnkNavi = null
        offerwall = null
        mActivity = null
    }

    companion object {
        private const val FRAGMENT_ACTIVITY_REQUIRED =
            "MainActivity 가 FlutterFragmentActivity 를 상속해야 TNK 오퍼월을 사용할 수 있습니다."
    }
}
