package com.tnkfactory.flutter.rwd.tnk_flutter_rwd.fancast

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.JsResult
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.tnkfactory.ad.TnkOfferwall
import com.tnkfactory.ad.TnkSession
import com.tnkfactory.ad.fancast.R
import com.tnkfactory.ad.rwd.AdvertisingIdInfo
import com.tnkfactory.ad.rwd.common.TAlertDialog
import com.tnkfactory.framework.vo.ValueObject
import java.net.URISyntaxException
import kotlin.getValue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TnkEventFragment : Fragment(R.layout.com_tnk_fragment_lottery) {

    private val TAG = this.javaClass.simpleName

    val viewModel: TnkEventViewModel by viewModels()

    private var preUnitId: String = ""

    var viewRoot: View? = null
    val webView: WebView?
        get() = viewRoot?.findViewById(R.id.wv_main)


    companion object {
        fun showWebviewFragment(typeCode: String): TnkEventFragment {
            val bundle = Bundle()
            bundle.putString("type_cd", typeCode)
            val fragment = TnkEventFragment()
            fragment.arguments = bundle
            return fragment
        }
    }

    private fun getEventTypeCode(): String? = requireArguments().getString("type_cd", "golfzone")

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewRoot = view
        activity?.let { activity ->
            viewModel.initAdiscopeSdk(activity) { isSuccess ->
                if (isSuccess) {
                    initView()
                } else {
//                    TnkSession.runOnMainThread {
//                        TAlertDialog.show(activity, errorMessage, { activity.finish() }, null)
//                    }
                }
            }
        }

        viewModel.webviewEventCallback.observe(viewLifecycleOwner) {
            webView?.loadUrl(it)
        }
        viewModel.onError.observe(viewLifecycleOwner) { errorMessage ->
            TnkSession.runOnMainThread {
                TAlertDialog.show(requireContext(), errorMessage, { activity?.finish() }, null)
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initView() {
        webView?.clearCache(true)
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.defaultTextEncodingName = "utf-8"
        webView?.isFocusableInTouchMode = true
        webView?.isVerticalScrollBarEnabled = false
        webView?.isHorizontalScrollBarEnabled = false
        webView?.isScrollContainer = true
        webView?.isFocusable = true
        webView?.requestFocus()
        webView?.addJavascriptInterface(TnkWebViewBridge(), "TnkWebViewBridge")

        webView?.webChromeClient = chromeClient
        webView?.webViewClient = webViewClient

        if (getEventTypeCode() == "golfzone") {
            try {

                // origin app_id 는 정수값 pub_id 는 hex 값
                // https://ap.tnkfactory.com/tnk/offevt.event.main?action=event&pub_id={app_id}&evt_id=10&adid={adid}&md_user_nm={md_user_nm}
                // op
                // https://ap.tnkfactory.com/tnk/offevt.event.main?action=event&pub_id=652635&evt_id=10&adid={adid}&md_user_nm={md_user_nm}
                // dev
                // https://adsdev.tnkad.net/tnk/offevt.event.main?action=event&app_id=657902&evt_id=10&adid={adid}&md_user_nm={md_user_nm}

                // op app_id = 652635
                // dev app_id = 657902
//                Log.d(TAG, "app_id: ${TnkCore.getSessionVO(requireContext()).getString("app_id")}")

//                val lotteryUrl =
//                    "https://ap.tnkfactory.com/tnk/offevt.event.main?action=event&pub_id={app_id}&evt_id=10&adid={adid}&md_user_nm={md_user_nm}"
////                val lotteryUrl = "https://ap.tnkfactory.com/tnk/offevt.event.main?action=event&pub_id={app_id}&evt_id=10&adid={adid}&md_user_nm=5e644c5b4a43"
//                        .replace("{app_id}", TnkCore.sessionInfo.applicationId!!)
//                        .replace("{adid}", Settings.getAdid(requireContext()))
//                        .replace("{md_user_nm}", Settings.getMediaUserName(requireContext()) ?: "")
//

//                webView?.loadUrl(lotteryUrl)
                getEventUrl()

            } catch (e: Exception) {
                e.printStackTrace()
            }

        }
    }

    private val chromeClient = object : WebChromeClient() {
        override fun onJsAlert(
            view: WebView?,
            url: String?,
            message: String?,
            result: JsResult?
        ): Boolean {
            return super.onJsAlert(view, url, message, result)
        }

        override fun onJsConfirm(
            view: WebView?,
            url: String?,
            message: String?,
            result: JsResult?
        ): Boolean {
            return super.onJsConfirm(view, url, message, result)
        }

    }

    private val webViewClient = object : WebViewClient() {
        override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
            super.onPageStarted(view, url, favicon)
        }

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)
        }


        override fun shouldOverrideUrlLoading(
            view: WebView?,
            request: WebResourceRequest?
        ): Boolean {
            try {
                activity ?: return false
                request ?: return false
                if (request.url.scheme == "intent") {
                    try {
                        // Intent 생성
                        val intent = Intent.parseUri(request.url.toString(), Intent.URI_INTENT_SCHEME)

                        // 실행 가능한 앱이 있으면 앱 실행
                        if (intent.resolveActivity(requireActivity().packageManager) != null) {
                            startActivity(intent)
                            return true
                        }

                        // Fallback URL이 있으면 현재 웹뷰에 로딩
                        val fallbackUrl = intent.getStringExtra("browser_fallback_url")
                        if (fallbackUrl != null) {
                            view?.loadUrl(fallbackUrl)
                            return true
                        }
                    } catch (e: URISyntaxException) {
                        Log.e(TAG, "Invalid intent request", e)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            }
            // 나머지 서비스 로직 구현
            return super.shouldOverrideUrlLoading(view, request)
        }

        /**
         * intent 로 시작하는 이벤트 추가
         */
        override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
            activity ?: return false
            url?.let { url ->
                if (url.startsWith("tnkscheme:")) {
                    if (url.contains("close_view")) {
                        // 웹뷰 history back 처리
                        webView?.let {
                            if (it.canGoBack()) {
                                it.goBack()
                            } else {
                                activity?.finish()
                            }
                        }
                    } else if (url.contains("show_helpdesk")) {
                        var helpUrl = TnkSession.getHelpdeskUrl(requireContext())
                        webView?.let { it.loadUrl(helpUrl) }
                    } else if (url.contains("show_offerwall")) {
                        TnkSession.runOnMainThread {
                            try {
                                TnkOfferwall(requireContext()).startOfferwallActivity(requireContext())
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                    } else if (url.contains("open_new_window")) {
                        Uri.parse(url).getQueryParameter("url")?.let {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(it))
                            startActivity(intent)
                        }
                    }
                    return true
                } else if (url.startsWith("market:")) {
                    val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                    intent?.let { startActivity(it) }
                    return true
                } else if (url.startsWith("intent:")) {
                    val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                    val existPackage: Intent? =
                        intent.getPackage()?.let {
                            requireActivity().packageManager.getLaunchIntentForPackage(it)
                        }
                    if (existPackage != null) {
                        startActivity(intent)
                    } else {
                        val marketIntent = Intent(Intent.ACTION_VIEW)
                        marketIntent.data = Uri.parse("market://details?id=" + intent.getPackage())
                        startActivity(marketIntent)
                    }
                    return true
                }
            }
            return super.shouldOverrideUrlLoading(view, url)
        }
    }

    inner class TnkWebViewBridge() {
        @JavascriptInterface
        fun loadVideoAd(unitId: String) {
            TnkSession.runOnMainThread {
                preUnitId = unitId
                viewModel.loadRv(unitId)
            }
        }

        @JavascriptInterface
        fun loadInterstitialAd(unitId: String) {
            TnkSession.runOnMainThread {
                preUnitId = unitId
                viewModel.loadInterstitial(unitId)
            }
        }

        @JavascriptInterface
        fun showInterstitialAd() {
            TnkSession.runOnMainThread {
                if (viewModel.interstitialAdLoaded(preUnitId)) {
                    viewModel.showInterstitial()
                } else {
                }
            }
        }

        @JavascriptInterface
        fun showVideoAd() {
            TnkSession.runOnMainThread {
                viewModel.showRv(preUnitId)
            }
        }

        @JavascriptInterface
        fun showOfferwall() {
            val adId = AdvertisingIdInfo.requestIdInfo(requireContext()).id
            val offerwall = TnkOfferwall(requireContext()).apply {
                // *** 적립받을 유저를 구분하기 위한 유저 식별값을 설정해주세요 ***
                setCOPPA(false)
            }

            TnkSession.runOnMainThread {
                offerwall.startOfferwallActivity(requireContext())
            }
        }

        @JavascriptInterface
        fun closeWebView() {
            activity?.finish()
        }


        @JavascriptInterface
        fun f() {
            Handler(Looper.getMainLooper()).post {
                Log.d(TAG, "call f()")
            }
        }
    }


    fun getEventUrl() {
        lifecycleScope.launch(Dispatchers.IO) {
            val offerwall = TnkOfferwall(requireActivity()).apply {
                getEventLink(103169) { eventLinkVo ->
                    eventLinkVo?.mkt_app_id?.let { appId ->
                        lifecycleScope.launch(Dispatchers.Main) {
                            webView?.loadUrl(appId)
                        }
                    }
                }
            }
        }

    }

    fun parserTnkEvetLink(res: ValueObject): EventLinkVo {
        return EventLinkVo.parse(res)
    }

    class EventLinkVo(
        var mkt_id: String = "",
        var mkt_app_id: String = "",
        var apk_key: String = "",
        var webview_yn: String = "N",
        var check_url: String = "",
        var cnts_skip: Int = 0,
        var cnts_type: Int = -1,
        var ret_cd: Int = 0
    ) {
        companion object {
            fun parse(vo: ValueObject): EventLinkVo {
                return EventLinkVo(
                    mkt_id = vo.getString("mkt_id") ?: "",
                    mkt_app_id = vo.getString("mkt_app_id") ?: "",
                    apk_key = vo.getString("apk_key") ?: "",
                    webview_yn = vo.getString("webview_yn") ?: "N",
                    check_url = vo.getString("check_url") ?: "",
                    cnts_skip = vo.getInt("cnts_skip") ?: 0,
                    cnts_type = vo.getInt("cnts_type") ?: -1,
                    ret_cd = vo.getInt("ret_cd") ?: 0
                )
            }
        }
    }
}
