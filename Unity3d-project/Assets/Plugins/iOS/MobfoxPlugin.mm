#import <UIKit/UIKit.h>
#import <MobFox/MobFox.h>
#define BANNER_LEFT_TOP 0
#define BANNER_CENTER_TOP 1
#define BANNER_RIGHT_TOP 2
#define BANNER_LEFT_BOTTOM 3
#define BANNER_CENTER_BOTTOM 4
#define BANNER_RIGHT_BOTTOM 5
extern UIViewController *UnityGetGLViewController();
extern "C" void UnitySendMessage(const char *, const char *, const char *);

@interface MobfoxPlugin : NSObject<MobFoxBannerViewDelegate, MobFoxVideoInterstitialViewControllerDelegate>
{
	UIView *unityView;
	NSString *gameObject;
	NSString *publisherId;
	int currentPositionCode;
}
@property (strong, nonatomic) MobFoxBannerView *bannerView;
@property (nonatomic, strong) MobFoxVideoInterstitialViewController *videoInterstitialViewController;
@end

@implementation MobfoxPlugin

- (id)initWithPublisherId:(const char *)publisherId_
{
	self = [super init];
	publisherId = [[NSString stringWithUTF8String:publisherId_] retain];
    //publisherId = @"fe96717d9875b9da4339ea5367eff1ec";	// Test publisher id
	
	if (unityView == NULL) {
		unityView = UnityGetGLViewController().view;
	}
    
    
    // Create, add Interstitial/Video Ad View Controller and add view to view hierarchy
    self.videoInterstitialViewController = [[MobFoxVideoInterstitialViewController alloc] init];
    
    // Assign delegate
    self.videoInterstitialViewController.delegate = self;
    
    // Add view. Note when it is created is transparent, with alpha = 0.0 and hidden
    // Only when an ad is being presented it become visible
    [unityView addSubview:self.videoInterstitialViewController.view];
    
    NSLog(@"MobFox plugin - initialized publisherId: %@", publisherId);
	return self;
}

- (void)dealloc
{
    self.videoInterstitialViewController.delegate = nil;
    [self.videoInterstitialViewController.view removeFromSuperview];
    [self.videoInterstitialViewController.view release];
    [self.videoInterstitialViewController release];
    self.videoInterstitialViewController = NULL;
    
    self.bannerView.delegate = nil;
	[self.bannerView removeFromSuperview];
	[self.bannerView release];
    self.bannerView = NULL;
    
	[gameObject release];
	[publisherId release];
	[super dealloc];
}

- (void)SetCallbackGameObject:(const char *)gameObject_
{
	gameObject = [[NSString stringWithUTF8String:gameObject_] retain];
}

- (void)ShowInterstitial
{
	if (self.videoInterstitialViewController != NULL) {
		self.videoInterstitialViewController.requestURL = @"http://my.mobfox.com/request.php";
		[self.videoInterstitialViewController requestAd];
    }
}

