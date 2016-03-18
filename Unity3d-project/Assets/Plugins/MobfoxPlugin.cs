using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class MobfoxPlugin {
	public enum PositionCode {
		BANNER_LEFT_TOP = 0,
		BANNER_CENTER_TOP = 1,
		BANNER_RIGHT_TOP = 2,
		BANNER_LEFT_BOTTOM = 3,
		BANNER_CENTER_BOTTOM = 4,
		BANNER_RIGHT_BOTTOM = 5
	}

#if UNITY_IPHONE
	private static IntPtr mobFoxObj;
#elif UNITY_ANDROID
	private static AndroidJavaObject mobFoxObj;
#endif

#if UNITY_IPHONE
	[DllImport("__Internal")]
	private static extern IntPtr _MobfoxPlugin_Init(string publisherId);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetCallbackGameObject(IntPtr instance, string gameObject);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_ShowInterstitial(IntPtr instance);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_AddBanner(IntPtr instance, int width, int height, bool strict);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_RemoveBanner(IntPtr instance);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetBannerSize(IntPtr instance, int width, int height, bool strict);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetBannerPosition(IntPtr instance, int positionCode);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetInterstitialAdsEnabled(IntPtr instance, bool b);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetVideoAdsEnabled(IntPtr instance, bool b);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_SetPrioritizeVideoAds(IntPtr instance, bool b);
	[DllImport("__Internal")]
	private static extern void _MobfoxPlugin_Destroy(IntPtr instance);
	#endif

	public static void Init(String publisherId)
	{
#if UNITY_IPHONE
		mobFoxObj = _MobfoxPlugin_Init(publisherId);
#elif UNITY_ANDROID
		mobFoxObj = new AndroidJavaObject("com.insthync.mobfox.MobfoxPlugin");
		mobFoxObj.Call("Init", publisherId);
#endif
	}

	public static void SetCallback(MobfoxPluginCallback callback)
	{
		if (callback == null || callback.gameObject == null)
			return;

		string gameObj = callback.gameObject.name;
#if UNITY_IPHONE
		_MobfoxPlugin_SetCallbackGameObject(mobFoxObj, gameObj);
#elif UNITY_ANDROID
		mobFoxObj = new AndroidJavaObject("com.insthync.mobfox.MobfoxPlugin");
		mobFoxObj.Call("SetCallbackGameObject", gameObj);
#endif
	}

	public static void ShowInterstitial()
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_ShowInterstitial(mobFoxObj);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("ShowInterstitial");
#endif
	}

	public static void AddBanner(int width, int height, bool strict)
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_AddBanner(mobFoxObj, width, height, strict);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("AddBanner", width, height, strict);
#endif
	}

	public static void RemoveBanner()
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_RemoveBanner(mobFoxObj);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("RemoveBanner");
#endif
	}

	public static void SetBannerSize(int width, int height, bool strict)
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_SetBannerSize(mobFoxObj, width, height, strict);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("SetBannerSize", width, height, strict);
#endif
	}

	public static void SetBannerPosition(PositionCode positionCode)
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_SetBannerPosition(mobFoxObj, (int)positionCode);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("SetBannerPosition", (int)positionCode);
#endif
	}

	public static void SetInterstitialAdsEnabled(bool b) {
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_SetInterstitialAdsEnabled(mobFoxObj, b);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("SetInterstitialAdsEnabled", b);
#endif
	}

	public static void SetVideoAdsEnabled(bool b) {
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_SetVideoAdsEnabled(mobFoxObj, b);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("SetVideoAdsEnabled", b);
#endif
	}

	public static void SetPrioritizeVideoAds(bool b) {
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_SetPrioritizeVideoAds(mobFoxObj, b);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("SetPrioritizeVideoAds", b);
#endif
	}

	public static void Destroy()
	{
#if UNITY_IPHONE
		if (mobFoxObj == IntPtr.Zero)
			return;
		_MobfoxPlugin_Destroy(mobFoxObj);
#elif UNITY_ANDROID
		if (mobFoxObj == null)
			return;
		mobFoxObj.Call("Destroy");
#endif
	}
}
