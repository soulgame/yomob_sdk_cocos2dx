//
//  TGSDKCocos2dxHelper.h
//  tgsdk_cocos_js
//
//  Created by yomob on 2016/12/15.
//
//

#ifndef TGSDKCocos2dxHelper_h
#define TGSDKCocos2dxHelper_h

// Custom Event
#define TGSDK_EVENT_INIT_SUCCESS "TGSDK_onInitSuccess"
#define TGSDK_EVENT_INIT_FAILED  "TGSDK_onInitFailed"

#define TGSDK_EVENT_PRELOAD_SUCCESS           "TGSDK_onPreloadSuccess"
#define TGSDK_EVENT_PRELOAD_FAILED            "TGSDK_onPreloadFailed"
// #define TGSDK_EVENT_CPAD_LOADED               "TGSDK_onCPADLoaded"  // Deprecated
// #define TGSDK_EVENT_VIDEOAD_LOADED            "TGSDK_onVideoADLoaded"  // Deprecated

// From 1.8.3
#define TGSDK_EVENT_AWARD_VIDEO_LOADED        "TGSDK_onAwardVideoLoaded"
#define TGSDK_EVENT_INTERSTITIAL_LOADED       "TGSDK_onInterstitialLoaded"
#define TGSDK_EVENT_INTERSTITIAL_VIDEO_LOADED "TGSDK_onInterstitialVideoLoaded"

// Deprecated
// #define TGSDK_EVENT_AD_SHOW_SUCCESS "TGSDK_onShowSuccess"
// Deprecated
// #define TGSDK_EVENT_AD_SHOW_FAILED  "TGSDK_onShowFailed"
// Deprecated
// #define TGSDK_EVENT_AD_COMPLETE     "TGSDK_onADComplete"
// Deprecated
// #define TGSDK_EVENT_AD_CLICK        "TGSDK_onADClick"
// Deprecated
// #define TGSDK_EVENT_AD_CLOSE        "TGSDK_onADClose"

// From 1.8.3
#define TGSDK_EVENT_ON_AD_SHOW_SUCCESS "TGSDK_onADShowSuccess"
#define TGSDK_EVENT_ON_AD_SHOW_FAILED  "TGSDK_onADShowFailed"
#define TGSDK_EVENT_ON_AD_CLICK        "TGSDK_onADClicked"
#define TGSDK_EVENT_ON_AD_CLOSE        "TGSDK_onADClosed"

// Deprecated
// #define TGSDK_EVENT_REWARD_SUCCESS "TGSDK_onADAwardSuccess"
// #define TGSDK_EVENT_REWARD_FAILED  "TGSDK_onADAwardFailed"

// Deprecated
// #define TGSDK_EVENT_BANNER_LOADED  "TGSDK_onBannerLoaded"
// #define TGSDK_EVENT_BANNER_FAILED  "TGSDK_onBannerFailed"
// #define TGSDK_EVENT_BANNER_CLICK   "TGSDK_onBannerClick"
// #define TGSDK_EVENT_BANNER_CLOSE   "TGSDK_onBannerClose"

#define TGPAYINGUSER_NON_PAYING_USER     "TGSDK_NON_PAYING_USER"
#define TGPAYINGUSER_SMALL_PAYMENT_USER  "TGSDK_SMALL_PAYMENT_USER"
#define TGPAYINGUSER_MEDIUM_PAYMENT_USER "TGSDK_MEDIUM_PAYMENT_USER"
#define TGPAYINGUSER_LARGE_PAYMENT_USER  "TGSDK_LARGE_PAYMENT_USER"

#define TGSDK_BANNER_TYPE_NORMAL "TGBannerNormal"
#define TGSDK_BANNER_TYPE_MEDIUM "TGBannerMediumRectangle"
#define TGSDK_BANNER_TYPE_LARGE  "TGBannerLarge"

#include "cocos2d.h"

namespace yomob {
    typedef enum {
        TGSDKCocos2dxNonPayingUser,
        TGSDKCocos2dxSmallPaymentUser,
        TGSDKCocos2dxMediumPaymentUser,
        TGSDKCocos2dxLargePaymentUser
    } TGSDKCocosedxPayingUser;
#ifdef TGSDK_COCOS2DX_2X
    class TGSDKCocos2dxSDKDelegate {
    public:
        virtual void onInitSuccess(const std::string ret){};
        virtual void onInitFailed(const std::string ret){};
    };

