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

#define TGSDK_EVENT_PRELOAD_SUCCESS "TGSDK_onPreloadSuccess"
#define TGSDK_EVENT_PRELOAD_FAILED  "TGSDK_onPreloadFailed"
#define TGSDK_EVENT_CPAD_LOADED     "TGSDK_onCPADLoaded"
#define TGSDK_EVENT_VIDEOAD_LOADED  "TGSDK_onVideoADLoaded"

#define TGSDK_EVENT_AD_SHOW_SUCCESS "TGSDK_onShowSuccess"
#define TGSDK_EVENT_AD_SHOW_FAILED  "TGSDK_onShowFailed"
#define TGSDK_EVENT_AD_COMPLETE     "TGSDK_onADComplete"
#define TGSDK_EVENT_AD_CLICK        "TGSDK_onADClick"
#define TGSDK_EVENT_AD_CLOSE        "TGSDK_onADClose"

#define TGSDK_EVENT_REWARD_SUCCESS "TGSDK_onADAwardSuccess"
#define TGSDK_EVENT_REWARD_FAILED  "TGSDK_onADAwardFailed"

#include "cocos2d.h"

namespace yomob {
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
        virtual void onCPADLoaded(const std::string ret){};
        virtual void onVideoADLoaded(const std::string ret){};
    };

    class TGSDKCocos2dxADDelegate {
    public:
        virtual void onShowSuccess(const std::string ret){};
        virtual void onShowFailed(const std::string ret){};
        virtual void onADComplete(const std::string ret){};
        virtual void onADClick(const std::string ret){};
        virtual void onADClose(const std::string ret){};
    };

    class TGSDKCocos2dxRewardDelegate {
    public:
        virtual void onADAwardSuccess(const std::string ret){};
        virtual void onADAwardFailed(const std::string ret){};
    };
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
        
        static bool couldShowAd(const std::string scene);
        static void showAd(const std::string scene);
        static void showTestView(const std::string scene);

        static void reportAdRejected(const std::string scene);
        static void showAdScene(const std::string scene);

        static void sendCounter(const std::string name, const std::string metaData);

#ifdef TGSDK_COCOS2DX_2X
        static void setSDKDelegate(TGSDKCocos2dxSDKDelegate *delegate);
        static void setPreloadDelegate(TGSDKCocos2dxPreloadDelegate *delegate);
        static void setADDelegate(TGSDKCocos2dxADDelegate *delegate);
        static void setRewardDelegate(TGSDKCocos2dxRewardDelegate *delegate);
#endif
        
        static void handleEvent(const std::string event, const std::string result);
        
        static void bindScript(void);
    };
};


#endif /* TGSDKCocos2dxHelper_h */
