package com.tnkfactory.flutter.rwd.tnk_flutter_rwd_example

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatDelegate
import androidx.fragment.app.FragmentActivity
import com.tnkfactory.ad.TnkContext
import com.tnkfactory.ad.TnkOfferwall
import com.tnkfactory.ad.TnkSession
import com.tnkfactory.ad.TnkWebEventActivity
import com.tnkfactory.ad.off.AdEventHandler
import com.tnkfactory.ad.rwd.TnkCore
import com.tnkfactory.ad.tnk_rwd.TnkAdManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        TnkAdManager.setCustomClass()
        val isPrivacyAgree = TnkSession.getAgreePrivacy(this@MainActivity)
        Log.d("jameson", "isPrivacyAgree: $isPrivacyAgree")
//        TnkOfferwall(this)

        var tnkContext: TnkContext? = null

        var mEventHandler: AdEventHandler? = null

        if (!TnkCore.isInitialized())
            TnkCore.init(this)
        if (this is FragmentActivity) {
            tnkContext = TnkContext(this)
            mEventHandler = AdEventHandler(this)
            Log.d("tnk", "is FragmentActivity")
        }else{
            Log.d("tnk", "not FragmentActivity")
        }

    }
}
