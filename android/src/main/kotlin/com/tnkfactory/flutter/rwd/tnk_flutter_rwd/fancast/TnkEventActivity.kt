package com.tnkfactory.flutter.rwd.tnk_flutter_rwd.fancast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.tnkfactory.ad.fancast.R
import com.tnkfactory.ad.fancast.TnkEventFragment

class TnkEventActivity : AppCompatActivity() {
    private val TAG = javaClass.simpleName

    companion object {
        fun startActivity(context: Context) {
            val intent = Intent(context, TnkEventActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.com_tnk_activity_test)
        enableEdgeToEdge()
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.cl_main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        initView()

    }

    private fun initView() {
        val fragmentManager = supportFragmentManager
        val fragmentTransaction = fragmentManager.beginTransaction()
        val fragment = TnkEventFragment.Companion.showWebviewFragment(typeCode = "golfzone")
        fragmentTransaction.add(R.id.fl_fragment, fragment)
        fragmentTransaction.commit()
    }

}
