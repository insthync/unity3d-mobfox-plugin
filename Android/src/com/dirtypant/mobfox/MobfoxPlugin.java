package com.dirtypant.mobfox;

import android.app.Activity;
import android.util.Log;
import android.widget.RelativeLayout;

import com.adsdk.sdk.Ad;
import com.adsdk.sdk.AdListener;
import com.adsdk.sdk.AdManager;
import com.adsdk.sdk.banner.AdView;
import com.unity3d.player.UnityPlayer;

public class MobfoxPlugin implements AdListener {
	public final int BANNER_LEFT_TOP = 0;
	public final int BANNER_CENTER_TOP = 1;
	public final int BANNER_RIGHT_TOP = 2;
	public final int BANNER_LEFT_BOTTOM = 3;
	public final int BANNER_CENTER_BOTTOM = 4;
	public final int BANNER_RIGHT_BOTTOM = 5;
	private String gameObject ;
	private String publisherId;
	private RelativeLayout mLayout = null;
	private AdManager mManager = null;
	private AdView mAdView = null;
	public void Init(final String publisherId) {
		this.publisherId = publisherId;
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			@SuppressWarnings("deprecation")
			public void run() {
				if (mLayout == null) {
					mLayout = new RelativeLayout(a);
					a.addContentView(mLayout, new RelativeLayout.LayoutParams(
							RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT));
					mLayout.setFocusable(true);
					mLayout.setFocusableInTouchMode(true);
				}
				
				if (mManager == null) {
					mManager = new AdManager(a,"http://my.mobfox.com/request.php", publisherId, true);
					mManager.setInterstitialAdsEnabled(true); //enabled by default. Allows the SDK to request static interstitial ads.
					mManager.setVideoAdsEnabled(true); //disabled by default. Allows the SDK to request video fullscreen ads.
					mManager.setPrioritizeVideoAds(true); //disabled by default. If enabled, indicates that SDK should request video ads first, and only if there is no video request a static interstitial (if they are enabled).
				}
			}
		});
	}
	
	public void Destroy() {
		Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mAdView != null)
					mAdView.release();
				
				if (mManager != null)
					mManager.release();
			}
		});
	}
	
	public void SetCallbackGameObject(String gameObject) {
		this.gameObject = gameObject;
	}
	
	public void ShowInterstitial() {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mManager != null)
				{
					mManager.requestAd();
				}
			}
		});
	}
	
	public void AddBanner(final int width, final int height, final boolean strict) {
		if (mAdView != null || mLayout == null)
		{
			return;
		}
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				mAdView = new AdView(a, "http://my.mobfox.com/request.php", publisherId, true, true);
				mAdView.setAdspaceWidth(width); // Optional, used to set the custom size of banner placement. Without setting it, the SDK will use default size of 320x50 or 300x50 depending on device type.
				mAdView.setAdspaceHeight(height);  
				mAdView.setAdspaceStrict(strict); // Optional, tells the server to only supply banner ads that are exactly of the desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
				mAdView.setAdListener(MobfoxPlugin.this);
				mLayout.addView(mAdView);
			}
		});
	}
	
	public void RemoveBanner() {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mAdView != null)
				{
					mLayout.removeView(mAdView);
					mAdView = null;
				}
			}
		});
	}
	
	public void SetBannerSize(final int width, final int height, final boolean strict) {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mAdView != null)
				{
					mAdView.setAdspaceWidth(width); // Optional, used to set the custom size of banner placement. Without setting it, the SDK will use default size of 320x50 or 300x50 depending on device type.
					mAdView.setAdspaceHeight(height);  
					mAdView.setAdspaceStrict(strict); // Optional, tells the server to only supply banner ads that are exactly of the desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
				}
			}
		});
	}
	
	public void SetBannerPosition(final int positionCode) {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mLayout == null || mAdView == null)
					return;
				
				RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mAdView.getLayoutParams();

				params.removeRule(RelativeLayout.ALIGN_PARENT_LEFT);
				params.removeRule(RelativeLayout.CENTER_HORIZONTAL);
				params.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
				params.removeRule(RelativeLayout.ALIGN_PARENT_TOP);
				params.removeRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
				switch (positionCode) {
				case BANNER_LEFT_TOP:
					params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
					params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
					break;
				case BANNER_CENTER_TOP:
					params.addRule(RelativeLayout.CENTER_HORIZONTAL);
					params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
					break;
				case BANNER_RIGHT_TOP:
					params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
					params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
					break;
				case BANNER_LEFT_BOTTOM:
					params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
					params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
					break;
				case BANNER_CENTER_BOTTOM:
					params.addRule(RelativeLayout.CENTER_HORIZONTAL);
					params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
					break;
				case BANNER_RIGHT_BOTTOM:
					params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
					params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
					break;
				}
				mAdView.setLayoutParams(params);
			}
		});
	}
	
	public void SetInterstitialAdsEnabled(final boolean is) {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mManager != null)
				{
					mManager.setInterstitialAdsEnabled(is);
				}
			}
		});
	}
	
	public void SetVideoAdsEnabled(final boolean is) {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mManager != null)
				{
					mManager.setVideoAdsEnabled(is);
				}
			}
		});
	}
	
	public void SetPrioritizeVideoAds(final boolean is) {
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (mManager != null)
				{
					mManager.setPrioritizeVideoAds(is);
				}
			}
		});
	}
	
	@Override
	public void adClicked() {
		// TODO Auto-generated method stub
		UnityPlayer.UnitySendMessage(gameObject, "mobfoxMessage", "adClicked");
	}
	@Override
	public void adClosed(Ad arg0, boolean arg1) {
		// TODO Auto-generated method stub
		UnityPlayer.UnitySendMessage(gameObject, "mobfoxMessage", "adClosed");
	}
	@Override
	public void adLoadSucceeded(Ad arg0) {
		// TODO Auto-generated method stub
		UnityPlayer.UnitySendMessage(gameObject, "mobfoxMessage", "adLoadSucceeded");
	}
	@Override
	public void adShown(Ad arg0, boolean arg1) {
		// TODO Auto-generated method stub
		UnityPlayer.UnitySendMessage(gameObject, "mobfoxMessage", "adShown");
	}
	@Override
	public void noAdFound() {
		// TODO Auto-generated method stub
		UnityPlayer.UnitySendMessage(gameObject, "mobfoxMessage", "noAdFound");
	}
}
