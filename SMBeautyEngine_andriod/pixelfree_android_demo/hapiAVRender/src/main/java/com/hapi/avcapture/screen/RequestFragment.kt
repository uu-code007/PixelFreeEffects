package com.hapi.avcapture.screen;

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.Fragment

class RequestFragment: Fragment() {

    var call:((requestCode: Int, resultCode: Int, data: Intent?) ->Unit)? = {_, _, _ ->  }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        call?.invoke(requestCode, resultCode, data)
        call=null
    }
}