- (void)AddBanner:(int)width height:(int)height strict:(BOOL)strict
{
    NSLog(@"MobFox plugin - adding banner width: %d height: %d", width, height);
	if ((self.bannerView != NULL && self.bannerView != nil) || unityView == NULL) {
		return;
	}
    
	self.bannerView = [[MobFoxBannerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	self.bannerView.allowDelegateAssigmentToRequestAd = NO; //use this if you don't want to trigger ad loading when setting delegate and intend to request it it manually
	self.bannerView.delegate = self;
	[unityView addSubview:self.bannerView];
	self.bannerView.requestURL = @"http://my.mobfox.com/request.php"; // Do Not Change this
	self.bannerView.adspaceWidth = width; // Optional, used to set the custom size of the banner placement. Without setting it, the Server will revert to default sizes (320x50 for iPhone, 728x90 for iPad).
	self.bannerView.adspaceHeight = height;
	self.bannerView.adspaceStrict = strict; // Optional, tells the server to only supply ads that are exactly of the desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
	[self.bannerView requestAd]; // Request a Banner Ad manually
    
	[self SetBannerPosition:currentPositionCode];
}

- (void)RemoveBanner
{
    NSLog(@"MobFox plugin - removing banner");
	if (self.bannerView == NULL || self.bannerView == nil) {
		return;
	}
    
    self.bannerView.delegate = nil;
	[self.bannerView removeFromSuperview];
	[self.bannerView release];
    self.bannerView = NULL;
}

- (void)SetBannerSize:(int)width height:(int)height strict:(BOOL)strict
{
    NSLog(@"MobFox plugin - setting banner size");
	if (self.bannerView == NULL || self.bannerView == nil) {
		return;
	}
    
	self.bannerView.adspaceWidth = width; // Optional, used to set the custom size of the banner placement. Without setting it, the Server will revert to default sizes (320x50 for iPhone, 728x90 for iPad).
	self.bannerView.adspaceHeight = height;
	self.bannerView.adspaceStrict = strict; // Optional, tells the server to only supply ads that are exactly of the desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
	
	[self SetBannerPosition:currentPositionCode];
}

- (void)SetBannerPosition:(int)positionCode
{
    NSLog(@"MobFox plugin - setting banner position: %d", positionCode);
    //	CGFloat scale = 1.0f / view.contentScaleFactor;
	CGRect frame = self.bannerView.frame;
	CGRect screen = unityView.bounds;
	currentPositionCode = positionCode;
	switch (positionCode) {
        case BANNER_LEFT_TOP:
            frame.origin.x = 0;
            frame.origin.y = 0;
            break;
        case BANNER_CENTER_TOP:
            frame.origin.x = (screen.size.width - frame.size.width) / 2;
            frame.origin.y = 0;
            break;
        case BANNER_RIGHT_TOP:
            frame.origin.x = screen.size.width - frame.size.width;
            frame.origin.y = 0;
            break;
        case BANNER_LEFT_BOTTOM:
            frame.origin.x = 0;
            frame.origin.y = screen.size.height - frame.size.height;
            break;
        case BANNER_CENTER_BOTTOM:
            frame.origin.x = (screen.size.width - frame.size.width) / 2;
            frame.origin.y = screen.size.height - frame.size.height;
            break;
        case BANNER_RIGHT_BOTTOM:
            frame.origin.x = screen.size.width - frame.size.width;
            frame.origin.y = screen.size.height - frame.size.height;
            break;
	}
	self.bannerView.frame = frame;
}

- (void)SetInterstitialAdsEnabled:(BOOL)b
{
	if (self.videoInterstitialViewController == NULL || self.videoInterstitialViewController == nil) {
		return;
	}
	self.videoInterstitialViewController.enableInterstitialAds = b;
}

- (void)SetVideoAdsEnabled:(BOOL)b
{
	if (self.videoInterstitialViewController == NULL || self.videoInterstitialViewController == nil) {
		return;
	}
	self.videoInterstitialViewController.enableVideoAds = b;
}

- (void)SetPrioritizeVideoAds:(BOOL)b
{
	if (self.videoInterstitialViewController == NULL || self.videoInterstitialViewController == nil) {
		return;
	}
	self.videoInterstitialViewController.prioritizeVideoAds = b;
}

- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner // Set the Publisher ID (mandatory)
{
    return publisherId;
}

- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    return publisherId;
}

// Called if an Ad has been successfully retrieved and displayed the first time. Not called when an adView receives a "refreshed" Ad.
- (void)mobfoxBannerViewDidLoadMobFoxAd:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewDidLoadMobFoxAd called.");
}

// Called if an existing Ad view receives a "refreshed" Ad.
- (void)mobfoxBannerViewDidLoadRefreshedAd:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewDidLoadRefreshedAd called.");
}

//Called if no banner is available or there is an error.
- (void)mobfoxBannerView:(MobFoxBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"mobfoxBannerView called error: %@", error);
}

// Called when user taps on a banner
- (BOOL)mobfoxBannerViewActionShouldBegin:(MobFoxBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"mobfoxBannerViewActionShouldBegin called.");
	return false;
}

// Called when the modal web view will be displayed
- (void)mobfoxBannerViewActionWillPresent:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewActionWillPresent called.");
}

// Called when the modal web view is about to be cancelled
// Restart any foreground activities paused as part of mobfoxBannerViewActionWillPresent.
- (void)mobfoxBannerViewActionWillFinish:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewActionWillFinish called.");
}