    class TGSDKCocos2dxPreloadDelegate {
    public:
        virtual void onPreloadSuccess(const std::string ret){};
        virtual void onPreloadFailed(const std::string ret){};
        // virtual void onCPADLoaded(const std::string ret){};  // Deprecated
        // virtual void onVideoADLoaded(const std::string ret){};  // Deprecated
        // From 1.8.3
        virtual void onAwardVideoLoaded(const std::string ret){};
        virtual void onInterstitialLoaded(const std::string ret){};
        virtual void onInterstitialVideoLoaded(const std::string ret){};
    };

    class TGSDKCocos2dxADDelegate {
    public:
        // virtual void onShowSuccess(const std::string ret){};  // Deprecated
        // virtual void onShowFailed(const std::string ret){};  // Deprecated
        // virtual void onADComplete(const std::string ret){};  // Deprecated
        // virtual void onADClick(const std::string ret){};  // Deprecated
        // virtual void onADClose(const std::string ret){};  // Deprecated
        virtual void onShowSuccess(const std::string scene, const std::string ret){};
        virtual void onShowFailed(const std::string scene, const std::string ret, const std:string error){};
        virtual void onADClick(const std::string scene, const std::string ret){};
        virtual void onADClose(const std::string scene, const std::string ret, const bool award){};
    };

    // Deprecated
    // class TGSDKCocos2dxRewardDelegate {
    // public:
    //     virtual void onADAwardSuccess(const std::string ret){};  // Deprecated
    //     virtual void onADAwardFailed(const std::string ret){};  // Deprecated
    // };

    // // Deprecated
    // class TGSDKCocos2dxBannerDelegate {
    // public:
    //     virtual void onBannerLoaded(const std::string scene, const std::string ret){};
    //     virtual void onBannerFailed(const std::string scene, const std::string ret const std::string error){};
    //     virtual void onBannerClick(const std::string scene, const std::string ret){};
    //     virtual void onBannerClose(const std::string scene, const std::string ret){};
    // }
#endif
    class TGSDKCocos2dxHelper {
    public:
        static void setDebugModel(bool debug);
        
        static void setSDKConfig(const std::string key, const std::string val);
        static std::string getSDKConfig(const std::string key);
        
        static void initialize(void);
        static void initialize(const std::string appid);
        static void initialize(const std::string appid, const std::string channelid);
        
        static int isWIFI();

        static void preload();

        static int getIntParameterFromAdScene(const std::string scene, const std::string key, int def = 0);
        static float getFloatParameterFromAdScene(const std::string scene, const std::string key, float def = 0);
        static std::string getStringParameterFromAdScene(const std::string scene, const std::string key, const std::string def = "");
        static void setBannerConfig(const std::string scene, const std::string type, float x, float y, float width, float height, int interval);
        
        static bool couldShowAd(const std::string scene);
        static void showAd(const std::string scene);
        static void showTestView(const std::string scene);
        static void closeBanner(const std::string scene);

        static void reportAdRejected(const std::string scene);
        static void showAdScene(const std::string scene);

        static void sendCounter(const std::string name, const std::string metaData);

        static void tagPayingUser(yomob::TGSDKCocosedxPayingUser user, const std::string currency, float currentAmount, float totalAmount);

        static std::string getUserGDPRConsentStatus();
        static void setUserGDPRConsentStatus(const std::string status);

        static std::string getIsAgeRestrictedUser();
        static void setIsAgeRestrictedUser(const std::string status);

#ifdef TGSDK_COCOS2DX_2X
        static void setSDKDelegate(TGSDKCocos2dxSDKDelegate *delegate);
        static void setPreloadDelegate(TGSDKCocos2dxPreloadDelegate *delegate);
        static void setADDelegate(TGSDKCocos2dxADDelegate *delegate);
        static void setRewardDelegate(TGSDKCocos2dxRewardDelegate *delegate);
        static void setBannerDelegate(TGSDKCocos2dxBannerDelegate *delegate);
#endif
        
        static void handleEvent(const std::string event, const std::string result);
        
        static void bindScript(void);
    };
};


#endif /* TGSDKCocos2dxHelper_h */
