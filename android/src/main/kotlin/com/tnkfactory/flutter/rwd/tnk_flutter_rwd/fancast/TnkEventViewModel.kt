package com.tnkfactory.flutter.rwd.tnk_flutter_rwd.fancast

import android.app.Activity
import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.nps.adiscope.AdiscopeError
import com.nps.adiscope.AdiscopeSdk
import com.nps.adiscope.interstitial.InterstitialAd
import com.nps.adiscope.interstitial.InterstitialAdListener
import com.nps.adiscope.reward.RewardItem
import com.nps.adiscope.reward.RewardedVideoAd
import com.nps.adiscope.reward.RewardedVideoAdListener
import com.tnkfactory.ad.TnkSession
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TnkEventViewModel(private val application: Application) : AndroidViewModel(application) {

    lateinit var rewardedVideoAd: RewardedVideoAd
    lateinit var interstitialAd: InterstitialAd

    var previewInterstitialAdId: String = ""
    var previewRewardedVideoAdId: String = ""

    val onError: MutableLiveData<String> = MutableLiveData()
    val webviewEventCallback: MutableLiveData<String> = MutableLiveData()

    fun initAdiscopeSdk(activity: Activity, onResult: (Boolean) -> Unit) {
        viewModelScope.launch(Dispatchers.Main) {
            try {
                AdiscopeSdk.setUserId("tnk_test")
//                        AdiscopeSdk.setUserId(Settings.getMediaUserName(activity))
                AdiscopeSdk.getOptionSetterInstance(activity)
                AdiscopeSdk.initialize(activity) { isInitialized ->
                    if (isInitialized) {

                        initListener(activity)
                        onResult(true)
                    } else {
                        onResult(false)
                        onError.postValue("광고 SDK 초기화에 실패했습니다. 잠시 후 다시 시도해주세요. \nerror code : TNK-0001")
                    }
                }
            } catch (e: Exception) {
                onResult(false)
                onError.postValue("광고 SDK 초기화에 실패했습니다. 잠시 후 다시 시도해주세요. \nerror code : TNK-0001")
            }
        }
    }

    private fun initListener(activity: Activity) {
        try {
            // rv 광고
            rewardedVideoAd = AdiscopeSdk.getRewardedVideoAdInstance(activity).apply {
                setRewardedVideoAdListener(rewardedVideoAdListener)
            }

            // interstitial 광고
            interstitialAd = AdiscopeSdk.getInterstitialAdInstance(activity).apply {
                setInterstitialAdListener(interstitialAdListener)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private val rewardedVideoAdListener = object : RewardedVideoAdListener {
        override fun onRewardedVideoAdLoaded(p0: String?) {
            Log.d(TAG, "onRewardedVideoAdLoaded, $p0")
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onAdLoadSuccess('%s')", previewRewardedVideoAdId))
                webviewEventCallback.postValue(
                    String.format(
                        "javascript:onAdLoadSuccess('%s')",
                        previewRewardedVideoAdId
                    )
                )
            }
        }

        override fun onRewardedVideoAdFailedToLoad(p0: String?, p1: AdiscopeError?) {
            TnkSession.runOnMainThread {
                onError.postValue("광고를 불러오지 못했습니다.\n${p0 ?: ""}")
            }
        }

        override fun onRewardedVideoAdOpened(p0: String?) {
            Log.d(TAG, "onRewardedVideoAdOpened $p0")
        }

        override fun onRewardedVideoAdClosed(p0: String?) {
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onAdClosed('%s')", previewRewardedVideoAdId))
                webviewEventCallback.postValue(String.format("javascript:onAdClosed('%s')", previewRewardedVideoAdId))
                previewRewardedVideoAdId = ""
            }
            Log.d(TAG, "onRewardedVideoAdClosed $p0")
        }


        override fun onRewarded(p0: String?, p1: RewardItem?) {
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onRewarded('%s')", previewRewardedVideoAdId))
                webviewEventCallback.postValue(String.format("javascript:onRewarded('%s')", previewRewardedVideoAdId))
                previewRewardedVideoAdId = ""
            }
            Log.d(TAG, "onRewarded $p0, ${p1!!.amount} ${p1!!.type}")
        }

        override fun onRewardedVideoAdFailedToShow(p0: String?, p1: AdiscopeError?) {
            Log.d(TAG, "onRewardedVideoAdFailedToShow $p0 , [$p1]")
            TnkSession.runOnMainThread {
                onError.postValue("광고영상 재생에 실패했습니다.\n${p0 ?: ""}")
            }
        }

    }

    private val interstitialAdListener = object : InterstitialAdListener {
        override fun onInterstitialAdLoaded() {
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onAdLoadSuccess('%s')", previewInterstitialAdId))
                webviewEventCallback.postValue(
                    String.format(
                        "javascript:onAdLoadSuccess('%s')",
                        previewInterstitialAdId
                    )
                )
            }
            Log.d(TAG, "onInterstitialAdLoaded")

        }

        override fun onInterstitialAdFailedToLoad(p0: AdiscopeError?) {
            Log.d(TAG, "onInterstitialAdFailedToLoad ${p0.toString()}")
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onAdLoadFail('%s', '%s')", previewInterstitialAdId, p0?.description))
                webviewEventCallback.postValue(
                    String.format(
                        "javascript:onAdLoadFail('%s', '%s')",
                        previewInterstitialAdId,
                        p0?.description
                    )
                )
            }
        }

        override fun onInterstitialAdOpened(p0: String?) {
            Log.d(TAG, "onInterstitialAdOpened")
        }

        override fun onInterstitialAdClosed(p0: String?) {
            TnkSession.runOnMainThread {
//                webView?.loadUrl(String.format("javascript:onAdClosed('%s')", previewInterstitialAdId))
                webviewEventCallback.postValue(String.format("javascript:onAdClosed('%s')", previewInterstitialAdId))
                previewInterstitialAdId = ""
            }
            Log.d(TAG, "onInterstitialAdClosed")
        }

        override fun onInterstitialAdFailedToShow(p0: String?, p1: AdiscopeError?) {
            Log.d(TAG, "onInterstitialAdFailedToShow ${p0.toString()} // ${p1.toString()}")
        }

    }

    fun loadRv(unitId: String) {
        Log.d(TAG, "loadRv: $unitId")
        try {
            if (!rewardedVideoAd.isLoaded(unitId)) {
                rewardedVideoAd.load(unitId)
            } else {
                rewardedVideoAd.load(unitId)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun loadInterstitial(unitId: String) {
        Log.d(TAG, "loadInterstitial: $unitId")
        try {
            if (!interstitialAd.isLoaded(unitId)) {
                interstitialAd.load(unitId)
            } else {
                interstitialAd.load(unitId)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun interstitialAdLoaded(preUnitId: String): Boolean {
        return interstitialAd.isLoaded(preUnitId)
    }

    fun showInterstitial() {
        interstitialAd.show()
    }

    fun showRv(preUnitId: String) {
        if (rewardedVideoAd.isLoaded(preUnitId)) {
            rewardedVideoAd.show()
            Log.d(TAG, "showVideoAd")
        } else {
            Log.d(TAG, "VideoAd is not loaded")
        }
    }

    companion object {
        const val TAG: String = "LotteryViewModel"
    }
//
//        fun <T> create(
//            activity: T
//        ): AbstractSavedStateViewModelFactory where T : Activity, T : SavedStateRegistryOwner {
//            // java.lang.IllegalArgumentException: SavedStateProvider with the given key is already registered
//            if (activity.intent.extras == null) {
//                Log.w(TAG, "Activity intent extras is null, using empty Bundle")
//                activity.intent.putExtra("defaultArgs", Bundle())
//            }
//            ViewModelProvider(activity, provideFactory(activity.application, activity, activity.intent.extras))
//            return provideFactory(activity.application, activity, activity.intent.extras)
//        }
//
//        fun provideFactory(
//            application: Application,
//            owner: SavedStateRegistryOwner,
//            defaultArgs: Bundle? = null,
//        ): AbstractSavedStateViewModelFactory =
//            object : AbstractSavedStateViewModelFactory(owner, defaultArgs) {
//                @Suppress("UNCHECKED_CAST")
//                override fun <T : ViewModel> create(
//                    key: String,
//                    modelClass: Class<T>,
//                    handle: SavedStateHandle
//                ): T {
//                    return LotteryViewModel(application, defaultArgs) as T
//                }
//            }
//    }
}