// Called when the modal web view is cancelled and the user is returning to the app.
- (void)mobfoxBannerViewActionDidFinish:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewActionDidFinish called.");
}

// Called when a user tap results in Application Switching.
- (void)mobfoxBannerViewActionWillLeaveApplication:(MobFoxBannerView *)banner
{
    NSLog(@"mobfoxBannerViewActionWillLeaveApplication called.");
}

// Called if an Ad has been successfully retrieved and is ready to be displayed via - (void)presentAd(MobFoxAdType)advertType
- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType
{
    NSLog(@"mobfoxVideoInterstitialViewDidLoadMobFoxAd called.");
}

// Called if no Video/Interstitial is available or there was an error.
- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"mobfoxVideoInterstitialView called.");
}

// Sent immediately before Video/Interstitial is shown to the user. At this point pause any animations, timers or other activities that assume user interaction and save app state, much like on UIApplicationDidEnterBackgroundNotification. Remember that the user may press Home or touch links to other apps like AppStore or iTunes within the interstitial, thus leaving your app.
- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"mobfoxVideoInterstitialViewActionWillPresentScreen called.");
}

// Sent immediately before interstitial leaves the screen. At this point restart any foreground activities paused as part of interstitialWillPresentScreen.
- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"mobfoxVideoInterstitialViewWillDismissScreen called.");
}

// Sent when the user has dismissed interstitial and it has left the screen.
- (void)mobfoxVideoInterstitialViewDidDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"mobfoxVideoInterstitialViewDidDismissScreen called.");
}

// Called when a user tap results in Application Switching.
- (void)mobfoxVideoInterstitialViewActionWillLeaveApplication:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"mobfoxVideoInterstitialViewActionWillLeaveApplication called.");
}
@end

extern "C" {
	void *_MobfoxPlugin_Init(const char *publisherId);
	void _MobfoxPlugin_SetCallbackGameObject(void *instance, const char *gameObject);
	void _MobfoxPlugin_ShowInterstitial(void *instance);
	void _MobfoxPlugin_AddBanner(void *instance, int width, int height, bool strict);
	void _MobfoxPlugin_RemoveBanner(void *instance);
	void _MobfoxPlugin_SetBannerSize(void *instance, int width, int height, bool strict);
	void _MobfoxPlugin_SetBannerPosition(void *instance, int positionCode);
	void _MobfoxPlugin_SetInterstitialAdsEnabled(void *instance, bool b);
	void _MobfoxPlugin_SetVideoAdsEnabled(void *instance, bool b);
	void _MobfoxPlugin_SetPrioritizeVideoAds(void *instance, bool b);
	void _MobfoxPlugin_Destroy(void *instance);
}

void *_MobfoxPlugin_Init(const char *publisherId)
{
	id instance = [[MobfoxPlugin alloc] initWithPublisherId:publisherId];
	return (void *)instance;
}

void _MobfoxPlugin_SetCallbackGameObject(void *instance, const char *gameObject)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetCallbackGameObject:gameObject];
}

void _MobfoxPlugin_ShowInterstitial(void *instance)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p ShowInterstitial];
}

void _MobfoxPlugin_AddBanner(void *instance, int width, int height, bool strict)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p AddBanner:width height:height strict:strict];
}

void _MobfoxPlugin_RemoveBanner(void *instance)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p RemoveBanner];
}

void _MobfoxPlugin_SetBannerSize(void *instance, int width, int height, bool strict)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetBannerSize:width height:height strict:strict];
}

void _MobfoxPlugin_SetBannerPosition(void *instance, int positionCode)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetBannerPosition:positionCode];
}

void _MobfoxPlugin_SetInterstitialAdsEnabled(void *instance, bool b)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetInterstitialAdsEnabled:b];
}

void _MobfoxPlugin_SetVideoAdsEnabled(void *instance, bool b)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetVideoAdsEnabled:b];
}

void _MobfoxPlugin_SetPrioritizeVideoAds(void *instance, bool b)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p SetPrioritizeVideoAds:b];
}

void _MobfoxPlugin_Destroy(void *instance)
{
	MobfoxPlugin *p = (MobfoxPlugin *)instance;
	[p release];
}
