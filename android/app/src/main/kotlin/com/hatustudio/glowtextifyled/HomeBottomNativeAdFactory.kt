package com.hatustudio.glowtextifyled

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class HomeBottomNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.home_bottom_native_ad, null) as NativeAdView

        val iconView = adView.findViewById<ImageView>(R.id.native_ad_icon)
        val headlineView = adView.findViewById<TextView>(R.id.native_ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.native_ad_body)
        val starsView = adView.findViewById<RatingBar>(R.id.native_ad_stars)
        val mediaView = adView.findViewById<MediaView>(R.id.native_ad_media)
        val ctaView = adView.findViewById<Button>(R.id.native_ad_cta)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        adView.bodyView = bodyView

        val icon = nativeAd.icon
        if (icon != null) {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        val rating = nativeAd.starRating
        if (rating != null) {
            starsView.rating = rating.toFloat()
            starsView.visibility = View.VISIBLE
        } else {
            starsView.visibility = View.GONE
        }
        adView.starRatingView = starsView

        adView.mediaView = mediaView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        adView.callToActionView = ctaView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
