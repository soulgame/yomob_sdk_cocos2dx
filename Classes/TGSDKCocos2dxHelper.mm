//
//  TGSDKCocos2dxHelper.cpp
//  tgsdk_cocos_js
//
//  Created by Yomob on 2016/12/15.
//
//

#include "TGSDKCocos2dxHelper.h"

USING_NS_CC;
using namespace yomob;

#define  TGSDK_NONE  "__tgsdk__none__"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <android/log.h>
#define  LOG_TAG    "TGSDK"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  JTGSDKCocos2dxHelper "com/soulgame/sgsdk/tgsdklib/cocos2dx/TGSDKCocos2dxHelper"
#define  JTGSDKClass "com/soulgame/sgsdk/tgsdklib/TGSDK"

// getStringUTFCharsJNI not exists in cocos/base/ccUTF8.h on some old version cocos2d-x engine
std::string __tgsdk_jstring_to_stdstring(JNIEnv* env, jstring srcjStr) {
    std::string utf8Str;
    const unsigned short * unicodeChar = ( const unsigned short *)env->GetStringChars(srcjStr, nullptr);
    size_t unicodeCharLength = env->GetStringLength(srcjStr);
    const std::u16string unicodeStr((const char16_t *)unicodeChar, unicodeCharLength);
    bool flag = cocos2d::StringUtils::UTF16ToUTF8(unicodeStr, utf8Str);

    if (!flag) {
        utf8Str = "";
    }
    env->ReleaseStringChars(srcjStr, unicodeChar);
    return utf8Str;
}

#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "TGSDK.h"
#define LOGD(...) NSLog(@__VA_ARGS__)
#endif

#ifdef TGSDK_BIND_COCOS_CREATOR
#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"
#include "scripting/js-bindings/auto/jsb_cocos2dx_auto.hpp"
#include "scripting/js-bindings/manual/jsb_conversions.hpp"
#include "scripting/js-bindings/manual/jsb_global.h"
#include "cocos/scripting/js-bindings/event/EventDispatcher.h"
#include "platform/CCApplication.h"
#include "base/CCScheduler.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "platform/ios/CCEAGLView-ios.h"
#endif
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#endif

se::Class *jsb_TGSDK_class = nullptr;
se::Object *jsb_TGSDK_prototype = nullptr;

#define JSB_TGSDK_EVENT_PROP(evt) \
static bool jsb_##evt(se::State& s) {\
    s.rval().setString(#evt); \
    return true; \
}\
SE_BIND_PROP_GET(jsb_##evt)

JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_INIT_SUCCESS)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_INIT_FAILED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_PRELOAD_SUCCESS)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_PRELOAD_FAILED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_CPAD_LOADED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_VIDEOAD_LOADED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_AD_SHOW_SUCCESS)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_AD_SHOW_FAILED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_AD_COMPLETE)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_AD_CLICK)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_AD_CLOSE)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_REWARD_SUCCESS)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_REWARD_FAILED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_BANNER_LOADED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_BANNER_FAILED)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_BANNER_CLICK)
JSB_TGSDK_EVENT_PROP(TGSDK_EVENT_BANNER_CLOSE)

JSB_TGSDK_EVENT_PROP(TGPAYINGUSER_NON_PAYING_USER)
JSB_TGSDK_EVENT_PROP(TGPAYINGUSER_SMALL_PAYMENT_USER)
JSB_TGSDK_EVENT_PROP(TGPAYINGUSER_MEDIUM_PAYMENT_USER)
JSB_TGSDK_EVENT_PROP(TGPAYINGUSER_LARGE_PAYMENT_USER)

JSB_TGSDK_EVENT_PROP(TGSDK_BANNER_TYPE_NORMAL)
JSB_TGSDK_EVENT_PROP(TGSDK_BANNER_TYPE_MEDIUM)
JSB_TGSDK_EVENT_PROP(TGSDK_BANNER_TYPE_LARGE)

static bool jsb_TGSDK_function_setDebugModel(se::State& s) {
    LOGD("JSB TGSDK.setDebugModel called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        bool arg0;
        ok &= seval_to_boolean(args[0], &arg0);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setDebugModel: Error processing arguments");
        TGSDKCocos2dxHelper::setDebugModel(arg0);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.setDebugModel: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_setDebugModel)


static bool jsb_TGSDK_function_initialize(se::State& s) {
    LOGD("JSB TGSDK.initialize called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        TGSDKCocos2dxHelper::initialize();
        return true;
    } else if (1 == argc) {
        std::string appid;
        ok &= seval_to_std_string(args[0], &appid);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.initialize: Error processing arguments");
        TGSDKCocos2dxHelper::initialize(appid);
        return true;
    } else if ( 2 <= argc) {
        std::string appid, channelid;
        ok &= seval_to_std_string(args[0], &appid);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.initialize: Error processing arguments");
        ok &= seval_to_std_string(args[1], &channelid);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.initialize: Error processing arguments");
        TGSDKCocos2dxHelper::initialize(appid, channelid);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.initialize: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_initialize)

static bool jsb_TGSDK_function_setSDKConfig(se::State& s) {
    LOGD("JSB TGSDK.setSDKConfig called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 2) {
        std::string key, val;
        ok &= seval_to_std_string(args[0], &key);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setSDKConfig: Error processing arguments");
        ok &= seval_to_std_string(args[1], &val);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setSDKConfig: Error processing arguments");
        TGSDKCocos2dxHelper::setSDKConfig(key, val);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.setSDKConfig: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_setSDKConfig)


static bool jsb_TGSDK_function_getSDKConfig(se::State& s) {
    LOGD("JSB TGSDK.getSDKConfig called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string key, val;
        ok &= seval_to_std_string(args[0], &key);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.getSDKConfig: Error processing arguments");
        val = TGSDKCocos2dxHelper::getSDKConfig(key);
        ok &= std_string_to_seval(val, &s.rval());
        SE_PRECONDITION2(ok, false, "JSB TGSDK.getSDKConfig: Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.getSDKConfig: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_getSDKConfig)


static bool jsb_TGSDK_function_isWIFI(se::State& s) {
    LOGD("JSB TGSDK.isWIFI called");
    CC_UNUSED bool ok = true;
    int ret = TGSDKCocos2dxHelper::isWIFI();
    ok &= int32_to_seval(ret, &s.rval());
    SE_PRECONDITION2(ok, false, "JSB TGSDK.isWIFI: Error processing arguments");
    return true;
}
SE_BIND_FUNC(jsb_TGSDK_function_isWIFI)


static bool jsb_TGSDK_function_preload(se::State& s) {
    LOGD("JSB TGSDK.preload called");
    TGSDKCocos2dxHelper::preload();
    return true;
}
SE_BIND_FUNC(jsb_TGSDK_function_preload)


static bool jsb_TGSDK_function_parameterFromAdScene(se::State& s) {
    LOGD("JSB TGSDK.parameterFromAdScene called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc >= 2) {
        std::string scene, key;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.parameterFromAdScene: Error processing arguments");
        ok &= seval_to_std_string(args[1], &key);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.parameterFromAdScene: Error processing arguments");
        std::string val = TGSDKCocos2dxHelper::getStringParameterFromAdScene(scene, key);
        if (val.compare(TGSDK_NONE) == 0) {
            if (argc > 2) {
                std::string def;
                ok &= seval_to_std_string(args[2], &def);
                SE_PRECONDITION2(ok, false, "JSB TGSDK.parameterFromAdScene: Error processing arguments");
                std_string_to_seval(def, &s.rval());
            }
        }
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.parameterFromAdScene: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_parameterFromAdScene)


static bool jsb_TGSDK_function_setBannerConfig(se::State& s) {
    LOGD("JSB TGSDK.setBannerConfig called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 7) {
        std::string scene, type;
        double x, y, width, height;
        long interval;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_std_string(args[1], &type);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_double(args[2], &x);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_double(args[3], &y);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_double(args[4], &width);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_double(args[5], &height);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        ok &= seval_to_long(args[6], &interval);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setBannerConfig: Error processing arguments");
        TGSDKCocos2dxHelper::setBannerConfig(scene, type, (float)x, (float)y, (float)width, (float)height, (int)interval);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.setBannerConfig: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_setBannerConfig)


static bool jsb_TGSDK_function_couldShowAd(se::State& s) {
    LOGD("JSB TGSDK.couldShowAd called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.couldShowAd: Error processing arguments");
        bool ret = TGSDKCocos2dxHelper::couldShowAd(scene);
        ok &= boolean_to_seval(ret, &s.rval());
        SE_PRECONDITION2(ok, false, "JSB TGSDK.couldShowAd: Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.couldShowAd: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_couldShowAd)


static bool jsb_TGSDK_function_showAd(se::State& s) {
    LOGD("JSB TGSDK.showAd called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.showAd: Error processing arguments");
        TGSDKCocos2dxHelper::showAd(scene);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.showAd: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_showAd)


static bool jsb_TGSDK_function_showTestView(se::State& s) {
    LOGD("JSB TGSDK.showTestView called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.showTestView: Error processing arguments");
        TGSDKCocos2dxHelper::showAd(scene);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.showTestView: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_showTestView)


static bool jsb_TGSDK_function_closeBanner(se::State& s) {
    LOGD("JSB TGSDK.closeBanner called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.closeBanner: Error processing arguments");
        TGSDKCocos2dxHelper::closeBanner(scene);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.closeBanner: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_closeBanner)


static bool jsb_TGSDK_function_reportAdRejected(se::State& s) {
    LOGD("JSB TGSDK.reportAdRejected called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.reportAdRejected: Error processing arguments");
        TGSDKCocos2dxHelper::reportAdRejected(scene);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.reportAdRejected: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_reportAdRejected)


static bool jsb_TGSDK_function_showAdScene(se::State& s) {
    LOGD("JSB TGSDK.showAdScene called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string scene;
        ok &= seval_to_std_string(args[0], &scene);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.showAdScene: Error processing arguments");
        TGSDKCocos2dxHelper::showAdScene(scene);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.showAdScene: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_showAdScene)


static bool jsb_TGSDK_function_sendCounter(se::State& s) {
    LOGD("JSB TGSDK.sendCounter called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 2) {
        std::string counterid, metadata;
        ok &= seval_to_std_string(args[0], &counterid);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.sendCounter: Error processing arguments");
        ok &= seval_to_std_string(args[1], &metadata);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.sendCounter: Error processing arguments");
        TGSDKCocos2dxHelper::sendCounter(counterid, metadata);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.sendCounter: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_sendCounter)


static bool jsb_TGSDK_function_tagPayingUser(se::State& s) {
    LOGD("JSB TGSDK.tagPayingUser called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    std::string payingUser;
    std::string currency = "";
    float currentAmount = 0;
    float totalAmount = 0;
    if (1 <= argc) {
        ok &= seval_to_std_string(args[0], &payingUser);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.tagPayingUser: Error processing arguments");
        if (!ok) {
            return false;
        }
    }
    if (2 <= argc) {
        ok &= seval_to_std_string(args[1], &currency);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.tagPayingUser: Error processing arguments");
        if (!ok) {
            currency = "";
        }
    }
    if (3 <= argc) {
        ok &= seval_to_float(args[2], &currentAmount);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.tagPayingUser: Error processing arguments");
        if (!ok) {
            currentAmount = 0.0;
        }
    }
    if (4 <= argc) {
        ok &= seval_to_float(args[3], &totalAmount);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.tagPayingUser: Error processing arguments");
        if (!ok) {
            totalAmount = 0.0;
        }
    }
    if (payingUser.compare(TGPAYINGUSER_NON_PAYING_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxNonPayingUser,
                                           currency, currentAmount, totalAmount);
        return true;
    } else if (payingUser.compare(TGPAYINGUSER_SMALL_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxSmallPaymentUser,
                                           currency, currentAmount, totalAmount);
        return true;
    } else if (payingUser.compare(TGPAYINGUSER_MEDIUM_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxMediumPaymentUser,
                                           currency, currentAmount, totalAmount);
        return true;
    } else if (payingUser.compare(TGPAYINGUSER_LARGE_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxLargePaymentUser,
                                           currency, currentAmount, totalAmount);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.tagPayingUser: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_tagPayingUser)


static bool jsb_TGSDK_function_getUserGDPRConsentStatus(se::State& s) {
    LOGD("JSB TGSDK.getUserGDPRConsentStatus called");
    std::string ret = TGSDKCocos2dxHelper::getUserGDPRConsentStatus();
    CC_UNUSED bool ok = std_string_to_seval(ret, &s.rval());
    SE_PRECONDITION2(ok, false, "JSB TGSDK.tagPayingUser: Error processing arguments");
    return true;
}
SE_BIND_FUNC(jsb_TGSDK_function_getUserGDPRConsentStatus)


static bool jsb_TGSDK_function_setUserGDPRConsentStatus(se::State& s) {
    LOGD("JSB TGSDK.setUserGDPRConsentStatus called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string status;
        ok &= seval_to_std_string(args[0], &status);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setUserGDPRConsentStatus: Error processing arguments");
        TGSDKCocos2dxHelper::setUserGDPRConsentStatus(status);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.setUserGDPRConsentStatus: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_setUserGDPRConsentStatus)


static bool jsb_TGSDK_function_getIsAgeRestrictedUser(se::State& s) {
    LOGD("JSB TGSDK.getIsAgeRestrictedUser called");
    std::string ret = TGSDKCocos2dxHelper::getIsAgeRestrictedUser();
    CC_UNUSED bool ok = std_string_to_seval(ret, &s.rval());
    SE_PRECONDITION2(ok, false, "JSB TGSDK.getIsAgeRestrictedUser: Error processing arguments");
    return true;
}
SE_BIND_FUNC(jsb_TGSDK_function_getIsAgeRestrictedUser)


static bool jsb_TGSDK_function_setIsAgeRestrictedUser(se::State& s) {
    LOGD("JSB TGSDK.setIsAgeRestrictedUser called");
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string status;
        ok &= seval_to_std_string(args[0], &status);
        SE_PRECONDITION2(ok, false, "JSB TGSDK.setIsAgeRestrictedUser: Error processing arguments");
        TGSDKCocos2dxHelper::setIsAgeRestrictedUser(status);
        return true;
    }
    SE_REPORT_ERROR("JSB TGSDK.setIsAgeRestrictedUser: Wrong number of arguments");
    return false;
}
SE_BIND_FUNC(jsb_TGSDK_function_setIsAgeRestrictedUser)

#define DEFINE_JSB_FUNCTION(method) cls->defineStaticFunction(#method, _SE(jsb_TGSDK_function_##method))
#define DEFINE_JSB_PROP(prop)  cls->defineStaticProperty(#prop, _SE(jsb_##prop), nullptr)
bool register_jsb_tgsdk(se::Object* obj)
{
    // Get the ns
    se::Value nsVal;
    if (!obj->getProperty("yomob", &nsVal))
    {
        se::HandleObject jsobj(se::Object::createPlainObject());
        nsVal.setObject(jsobj);
        obj->setProperty("yomob", nsVal);
    }
    se::Object* ns = nsVal.toObject();
    
    auto cls = se::Class::create("TGSDK", ns, nullptr, nullptr);
    DEFINE_JSB_FUNCTION(setDebugModel);
    DEFINE_JSB_FUNCTION(setSDKConfig);
    DEFINE_JSB_FUNCTION(getSDKConfig);
    DEFINE_JSB_FUNCTION(initialize);
    DEFINE_JSB_FUNCTION(isWIFI);
    DEFINE_JSB_FUNCTION(preload);
    DEFINE_JSB_FUNCTION(parameterFromAdScene);
    DEFINE_JSB_FUNCTION(setBannerConfig);
    DEFINE_JSB_FUNCTION(couldShowAd);
    DEFINE_JSB_FUNCTION(showAd);
    DEFINE_JSB_FUNCTION(showTestView);
    DEFINE_JSB_FUNCTION(closeBanner);
    DEFINE_JSB_FUNCTION(reportAdRejected);
    DEFINE_JSB_FUNCTION(showAdScene);
    DEFINE_JSB_FUNCTION(sendCounter);
    DEFINE_JSB_FUNCTION(tagPayingUser);
    DEFINE_JSB_FUNCTION(getUserGDPRConsentStatus);
    DEFINE_JSB_FUNCTION(setUserGDPRConsentStatus);
    DEFINE_JSB_FUNCTION(getIsAgeRestrictedUser);
    DEFINE_JSB_FUNCTION(setIsAgeRestrictedUser);
    
    DEFINE_JSB_PROP(TGSDK_EVENT_INIT_SUCCESS);
    DEFINE_JSB_PROP(TGSDK_EVENT_INIT_FAILED);
    DEFINE_JSB_PROP(TGSDK_EVENT_PRELOAD_SUCCESS);
    DEFINE_JSB_PROP(TGSDK_EVENT_PRELOAD_FAILED);
    DEFINE_JSB_PROP(TGSDK_EVENT_CPAD_LOADED);
    DEFINE_JSB_PROP(TGSDK_EVENT_VIDEOAD_LOADED);
    DEFINE_JSB_PROP(TGSDK_EVENT_AD_SHOW_SUCCESS);
    DEFINE_JSB_PROP(TGSDK_EVENT_AD_SHOW_FAILED);
    DEFINE_JSB_PROP(TGSDK_EVENT_AD_COMPLETE);
    DEFINE_JSB_PROP(TGSDK_EVENT_AD_CLICK);
    DEFINE_JSB_PROP(TGSDK_EVENT_AD_CLOSE);
    DEFINE_JSB_PROP(TGSDK_EVENT_REWARD_SUCCESS);
    DEFINE_JSB_PROP(TGSDK_EVENT_REWARD_FAILED);
    DEFINE_JSB_PROP(TGSDK_EVENT_BANNER_LOADED);
    DEFINE_JSB_PROP(TGSDK_EVENT_BANNER_FAILED);
    DEFINE_JSB_PROP(TGSDK_EVENT_BANNER_CLICK);
    DEFINE_JSB_PROP(TGSDK_EVENT_BANNER_CLOSE);
    DEFINE_JSB_PROP(TGPAYINGUSER_NON_PAYING_USER);
    DEFINE_JSB_PROP(TGPAYINGUSER_SMALL_PAYMENT_USER);
    DEFINE_JSB_PROP(TGPAYINGUSER_MEDIUM_PAYMENT_USER);
    DEFINE_JSB_PROP(TGPAYINGUSER_LARGE_PAYMENT_USER);
    DEFINE_JSB_PROP(TGSDK_BANNER_TYPE_NORMAL);
    DEFINE_JSB_PROP(TGSDK_BANNER_TYPE_MEDIUM);
    DEFINE_JSB_PROP(TGSDK_BANNER_TYPE_LARGE);
    
    cls->install();
    JSBClassType::registerClass<yomob::TGSDKCocos2dxHelper>(cls);
    jsb_TGSDK_prototype = cls->getProto();
    jsb_TGSDK_class = cls;
    se::ScriptEngine::getInstance()->clearException();
    
    return true;
}

#endif

#ifdef TGSDK_BIND_JS
#include "jsapi.h"
#include "jsfriendapi.h"
#include "scripting/js-bindings/manual/ScriptingCore.h"
#include <stdlib.h>

#define JSTGSDKClass "TGSDK"
JSClass *jsb_TGSDK_class;
JSObject *jsb_TGSDK_prototype;

#define JSB_TGSDK_EVENT_GETTER(evt) \
static bool jsb_##evt(JSContext* cx, uint32_t argc, jsval* vp) {\
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);\
    args.rval().set(std_string_to_jsval(cx, evt));\
    return true;\
}

JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_INIT_SUCCESS)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_INIT_FAILED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_PRELOAD_SUCCESS)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_PRELOAD_FAILED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_CPAD_LOADED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_VIDEOAD_LOADED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_SHOW_SUCCESS)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_SHOW_FAILED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_COMPLETE)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_CLICK)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_CLOSE)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_REWARD_SUCCESS)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_REWARD_FAILED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_LOADED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_FAILED)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_CLICK)
JSB_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_CLOSE)

JSB_TGSDK_EVENT_GETTER(TGPAYINGUSER_NON_PAYING_USER)
JSB_TGSDK_EVENT_GETTER(TGPAYINGUSER_SMALL_PAYMENT_USER)
JSB_TGSDK_EVENT_GETTER(TGPAYINGUSER_MEDIUM_PAYMENT_USER)
JSB_TGSDK_EVENT_GETTER(TGPAYINGUSER_LARGE_PAYMENT_USER)

JSB_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_NORMAL)
JSB_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_MEDIUM)
JSB_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_LARGE)

bool jsb_TGSDK_constructor(JSContext* cx, uint32_t argc, jsval *vp) {
    JS_ReportError(cx, "TGSDK could not be instantiated");
    return false;
}

void jsb_TGSDK_finalize(JSFreeOp *fop, JSObject *obj) {
    LOGD("JSB TGSDK finalize called");
}

bool jsb_TGSDK_function_setDebugModel(JSContext* cx, uint32_t argc, jsval *vp) {
    LOGD("JSB TGSDK.setDebugModel called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        bool debug = JS::ToBoolean(args.get(0));
        TGSDKCocos2dxHelper::setDebugModel(debug);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.setDebugModel: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_setSDKConfig(JSContext* cx, uint32_t argc, jsval *vp) {
    LOGD("JSB TGSDK.setSDKConfig called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (2 == argc) {
        std::string key;
        std::string val;
        bool ok = jsval_to_std_string(cx, args.get(0), &key);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setSDKConfig key must be string");
        ok &= jsval_to_std_string(cx, args.get(1), &val);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setSDKConfig val must be string");
        TGSDKCocos2dxHelper::setSDKConfig(key, val);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.setSDKConfig: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_getSDKConfig(JSContext *cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.getSDKConfig called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string key;
        bool ok = jsval_to_std_string(cx, args.get(0), &key);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.getSDKConfig key must be string");
        std::string val = TGSDKCocos2dxHelper::getSDKConfig(key);
        args.rval().set(std_string_to_jsval(cx, val));
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.getSDKConfig: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_initialize(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.initialize called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (0 == argc) {
        TGSDKCocos2dxHelper::initialize();
    } else if (1 == argc) {
        std::string appid;
        bool ok = jsval_to_std_string(cx, args.get(0), &appid);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.initialize appid must be string");
        TGSDKCocos2dxHelper::initialize(appid);
    } else if (2 <= argc) {
        std::string appid;
        std::string channelid;
        bool ok = jsval_to_std_string(cx, args.get(0), &appid);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.initialize appid must be string");
        ok = jsval_to_std_string(cx, args.get(1), &channelid);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.initialize channelid must be string");
        TGSDKCocos2dxHelper::initialize(appid, channelid);
    } else {
        JS_ReportError(cx, "JSB TGSDK.initialize: Wrong number of arguments");
        return false;
    }
    args.rval().set(JSVAL_NULL);
    return true;
}

bool jsb_TGSDK_function_isWIFI(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.isWIFI called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    int ret = TGSDKCocos2dxHelper::isWIFI();
    args.rval().set(INT_TO_JSVAL(ret));
    return true;
}

bool jsb_TGSDK_function_preload(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.preload called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    TGSDKCocos2dxHelper::preload();
    args.rval().set(JSVAL_NULL);
    return true;
}

bool jsb_TGSDK_function_parameterFromAdScene(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.parameterFromAdScene called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (argc >= 2) {
        std::string scene;
        std::string key;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.parameterFromAdScene scene must be string");
        ok = jsval_to_std_string(cx, args.get(1), &key);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.parameterFromAdScene key must be string");
        std::string ret = TGSDKCocos2dxHelper::getStringParameterFromAdScene(scene, key, TGSDK_NONE);
        if (ret.compare(TGSDK_NONE) == 0) {
            if (argc > 2) {
                args.rval().set(args.get(2));
            } else {
                args.rval().set(JSVAL_NULL);
            }
        } else {
            args.rval().set(std_string_to_jsval(cx, ret));
        }
    } else {
        JS_ReportError(cx, "JSB TGSDK.parameterFromAdScene: Wrong number of arguments");
        return false;
    }
    return true;
}

bool jsb_TGSDK_function_setBannerConfig(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.setBannerConfig called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (7 == argc) {
        std::string scene;
        std::string type;
        double x, y, width, height;
        long interval;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig scene must be string");
        ok &= jsval_to_std_string(cx, args.get(1), &type);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig type must be string");
        ok &= ToNumber(cx, args.get(2), &x);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig x must be number");
        ok &= ToNumber(cx, args.get(3), &y);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig y must be number");
        ok &= ToNumber(cx, args.get(4), &width);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig width must be number");
        ok &= ToNumber(cx, args.get(5), &height);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig height must be number");
        ok &= jsval_to_long(cx, args.get(6), &interval);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setBannerConfig interval must be number");
        TGSDKCocos2dxHelper::setBannerConfig(scene, type, (float)x, (float)y, (float)width, (float)height, (int)interval);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.setBannerConfig: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_couldShowAd(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.couldShowAd called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.couldShowAd scene must be string");
        ok = TGSDKCocos2dxHelper::couldShowAd(scene);
        args.rval().set(BOOLEAN_TO_JSVAL(ok));
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.couldShowAd: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_showAd(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.showAd called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.showAd scene must be string");
        TGSDKCocos2dxHelper::showAd(scene);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.showAd: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_showTestView(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.showTestView called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.showTestView scene must be string");
        TGSDKCocos2dxHelper::showTestView(scene);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.showTestView: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_closeBanner(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.closeBanner called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.closeBanner scene must be string");
        TGSDKCocos2dxHelper::closeBanner(scene);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.closeBanner: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_reportAdRejected(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.reportAdRejected called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.reportAdRejected scene must be string");
        TGSDKCocos2dxHelper::reportAdRejected(scene);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.reportAdRejected: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_showAdScene(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.showAdScene called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string scene;
        bool ok = jsval_to_std_string(cx, args.get(0), &scene);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.showAdScene scene must be string");
        TGSDKCocos2dxHelper::showAdScene(scene);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.showAdScene: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_sendCounter(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.sendCounter called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (2 == argc) {
        std::string name;
        std::string metaData;
        bool ok = jsval_to_std_string(cx, args.get(0), &name);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.sendCounter name must be string");
        ok = jsval_to_std_string(cx, args.get(1), &metaData);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.sendCounter metaData must be string");
        TGSDKCocos2dxHelper::sendCounter(name, metaData);
        args.rval().set(JSVAL_NULL);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.sendCounter: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_tagPayingUser(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.tagPayingUser called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    std::string payingUser;
    std::string currency = "";
    float currentAmount = 0;
    float totalAmount = 0;
    bool ok = true;
    if (1 <= argc) {
        ok &= jsval_to_std_string(cx, args.get(0), &payingUser);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.tagPayingUser user must be string");
        if (!ok) {
            return false;
        }
    }
    if (2 <= argc) {
        ok &= jsval_to_std_string(cx, args.get(1), &currency);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.tagPayingUser currency must be string");
    }
    if (3 <= argc) {
        JSString *jsstr = JS::ToString(cx, args.get(2));
        JSB_PRECONDITION2(jsstr, cx, false, "JSB TGSDK.tagPayingUser currentAmount must be number");
        char *str = JS_EncodeString(cx, jsstr);
        JSB_PRECONDITION2(str, cx, false, "JSB TGSDK.tagPayingUser currentAmount must be number");
        char *endptr;
        currentAmount = strtof(str, &endptr);
    }
    if (4 <= argc) {
        JSString *jsstr = JS::ToString(cx, args.get(3));
        JSB_PRECONDITION2(jsstr, cx, false, "JSB TGSDK.tagPayingUser totalAmount must be number");
        char *str = JS_EncodeString(cx, jsstr);
        JSB_PRECONDITION2(str, cx, false, "JSB TGSDK.tagPayingUser totalAmount must be number");
        char *endptr;
        totalAmount = strtof(str, &endptr);
    }
    if (payingUser.compare(TGPAYINGUSER_NON_PAYING_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxNonPayingUser,
            currency, currentAmount, totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_SMALL_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxSmallPaymentUser,
            currency, currentAmount, totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_MEDIUM_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxMediumPaymentUser,
            currency, currentAmount, totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_LARGE_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxLargePaymentUser,
            currency, currentAmount, totalAmount);
    } else {
        LOGD("JSB TGSDK.tagPayingUser invalid user tag : %s", payingUser.c_str());
        JSB_PRECONDITION2(false, cx, false, "JSB TGSDK.tagPayingUser invalid user tag");
    }
    return true;
}

bool jsb_TGSDK_function_getUserGDPRConsentStatus(JSContext *cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.getUserGDPRConsentStatus called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    std::string status = TGSDKCocos2dxHelper::getUserGDPRConsentStatus();
    args.rval().set(std_string_to_jsval(cx, status));
    return true;
}

bool jsb_TGSDK_function_setUserGDPRConsentStatus(JSContext* cx, uint32_t argc, jsval *vp) {
    LOGD("JSB TGSDK.setUserGDPRConsentStatus called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string status;
        bool ok = jsval_to_std_string(cx, args.get(0), &status);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setUserGDPRConsentStatus status must be string");
        TGSDKCocos2dxHelper::setUserGDPRConsentStatus(status);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.setUserGDPRConsentStatus: Wrong number of arguments");
    return false;
}

bool jsb_TGSDK_function_getIsAgeRestrictedUser(JSContext *cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.getIsAgeRestrictedUser called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    std::string status = TGSDKCocos2dxHelper::getIsAgeRestrictedUser();
    args.rval().set(std_string_to_jsval(cx, status));
    return true;
}

bool jsb_TGSDK_function_setIsAgeRestrictedUser(JSContext* cx, uint32_t argc, jsval *vp) {
    LOGD("JSB TGSDK.setIsAgeRestrictedUser called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    if (1 == argc) {
        std::string status;
        bool ok = jsval_to_std_string(cx, args.get(0), &status);
        JSB_PRECONDITION2(ok, cx, false, "JSB TGSDK.setIsAgeRestrictedUser status must be string");
        TGSDKCocos2dxHelper::setIsAgeRestrictedUser(status);
        return true;
    }
    JS_ReportError(cx, "JSB TGSDK.setIsAgeRestrictedUser: Wrong number of arguments");
    return false;
}

void register_jsb_tgsdk(JSContext* cx, JS::HandleObject global) {
    JS::RootedObject yomob(cx);
    JS::RootedValue yomobval(cx);
    JS_GetProperty(cx, global, "yomob", &yomobval);
    if (yomobval == JSVAL_VOID) {
        yomob.set(JS_NewObject(cx, nullptr, JS::NullPtr(), JS::NullPtr()));
        yomobval = OBJECT_TO_JSVAL(yomob);
        JS_SetProperty(cx, global, "yomob", yomobval);
    } else {
        yomob.set(yomobval.toObjectOrNull());
    }
    
    
    jsb_TGSDK_class = (JSClass*)calloc(1, sizeof(JSClass));
    jsb_TGSDK_class->name = JSTGSDKClass;
    jsb_TGSDK_class->addProperty = JS_PropertyStub;
    jsb_TGSDK_class->delProperty = JS_DeletePropertyStub;
    jsb_TGSDK_class->getProperty = JS_PropertyStub;
    jsb_TGSDK_class->setProperty = JS_StrictPropertyStub;
    jsb_TGSDK_class->enumerate = JS_EnumerateStub;
    jsb_TGSDK_class->resolve = JS_ResolveStub;
    jsb_TGSDK_class->convert = JS_ConvertStub;
    jsb_TGSDK_class->finalize = jsb_TGSDK_finalize;
    jsb_TGSDK_class->flags = JSCLASS_HAS_RESERVED_SLOTS(2);
    
    static JSFunctionSpec funcs[] = {
        JS_FN("setDebugModel", jsb_TGSDK_function_setDebugModel, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("setSDKConfig", jsb_TGSDK_function_setSDKConfig, 2, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("getSDKConfig", jsb_TGSDK_function_getSDKConfig, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("initialize", jsb_TGSDK_function_initialize, 2, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("isWIFI", jsb_TGSDK_function_isWIFI, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("preload", jsb_TGSDK_function_preload, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("parameterFromAdScene", jsb_TGSDK_function_parameterFromAdScene, 3, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("setBannerConfig", jsb_TGSDK_function_setBannerConfig, 7, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("couldShowAd", jsb_TGSDK_function_couldShowAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showAd", jsb_TGSDK_function_showAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showTestView", jsb_TGSDK_function_showTestView, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("closeBanner", jsb_TGSDK_function_closeBanner, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("reportAdRejected", jsb_TGSDK_function_reportAdRejected, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showAdScene", jsb_TGSDK_function_showAdScene, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("sendCounter", jsb_TGSDK_function_sendCounter, 2, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("tagPayingUser", jsb_TGSDK_function_tagPayingUser, 4, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("getUserGDPRConsentStatus", jsb_TGSDK_function_getUserGDPRConsentStatus, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("setUserGDPRConsentStatus", jsb_TGSDK_function_setUserGDPRConsentStatus, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("getIsAgeRestrictedUser", jsb_TGSDK_function_getIsAgeRestrictedUser, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("setIsAgeRestrictedUser", jsb_TGSDK_function_setIsAgeRestrictedUser, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FS_END
    };
    
    static JSPropertySpec properties[] = {
        JS_PSG("TGSDK_EVENT_INIT_SUCCESS", jsb_TGSDK_EVENT_INIT_SUCCESS, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_INIT_FAILED", jsb_TGSDK_EVENT_INIT_FAILED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_PRELOAD_SUCCESS", jsb_TGSDK_EVENT_PRELOAD_SUCCESS, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_PRELOAD_FAILED", jsb_TGSDK_EVENT_PRELOAD_FAILED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_CPAD_LOADED", jsb_TGSDK_EVENT_CPAD_LOADED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_VIDEOAD_LOADED", jsb_TGSDK_EVENT_VIDEOAD_LOADED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_AD_SHOW_SUCCESS", jsb_TGSDK_EVENT_AD_SHOW_SUCCESS, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_AD_SHOW_FAILED", jsb_TGSDK_EVENT_AD_SHOW_FAILED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_AD_COMPLETE", jsb_TGSDK_EVENT_AD_COMPLETE, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_AD_CLICK", jsb_TGSDK_EVENT_AD_CLICK, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_AD_CLOSE", jsb_TGSDK_EVENT_AD_CLOSE, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_REWARD_SUCCESS", jsb_TGSDK_EVENT_REWARD_SUCCESS, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_REWARD_FAILED", jsb_TGSDK_EVENT_REWARD_FAILED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_BANNER_LOADED", jsb_TGSDK_EVENT_BANNER_LOADED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_BANNER_FAILED", jsb_TGSDK_EVENT_BANNER_FAILED, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_BANNER_CLICK", jsb_TGSDK_EVENT_BANNER_CLICK, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_EVENT_BANNER_CLOSE", jsb_TGSDK_EVENT_BANNER_CLOSE, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGPAYINGUSER_NON_PAYING_USER", jsb_TGPAYINGUSER_NON_PAYING_USER, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGPAYINGUSER_SMALL_PAYMENT_USER", jsb_TGPAYINGUSER_SMALL_PAYMENT_USER, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGPAYINGUSER_MEDIUM_PAYMENT_USER", jsb_TGPAYINGUSER_MEDIUM_PAYMENT_USER, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGPAYINGUSER_LARGE_PAYMENT_USER", jsb_TGPAYINGUSER_LARGE_PAYMENT_USER, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_BANNER_TYPE_NORMAL", jsb_TGSDK_BANNER_TYPE_NORMAL, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_BANNER_TYPE_MEDIUM", jsb_TGSDK_BANNER_TYPE_MEDIUM, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PSG("TGSDK_BANNER_TYPE_LARGE", jsb_TGSDK_BANNER_TYPE_LARGE, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_PS_END
    };
    
    jsb_TGSDK_prototype = JS_InitClass(cx, yomob,
                                       JS::NullPtr(),
                                       jsb_TGSDK_class,
                                       jsb_TGSDK_constructor, 0,
                                       nullptr,
                                       nullptr,
                                       properties,
                                       funcs);
}
#endif
#ifdef TGSDK_BIND_LUA

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/CCLuaStack.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

#define LUA_TGSDK_EVENT_GETTER(evt) \
static int tolua_##evt(lua_State* tolua_S) {\
    lua_pushstring(tolua_S, evt);\
    return 1;\
}

LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_INIT_SUCCESS)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_INIT_FAILED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_PRELOAD_SUCCESS)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_PRELOAD_FAILED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_CPAD_LOADED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_VIDEOAD_LOADED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_SHOW_SUCCESS)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_SHOW_FAILED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_COMPLETE)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_CLICK)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_AD_CLOSE)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_REWARD_SUCCESS)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_REWARD_FAILED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_LOADED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_FAILED)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_CLICK)
LUA_TGSDK_EVENT_GETTER(TGSDK_EVENT_BANNER_CLOSE)

LUA_TGSDK_EVENT_GETTER(TGPAYINGUSER_NON_PAYING_USER)
LUA_TGSDK_EVENT_GETTER(TGPAYINGUSER_SMALL_PAYMENT_USER)
LUA_TGSDK_EVENT_GETTER(TGPAYINGUSER_MEDIUM_PAYMENT_USER)
LUA_TGSDK_EVENT_GETTER(TGPAYINGUSER_LARGE_PAYMENT_USER)

LUA_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_NORMAL)
LUA_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_MEDIUM)
LUA_TGSDK_EVENT_GETTER(TGSDK_BANNER_TYPE_LARGE)

#ifdef __cplusplus
static int tolua_collect_TGSDK (lua_State* tolua_S) {
    TGSDKCocos2dxHelper* self = (TGSDKCocos2dxHelper*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}
#endif

bool __luaval_to_std_string(lua_State* L, int lo, std::string* outValue, const char* funcName)
{
    if (NULL == L || NULL == outValue)
        return false;
    
    bool ok = true;
    
    tolua_Error tolua_err;
    if (!tolua_iscppstring(L,lo,0,&tolua_err))
    {
        ok = false;
    }
    
    if (ok)
    {
        *outValue = tolua_tocppstring(L,lo,NULL);
    }
    
    return ok;
}

bool __luaval_to_number(lua_State* L,int lo,double* outValue, const char* funcName)
{
    if (NULL == L || NULL == outValue)
        return false;

    bool ok = true;

    tolua_Error tolua_err;
    if (!tolua_isnumber(L,lo,0,&tolua_err))
    {
        ok = false;
    }

    if (ok)
    {
        *outValue = tolua_tonumber(L, lo, 0);
    }

    return ok;
}

static int tolua_TGSDK_function_setDebugModel(lua_State* tolua_S) {
    LOGD("Lua TGSDK.setDebugModel called");
    tolua_Error tolua_err;
    if (tolua_isboolean(tolua_S, 1, 0, &tolua_err)) {
        bool debug = (bool)tolua_toboolean(tolua_S, 1, 0);
        TGSDKCocos2dxHelper::setDebugModel(debug);
    } else {
        LOGD("Lua TGSDK.setDebugModel: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.setDebugModel'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_setSDKConfig(lua_State* tolua_S) {
    LOGD("Lua TGSDK.setSDKConfig called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err) &&
        tolua_isstring(tolua_S, 2, 0, &tolua_err)) {
        std::string key;
        std::string val;
        bool ok = __luaval_to_std_string(tolua_S, 1, &key, "setSDKConfig");
        ok &= __luaval_to_std_string(tolua_S, 2, &val, "setSDKConfig");
        if (ok) {
            TGSDKCocos2dxHelper::setSDKConfig(key, val);
        }
    } else {
        LOGD("Lua TGSDK.setSDKConfig: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.setSDKConfig'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_getSDKConfig(lua_State* tolua_S) {
    LOGD("Lua TGSDK.getSDKConfig called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string key;
        bool ok = __luaval_to_std_string(tolua_S, 1, &key, "getSDKConfig");
        if (ok) {
            std::string val = TGSDKCocos2dxHelper::getSDKConfig(key);
            tolua_pushstring(tolua_S, val.c_str());
        } else {
            lua_pushnil(tolua_S);
        }
    } else {
        LOGD("Lua TGSDK.getSDKConfig: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.getSDKConfig'.",&tolua_err);
        lua_pushnil(tolua_S);
    }
    return 1;
}

static int tolua_TGSDK_function_parameterFromAdScene(lua_State* tolua_S) {
    LOGD("Lua TGSDK.parameterFromAdScene called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)
        &&  tolua_isstring(tolua_S, 2, 0, &tolua_err)) {
        std::string scene;
        std::string key;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "parameterFromAdScene");
        ok &= __luaval_to_std_string(tolua_S, 2, &key, "parameterFromAdScene");
        if (ok) {
            std::string ret = TGSDKCocos2dxHelper::getStringParameterFromAdScene(scene, key, TGSDK_NONE);
            if (ret.compare(TGSDK_NONE) == 0) {
                if (lua_gettop(tolua_S) > 2) {
                    lua_pushvalue(tolua_S, 3);
                } else {
                    lua_pushnil(tolua_S);
                }
            } else {
                tolua_pushstring(tolua_S, ret.c_str());
            }
        }
    } else {
        LOGD("Lua TGSDK.parameterFromAdScene: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.parameterFromAdScene'.",&tolua_err);
        lua_pushnil(tolua_S);
    }
    return 1;
}

static int tolua_TGSDK_function_setBannerConfig(lua_State* tolua_S) {
    LOGD("Lua TGSDK.setBannerConfig called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err) &&
        tolua_isstring(tolua_S, 2, 0, &tolua_err) &&
        tolua_isnumber(tolua_S, 3, 0, &tolua_err) &&
        tolua_isnumber(tolua_S, 4, 0, &tolua_err) &&
        tolua_isnumber(tolua_S, 5, 0, &tolua_err) &&
        tolua_isnumber(tolua_S, 6, 0, &tolua_err) &&
        tolua_isnumber(tolua_S, 7, 0, &tolua_err) ) {

        std::string scene;
        std::string type;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "setBannerConfig");
        ok &= __luaval_to_std_string(tolua_S, 2, &type, "setBannerConfig");
        lua_Number x, y, width, height, interval;
        x = tolua_tonumber(tolua_S, 3, -1);
        y = tolua_tonumber(tolua_S, 4, -1);
        width = tolua_tonumber(tolua_S, 5, 0);
        height = tolua_tonumber(tolua_S, 6, 0);
        interval = tolua_tonumber(tolua_S, 7, 0);

        if (ok) {
            TGSDKCocos2dxHelper::setBannerConfig(scene, type, (float)x, (float)y, (float)width, (float)height, (int)interval);
        }

    } else {
        LOGD("Lua TGSDK.setBannerConfig: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.setBannerConfig'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_initialize(lua_State* tolua_S) {
    LOGD("Lua TGSDK.initialize called");
    tolua_Error tolua_err;
    bool hasArgv1 = tolua_isstring(tolua_S, 1, 0, &tolua_err);
    bool hasArgv2 = tolua_isstring(tolua_S, 2, 0, &tolua_err);
    if (hasArgv1 && hasArgv2) {
        std::string appid;
        std::string channelid;
        bool ok = __luaval_to_std_string(tolua_S, 1, &appid, "initialize");
        if (!ok) {
        }
        ok = __luaval_to_std_string(tolua_S, 2, &channelid, "initialize");
        if (!ok) {
        }
        TGSDKCocos2dxHelper::initialize(appid, channelid);
    } else if (hasArgv1) {
        std::string appid;
        bool ok = __luaval_to_std_string(tolua_S, 1, &appid, "initialize");
        if (!ok) {
        }
        TGSDKCocos2dxHelper::initialize(appid);
    } else {
        TGSDKCocos2dxHelper::initialize();
    }
    return 0;
}

static int tolua_TGSDK_function_isWIFI(lua_State* tolua_S) {
    LOGD("Lua TGSDK.isWIFI called");
    int ret = TGSDKCocos2dxHelper::isWIFI();
    tolua_pushnumber(tolua_S, (double)ret);
    return 1;
}

static int tolua_TGSDK_function_preload(lua_State* tolua_S) {
    LOGD("Lua TGSDK.preload called");
    // tolua_Error tolua_err;
    TGSDKCocos2dxHelper::preload();
    return 0;
}

static int tolua_TGSDK_function_couldShowAd(lua_State* tolua_S) {
    LOGD("Lua TGSDK.couldShowAd called");
    tolua_Error tolua_err;
    bool ret = false;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        ret = __luaval_to_std_string(tolua_S, 1, &scene, "couldShowAd");
        if (ret) {
            ret = TGSDKCocos2dxHelper::couldShowAd(scene);
        }
    } else {
        LOGD("Lua TGSDK.couldShowAd: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.couldShowAd'.",&tolua_err);
    }
    tolua_pushboolean(tolua_S, ret);
    return 1;
}

static int tolua_TGSDK_function_showAd(lua_State* tolua_S) {
    LOGD("Lua TGSDK.showAd called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "showAd");
        if (ok) {
            TGSDKCocos2dxHelper::showAd(scene);
        }
    } else {
        LOGD("Lua TGSDK.showAd: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.showAd'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_closeBanner(lua_State* tolua_S) {
    LOGD("Lua TGSDK.closeBanner called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "closeBanner");
        if (ok) {
            TGSDKCocos2dxHelper::closeBanner(scene);
        }
    } else {
        LOGD("Lua TGSDK.closeBanner: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.closeBanner'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_showTestView(lua_State* tolua_S) {
    LOGD("Lua TGSDK.showTestView called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "showTestView");
        if (ok) {
            TGSDKCocos2dxHelper::showTestView(scene);
        }
    } else {
        LOGD("Lua TGSDK.showTestView: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.showTestView'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_reportAdRejected(lua_State* tolua_S) {
    LOGD("Lua TGSDK.reportAdRejected called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "reportAdRejected");
        if (ok) {
            TGSDKCocos2dxHelper::reportAdRejected(scene);
        }
    } else {
        LOGD("Lua TGSDK.reportAdRejected: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.reportAdRejected'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_showAdScene(lua_State* tolua_S) {
    LOGD("Lua TGSDK.showAdScene called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string scene;
        bool ok = __luaval_to_std_string(tolua_S, 1, &scene, "showAdScene");
        if (ok) {
            TGSDKCocos2dxHelper::showAdScene(scene);
        }
    } else {
        LOGD("Lua TGSDK.showAdScene: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.showAdScene'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_sendCounter(lua_State* tolua_S) {
    LOGD("Lua TGSDK.sendCounter called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err) &&
        tolua_isstring(tolua_S, 2, 0, &tolua_err)) {
        std::string name;
        std::string metaData;
        bool ok = __luaval_to_std_string(tolua_S, 1, &name, "sendCounter");
        ok &= __luaval_to_std_string(tolua_S, 2, &metaData, "sendCounter");
        if (ok) {
            TGSDKCocos2dxHelper::sendCounter(name, metaData);
        }
    } else {
        LOGD("Lua TGSDK.sendCounter: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.sendCounter'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_tagPayingUser(lua_State* tolua_S) {
    LOGD("Lua TGSDK.tagPayingUser called");
    tolua_Error tolua_err;
    std::string payingUser;
    std::string currency = "";
    double currentAmount = 0;
    double totalAmount = 0;
    bool ok = true;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        ok &= __luaval_to_std_string(tolua_S, 1, &payingUser, "tagPayingUser");
        if (!ok) {
            LOGD("Lua TGSDK.payingUser user must be string");
            return 0;
        }
    } else {
        tolua_error(tolua_S, "#ferror in function 'TGSDK.tagPayingUser'.", &tolua_err);
        return 0;
    }
    if (tolua_isstring(tolua_S, 2, 0, &tolua_err)) {
        ok &= __luaval_to_std_string(tolua_S, 2, &currency, "tagPayingUser");
    }
    if (tolua_isnumber(tolua_S, 3, 0, &tolua_err)) {
        ok &= __luaval_to_number(tolua_S, 3, &currentAmount, "tagPayingUser");
    }
    if (tolua_isnumber(tolua_S, 4, 0, &tolua_err)) {
        ok &= __luaval_to_number(tolua_S, 4, &totalAmount, "tagPayingUser");
    }
    if (payingUser.compare(TGPAYINGUSER_NON_PAYING_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxNonPayingUser,
            currency, (float)currentAmount, (float)totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_SMALL_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxSmallPaymentUser,
            currency, (float)currentAmount, (float)totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_MEDIUM_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxMediumPaymentUser,
            currency, (float)currentAmount, (float)totalAmount);
    } else if (payingUser.compare(TGPAYINGUSER_LARGE_PAYMENT_USER) == 0) {
        TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocos2dxLargePaymentUser,
            currency, (float)currentAmount, (float)totalAmount);
    } else {
        LOGD("LUA TGSDK.tagPayingUser invalid user tag : %s", payingUser.c_str());
    }
    return 0;
}

static int tolua_TGSDK_function_setUserGDPRConsentStatus(lua_State* tolua_S) {
    LOGD("Lua TGSDK.setUserGDPRConsentStatus called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string status;
        bool ok = __luaval_to_std_string(tolua_S, 1, &status, "setUserGDPRConsentStatus");
        if (ok) {
            TGSDKCocos2dxHelper::setUserGDPRConsentStatus(status);
        }
    } else {
        LOGD("Lua TGSDK.setUserGDPRConsentStatus: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.setUserGDPRConsentStatus'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_getUserGDPRConsentStatus(lua_State* tolua_S) {
    LOGD("Lua TGSDK.getUserGDPRConsentStatus called");
    std::string status = TGSDKCocos2dxHelper::getUserGDPRConsentStatus();
    tolua_pushstring(tolua_S, status.c_str());
    return 1;
}

static int tolua_TGSDK_function_setIsAgeRestrictedUser(lua_State* tolua_S) {
    LOGD("Lua TGSDK.setIsAgeRestrictedUser called");
    tolua_Error tolua_err;
    if (tolua_isstring(tolua_S, 1, 0, &tolua_err)) {
        std::string status;
        bool ok = __luaval_to_std_string(tolua_S, 1, &status, "setIsAgeRestrictedUser");
        if (ok) {
            TGSDKCocos2dxHelper::setIsAgeRestrictedUser(status);
        }
    } else {
        LOGD("Lua TGSDK.setIsAgeRestrictedUser: Wrong number of arguments");
        tolua_error(tolua_S,"#ferror in function 'TGSDK.setIsAgeRestrictedUser'.",&tolua_err);
    }
    return 0;
}

static int tolua_TGSDK_function_getIsAgeRestrictedUser(lua_State* tolua_S) {
    LOGD("Lua TGSDK.getIsAgeRestrictedUser called");
    std::string status = TGSDKCocos2dxHelper::getIsAgeRestrictedUser();
    tolua_pushstring(tolua_S, status.c_str());
    return 1;
}

TOLUA_API int tolua_tgsdk_open(lua_State* tolua_S){
    tolua_open(tolua_S);
    tolua_usertype(tolua_S, "yomob.TGSDK");
    tolua_module(tolua_S,"yomob",0);
    tolua_beginmodule(tolua_S,"yomob");
      #ifdef __cplusplus
      tolua_cclass(tolua_S,"TGSDK","yomob.TGSDK","",tolua_collect_TGSDK);
      #else
      tolua_cclass(tolua_S,"TGSDK","yomob.TGSDK","",NULL);
      #endif
      tolua_beginmodule(tolua_S,"TGSDK");
        tolua_variable(tolua_S, "TGSDK_EVENT_INIT_SUCCESS", tolua_TGSDK_EVENT_INIT_SUCCESS, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_INIT_FAILED", tolua_TGSDK_EVENT_INIT_FAILED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_PRELOAD_SUCCESS", tolua_TGSDK_EVENT_PRELOAD_SUCCESS, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_PRELOAD_FAILED", tolua_TGSDK_EVENT_PRELOAD_FAILED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_CPAD_LOADED", tolua_TGSDK_EVENT_CPAD_LOADED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_VIDEOAD_LOADED", tolua_TGSDK_EVENT_VIDEOAD_LOADED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_AD_SHOW_SUCCESS", tolua_TGSDK_EVENT_AD_SHOW_SUCCESS, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_AD_SHOW_FAILED", tolua_TGSDK_EVENT_AD_SHOW_FAILED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_AD_COMPLETE", tolua_TGSDK_EVENT_AD_COMPLETE, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_AD_CLICK", tolua_TGSDK_EVENT_AD_CLICK, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_AD_CLOSE", tolua_TGSDK_EVENT_AD_CLOSE, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_REWARD_SUCCESS", tolua_TGSDK_EVENT_REWARD_SUCCESS, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_REWARD_FAILED", tolua_TGSDK_EVENT_REWARD_FAILED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_BANNER_LOADED", tolua_TGSDK_EVENT_BANNER_LOADED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_BANNER_FAILED", tolua_TGSDK_EVENT_BANNER_FAILED, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_BANNER_CLICK", tolua_TGSDK_EVENT_BANNER_CLICK, nullptr);
        tolua_variable(tolua_S, "TGSDK_EVENT_BANNER_CLOSE", tolua_TGSDK_EVENT_BANNER_CLOSE, nullptr);
        tolua_variable(tolua_S, "TGPAYINGUSER_NON_PAYING_USER", tolua_TGPAYINGUSER_NON_PAYING_USER, nullptr);
        tolua_variable(tolua_S, "TGPAYINGUSER_SMALL_PAYMENT_USER", tolua_TGPAYINGUSER_SMALL_PAYMENT_USER, nullptr);
        tolua_variable(tolua_S, "TGPAYINGUSER_MEDIUM_PAYMENT_USER", tolua_TGPAYINGUSER_MEDIUM_PAYMENT_USER, nullptr);
        tolua_variable(tolua_S, "TGPAYINGUSER_LARGE_PAYMENT_USER", tolua_TGPAYINGUSER_LARGE_PAYMENT_USER, nullptr);
        tolua_variable(tolua_S, "TGSDK_BANNER_TYPE_NORMAL", tolua_TGSDK_BANNER_TYPE_NORMAL, nullptr);
        tolua_variable(tolua_S, "TGSDK_BANNER_TYPE_MEDIUM", tolua_TGSDK_BANNER_TYPE_MEDIUM, nullptr);
        tolua_variable(tolua_S, "TGSDK_BANNER_TYPE_LARGE", tolua_TGSDK_BANNER_TYPE_LARGE, nullptr);
        tolua_function(tolua_S, "setSDKConfig", tolua_TGSDK_function_setSDKConfig);
        tolua_function(tolua_S, "getSDKConfig", tolua_TGSDK_function_getSDKConfig);
        tolua_function(tolua_S, "setDebugModel", tolua_TGSDK_function_setDebugModel);
        tolua_function(tolua_S, "initialize", tolua_TGSDK_function_initialize);
        tolua_function(tolua_S, "isWIFI", tolua_TGSDK_function_isWIFI);
        tolua_function(tolua_S, "preload", tolua_TGSDK_function_preload);
        tolua_function(tolua_S, "parameterFromAdScene", tolua_TGSDK_function_parameterFromAdScene);
        tolua_function(tolua_S, "setBannerConfig", tolua_TGSDK_function_setBannerConfig);
        tolua_function(tolua_S, "couldShowAd", tolua_TGSDK_function_couldShowAd);
        tolua_function(tolua_S, "showAd", tolua_TGSDK_function_showAd);
        tolua_function(tolua_S, "showTestView", tolua_TGSDK_function_showTestView);
        tolua_function(tolua_S, "closeBanner", tolua_TGSDK_function_closeBanner);
        tolua_function(tolua_S, "reportAdRejected", tolua_TGSDK_function_reportAdRejected);
        tolua_function(tolua_S, "showAdScene", tolua_TGSDK_function_showAdScene);
        tolua_function(tolua_S, "sendCounter", tolua_TGSDK_function_sendCounter);
        tolua_function(tolua_S, "tagPayingUser", tolua_TGSDK_function_tagPayingUser);
        tolua_function(tolua_S, "getUserGDPRConsentStatus", tolua_TGSDK_function_getUserGDPRConsentStatus);
        tolua_function(tolua_S, "setUserGDPRConsentStatus", tolua_TGSDK_function_setUserGDPRConsentStatus);
        tolua_function(tolua_S, "getIsAgeRestrictedUser", tolua_TGSDK_function_getIsAgeRestrictedUser);
        tolua_function(tolua_S, "setIsAgeRestrictedUser", tolua_TGSDK_function_setIsAgeRestrictedUser);
      tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
	return 1;
}
#endif



#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
extern "C" {
    void Java_com_soulgame_sgsdk_tgsdklib_cocos2dx_TGSDKCocos2dxHelper_onEvent(JNIEnv *env, jobject thiz, jstring jevent, jstring jresult) {
        std::string event = __tgsdk_jstring_to_stdstring(env, jevent);
        std::string result = __tgsdk_jstring_to_stdstring(env, jresult);
        TGSDKCocos2dxHelper::handleEvent(event, result);
    }
}
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
@interface TGSDKCocos2dxHelperiOSDelegate : NSObject<TGPreloadADDelegate, TGADDelegate, TGRewardVideoADDelegate, TGBannerADDelegate>
@end
@implementation TGSDKCocos2dxHelperiOSDelegate

+ (TGSDKCocos2dxHelperiOSDelegate*) getInstance {
    static TGSDKCocos2dxHelperiOSDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) onPreloadSuccess:(NSString* _Nullable)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_PRELOAD_SUCCESS, (result?[result UTF8String]:""));
}

- (void) onPreloadFailed:(NSString* _Nullable)result WithError:(NSError* _Nullable) error {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_PRELOAD_FAILED, (error?[[error description] UTF8String]:""));
}

- (void) onCPADLoaded:(NSString* _Nonnull) result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_CPAD_LOADED, (result?[result UTF8String]:""));
}

- (void) onVideoADLoaded:(NSString* _Nonnull) result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_VIDEOAD_LOADED, (result?[result UTF8String]:""));
}

- (void) onShowSuccess:(NSString* _Nonnull)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_AD_SHOW_SUCCESS, (result?[result UTF8String]:""));
}

- (void) onShowFailed:(NSString* _Nonnull)result WithError:(NSError* _Nullable)error {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_AD_SHOW_FAILED, (error?[[error description] UTF8String]:""));
}

- (void) onADComplete:(NSString* _Nonnull)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_AD_COMPLETE, (result?[result UTF8String]:""));
}

- (void) onADClick:(NSString* _Nonnull)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_AD_CLICK, (result?[result UTF8String]:""));
}

- (void) onADClose:(NSString* _Nonnull)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_AD_CLOSE, (result?[result UTF8String]:""));
}

- (void) onADAwardSuccess:(NSString* _Nonnull)result {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_REWARD_SUCCESS, (result?[result UTF8String]:""));
}

- (void) onADAwardFailed:(NSString* _Nonnull)result WithError:(NSError* _Nullable)error {
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_REWARD_FAILED, (error?[[error description] UTF8String]:""));
}

- (void) onBanner:(NSString* _Nonnull)scene Loaded:(NSString* _Nonnull)result {
    NSString* msg = [NSString stringWithFormat:@"%@|%@", scene, result];
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_BANNER_LOADED, [msg UTF8String]);
}

- (void) onBanner:(NSString* _Nonnull)scene Failed:(NSString* _Nonnull)result WithError:(NSError* _Nullable)error {
    NSString* msg = [NSString stringWithFormat:@"%@|%@|%@", scene, result, (error?[error description]:@"")];
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_BANNER_FAILED, [msg UTF8String]);
}

- (void) onBanner:(NSString* _Nonnull)scene Click:(NSString* _Nonnull)result {
    NSString* msg = [NSString stringWithFormat:@"%@|%@", scene, result];
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_BANNER_CLICK, [msg UTF8String]);
}

- (void) onBanner:(NSString* _Nonnull)scene Close:(NSString* _Nonnull)result {
    NSString* msg = [NSString stringWithFormat:@"%@|%@", scene, result];
    TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_BANNER_CLOSE, [msg UTF8String]);
}

@end
#endif

void TGSDKCocos2dxHelper::setDebugModel(bool debug) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "setDebugModel",
                                                 "(Z)V"
                                                 );
    if (isHave) {
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        debug);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni setDebugModel not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setDebugModel:(debug?YES:NO)];
#endif
}

void TGSDKCocos2dxHelper::setSDKConfig(const std::string key, const std::string val) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "setSDKConfig",
                                                 "(Ljava/lang/String;Ljava/lang/String;)V");
    if (isHave) {
        jstring jkey = minfo.env->NewStringUTF(key.c_str());
        jstring jval = minfo.env->NewStringUTF(val.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jkey,
                                        jval);
        minfo.env->DeleteLocalRef(jkey);
        minfo.env->DeleteLocalRef(jval);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDK jni setSDKConfig( key, val ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setSDKConfig:[NSString stringWithUTF8String:val.c_str()]
                 forKey:[NSString stringWithUTF8String:key.c_str()]];
#endif
}

std::string TGSDKCocos2dxHelper::getSDKConfig(const std::string key) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                             minfo,
                                             JTGSDKClass,
                                             "getSDKConfig",
                                             "(Ljava/lang/String;)Ljava/lang/String;"
    );
    if (isHave) {
        jstring jkey = minfo.env->NewStringUTF(key.c_str());
        jstring jval = (jstring)minfo.env->CallStaticObjectMethod(
                                                         minfo.classID,
                                                         minfo.methodID,
                                                         jkey
        );
        std::string val = JniHelper::jstring2string(jval);
        minfo.env->DeleteLocalRef(jkey);
        minfo.env->DeleteLocalRef(jval);
        minfo.env->DeleteLocalRef(minfo.classID);
        return val;
    } else {
        LOGD("TGSDK jni getSDKConfig( key ) not found");
    }
    return "";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    NSString *val = [TGSDK getSDKConfig:[NSString stringWithUTF8String:key.c_str()]];
    return (val?[val UTF8String]:"");
#endif
}

void TGSDKCocos2dxHelper::initialize() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "initialize",
                                                 "(V)V"
    );
    if (isHave) {
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID
        );
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni initialize not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK initialize:^(BOOL success, id  _Nullable tag, NSDictionary * _Nullable result) {
        if (success) {
            TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_SUCCESS, "");
        } else {
            TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_FAILED, "");
        }
    }];
#endif
}

void TGSDKCocos2dxHelper::initialize(const std::string appid) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "initialize",
                                                 "(Ljava/lang/String;)V");
    if (isHave) {
        jstring jappid = minfo.env->NewStringUTF(appid.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jappid);
        minfo.env->DeleteLocalRef(jappid);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni initialize( appid ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK initialize:[NSString stringWithUTF8String:appid.c_str()]
             callback:^(BOOL success, id  _Nullable tag, NSDictionary * _Nullable result) {
                 if (success) {
                     TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_SUCCESS, "");
                 } else {
                     TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_FAILED, "");
                 }
             }];
#endif
}

void TGSDKCocos2dxHelper::initialize(const std::string appid, const std::string channelid) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "initialize",
                                                 "(Ljava/lang/String;Ljava/lang/String;)V");
    if (isHave) {
        jstring jappid = minfo.env->NewStringUTF(appid.c_str());
        jstring jchannelid = minfo.env->NewStringUTF(channelid.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jappid,
                                        jchannelid);
        minfo.env->DeleteLocalRef(jappid);
        minfo.env->DeleteLocalRef(jchannelid);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni initialize( appid, channelid ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK initialize:[NSString stringWithUTF8String:appid.c_str()]
            channelID:[NSString stringWithUTF8String:channelid.c_str()]
             callback:^(BOOL success, id  _Nullable tag, NSDictionary * _Nullable result) {
                 if (success) {
                     TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_SUCCESS, "");
                 } else {
                     TGSDKCocos2dxHelper::handleEvent(TGSDK_EVENT_INIT_FAILED, "");
                 }
             }];
#endif
}

int TGSDKCocos2dxHelper::isWIFI() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "isWIFI",
                                                 "()I"
    );
    if (isHave) {
        jint jret = minfo.env->CallStaticIntMethod(
                                        minfo.classID,
                                        minfo.methodID
        );
        minfo.env->DeleteLocalRef(minfo.classID);
        return (int)jret;
    } else {
        LOGD("TGSDKCocos2dxHelper jni isWIFI() not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    return [TGSDK isWIFI];
#endif
    return 2;
}

void TGSDKCocos2dxHelper::preload() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "preload",
                                                 "()V"
    );
    if (isHave) {
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID
        );
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni preload() not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setADDelegate:[TGSDKCocos2dxHelperiOSDelegate getInstance]];
    [TGSDK setRewardVideoADDelegate:[TGSDKCocos2dxHelperiOSDelegate getInstance]];
    [TGSDK setBannerDelegate:[TGSDKCocos2dxHelperiOSDelegate getInstance]];
    [TGSDK preloadAd:[TGSDKCocos2dxHelperiOSDelegate getInstance]];
#endif
}

int TGSDKCocos2dxHelper::getIntParameterFromAdScene(const std::string scene, const std::string key, int def) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "getIntParameterFromAdScene",
                                                 "(Ljava/lang/String;Ljava/lang/String;I)I"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        jstring jkey = minfo.env->NewStringUTF(key.c_str());
        jint jret = minfo.env->CallStaticIntMethod(
                                                           minfo.classID,
                                                           minfo.methodID,
                                                           jscene,
                                                           jkey,
                                                           (jint)def);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(jkey);
        minfo.env->DeleteLocalRef(minfo.classID);
        return (int)jret;
    } else {
        LOGD("TGSDKCocos2dxHelper jni getIntParameterFromAdScene() not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    id ret = [TGSDK parameterFromAdScene:[NSString stringWithUTF8String:scene.c_str()]
                                 WithKey:[NSString stringWithUTF8String:key.c_str()]];
    if (ret && [ret isKindOfClass:[NSNumber class]]) {
        return [ret intValue];
    }
    LOGD("Get parameter from AD scene error : %s %s", key.c_str(), (ret?"is not number":"not found"));
    return def;
#endif
}

float TGSDKCocos2dxHelper::getFloatParameterFromAdScene(const std::string scene, const std::string key, float def) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "getFloatParameterFromAdScene",
                                                 "(Ljava/lang/String;Ljava/lang/String;F)F"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        jstring jkey = minfo.env->NewStringUTF(key.c_str());
        jfloat jret = minfo.env->CallStaticFloatMethod(
                                                           minfo.classID,
                                                           minfo.methodID,
                                                           jscene,
                                                           jkey,
                                                           (jfloat)def);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(jkey);
        minfo.env->DeleteLocalRef(minfo.classID);
        return (float)jret;
    } else {
        LOGD("TGSDKCocos2dxHelper jni getIntParameterFromAdScene() not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    id ret = [TGSDK parameterFromAdScene:[NSString stringWithUTF8String:scene.c_str()]
                                 WithKey:[NSString stringWithUTF8String:key.c_str()]];
    if (ret && [ret isKindOfClass:[NSNumber class]]) {
        return [ret floatValue];
    }
    LOGD("Get parameter from AD scene error : %s %s", key.c_str(), (ret?"is not number":"not found"));
    return def;
#endif
}

std::string TGSDKCocos2dxHelper::getStringParameterFromAdScene(const std::string scene, const std::string key, const std::string def) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                             minfo,
                                             JTGSDKCocos2dxHelper,
                                             "getStringParameterFromAdScene",
                                             "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        jstring jkey = minfo.env->NewStringUTF(key.c_str());
        jstring jdef = minfo.env->NewStringUTF(def.c_str());
        jstring jval = (jstring)minfo.env->CallStaticObjectMethod(
                                                         minfo.classID,
                                                         minfo.methodID,
                                                         jscene,
                                                         jkey,
                                                         jdef
        );
        std::string val = JniHelper::jstring2string(jval);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(jkey);
        minfo.env->DeleteLocalRef(jdef);
        minfo.env->DeleteLocalRef(jval);
        minfo.env->DeleteLocalRef(minfo.classID);
        return val;
    } else {
        LOGD("TGSDK jni getStringParameterFromAdScene( key ) not found");
        return def;
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    id ret = [TGSDK parameterFromAdScene:[NSString stringWithUTF8String:scene.c_str()]
                                 WithKey:[NSString stringWithUTF8String:key.c_str()]];
    if (ret && [ret isKindOfClass:[NSString class]]) {
        return ([ret UTF8String]);
    }  else if (ret && [ret isKindOfClass:[NSNumber class]]) {
        return ([[ret stringValue] UTF8String]);
    }
    LOGD("Get parameter from AD scene error : %s %s", key.c_str(), (ret?"is not string":"not found"));
    return (char*)(def.c_str());
#endif
}

void TGSDKCocos2dxHelper::setBannerConfig(const std::string scene, const std::string type, float x, float y, float width, float height, int interval) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "setBannerConfig",
                                                 "(Ljava/lang/String;Ljava/lang/String;FFFFI)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        jstring jtype = minfo.env->NewStringUTF(type.c_str());
        jboolean jret = minfo.env->CallStaticBooleanMethod(
                                                           minfo.classID,
                                                           minfo.methodID,
                                                           jscene, jtype, x, y, width, height, interval);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(jtype);
        minfo.env->DeleteLocalRef(minfo.classID);
        LOGD("TGSDKCocos2dxHelper setBannerConfig(%s, %s, %f, %f, %f, %f, %d)", scene.c_str(), type.c_str(), x, y, width, height, interval);
    } else {
        LOGD("TGSDKCocos2dxHelper jni setBannerConfig( scene, type, x, y, w, h, i ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    TGBannerType bannerType;
    if (type.compare(TGSDK_BANNER_TYPE_NORMAL) == 0) {
        bannerType = TGBannerNormal;
    } else if (type.compare(TGSDK_BANNER_TYPE_LARGE) == 0) {
        bannerType = TGBannerLarge;
    } else if (type.compare(TGSDK_BANNER_TYPE_MEDIUM) == 0) {
        bannerType = TGBannerMediumRectangle;
    } else {
        bannerType = TGBannerNormal;
    }
#ifdef TGSDK_BIND_COCOS_CREATOR
    CGFloat __TGSDK_screenScaleFactor = 1.0;
#else
    float sWidth = cocos2d::Director::getInstance()->getOpenGLView()->getFrameSize().width;
    LOGD("TGSDKCocos2dxHelper setBannerConfig screen width = %f", sWidth);
    CGFloat __TGSDK_screenScaleFactor = (sWidth / [[UIScreen mainScreen] bounds].size.width);
    LOGD("TGSDKCocos2dxHelper setBannerConfig scale factor = %f", __TGSDK_screenScaleFactor);
#endif
    x /= __TGSDK_screenScaleFactor;
    y /= __TGSDK_screenScaleFactor;
    width /= __TGSDK_screenScaleFactor;
    height /= __TGSDK_screenScaleFactor;
    [TGSDK setBanner:[NSString stringWithUTF8String:scene.c_str()] Config:bannerType
                   x:x y:y width:width height:height Interval:interval];
    LOGD("TGSDKCocos2dxHelper setBannerConfig(%s, %s, %f, %f, %f, %f, %d)", scene.c_str(), type.c_str(), x, y, width, height, interval);
#endif
}

bool TGSDKCocos2dxHelper::couldShowAd(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "couldShowAd",
                                                 "(Ljava/lang/String;)Z"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        jboolean jret = minfo.env->CallStaticBooleanMethod(
                                                           minfo.classID,
                                                           minfo.methodID,
                                                           jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
        return (jret?true:false);
    } else {
        LOGD("TGSDKCocos2dxHelper jni couldShowAd( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    BOOL ret = [TGSDK couldShowAd:[NSString stringWithUTF8String:scene.c_str()]];
    return (ret?true:false);
#endif
    return false;
}

void TGSDKCocos2dxHelper::showAd(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "showAd",
                                                 "(Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni showAd( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK showAd:[NSString stringWithUTF8String:scene.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::showTestView(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "showTestView",
                                                 "(Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni showTestView( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK showTestView:[NSString stringWithUTF8String:scene.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::closeBanner(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "closeBanner",
                                                 "(Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni closeBanner( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK closeBanner:[NSString stringWithUTF8String:scene.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::reportAdRejected(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "reportAdRejected",
                                                 "(Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDK jni reportAdRejected( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK reportAdRejected:[NSString stringWithUTF8String:scene.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::showAdScene(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "showAdScene",
                                                 "(Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jscene = minfo.env->NewStringUTF(scene.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jscene);
        minfo.env->DeleteLocalRef(jscene);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDK jni showAdScene( scene ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK showAdScene:[NSString stringWithUTF8String:scene.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::sendCounter(const std::string name, const std::string metaData) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKCocos2dxHelper,
                                                 "sendCounter",
                                                 "(Ljava/lang/String;Ljava/lang/String;)V"
    );
    if (isHave) {
        jstring jname = minfo.env->NewStringUTF(name.c_str());
        jstring jmetadata = minfo.env->NewStringUTF(metaData.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jname,
                                        jmetadata);
        minfo.env->DeleteLocalRef(jname);
        minfo.env->DeleteLocalRef(jmetadata);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni sendCounter( name, metaData ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK sendCounter:[NSString stringWithUTF8String:name.c_str()]
           metaDataJson:[NSString stringWithUTF8String:metaData.c_str()]];
#endif
}

void TGSDKCocos2dxHelper::tagPayingUser(TGSDKCocosedxPayingUser user, const std::string currency, float currentAmount, float totalAmount) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                minfo,
                                                JTGSDKCocos2dxHelper,
                                                "tagPayingUser",
                                                "(Ljava/lang/String;Ljava/lang/String;FF)V"
    );
    if (isHave) {
        jstring juser;
        jstring jcurrency;
        switch(user) {
        case TGSDKCocos2dxNonPayingUser:
            juser = minfo.env->NewStringUTF("none");
            break;
        case TGSDKCocos2dxSmallPaymentUser:
            juser = minfo.env->NewStringUTF("small");
            break;
        case TGSDKCocos2dxMediumPaymentUser:
            juser = minfo.env->NewStringUTF("medium");
            break;
        case TGSDKCocos2dxLargePaymentUser:
            juser = minfo.env->NewStringUTF("large");
            break;
        default:
            return;
        }
        jcurrency = minfo.env->NewStringUTF(currency.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        juser,
                                        jcurrency,
                                        currentAmount,
                                        totalAmount);
        minfo.env->DeleteLocalRef(juser);
        minfo.env->DeleteLocalRef(jcurrency);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni tagPayingUser( (Ljava/lang/String;Ljava/lang/String;FF)V ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    switch (user) {
    case TGSDKCocos2dxNonPayingUser:
        [TGSDK tagPayingUser:TGNonPayingUser
                WithCurrency:[NSString stringWithUTF8String:currency.c_str()]
            AndCurrentAmount:currentAmount
              AndTotalAmount:totalAmount];
        break;
    case TGSDKCocos2dxSmallPaymentUser:
        [TGSDK tagPayingUser:TGSmallPaymentUser
                WithCurrency:[NSString stringWithUTF8String:currency.c_str()]
            AndCurrentAmount:currentAmount
              AndTotalAmount:totalAmount];
        break;
    case TGSDKCocos2dxMediumPaymentUser:
        [TGSDK tagPayingUser:TGMediumPaymentUser
                WithCurrency:[NSString stringWithUTF8String:currency.c_str()]
            AndCurrentAmount:currentAmount
              AndTotalAmount:totalAmount];
        break;
    case TGSDKCocos2dxLargePaymentUser:
        [TGSDK tagPayingUser:TGLargePaymentUser
                WithCurrency:[NSString stringWithUTF8String:currency.c_str()]
            AndCurrentAmount:currentAmount
              AndTotalAmount:totalAmount];
        break;
    }
#endif
}

void TGSDKCocos2dxHelper::setUserGDPRConsentStatus(const std::string status) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "setUserGDPRConsentStatus",
                                                 "(Ljava/lang/String;)V");
    if (isHave) {
        jstring jstatus = minfo.env->NewStringUTF(status.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jstatus);
        minfo.env->DeleteLocalRef(jstatus);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDK jni setUserGDPRConsentStatus( status ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setUserGDPRConsentStatus:[NSString stringWithUTF8String:status.c_str()]];
#endif
}

std::string TGSDKCocos2dxHelper::getUserGDPRConsentStatus() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                             minfo,
                                             JTGSDKClass,
                                             "getUserGDPRConsentStatus",
                                             "()Ljava/lang/String;"
    );
    if (isHave) {
        jstring jstatus = (jstring)minfo.env->CallStaticObjectMethod(
                                                         minfo.classID,
                                                         minfo.methodID);
        std::string status = JniHelper::jstring2string(jstatus);
        minfo.env->DeleteLocalRef(jstatus);
        minfo.env->DeleteLocalRef(minfo.classID);
        return status;
    } else {
        LOGD("TGSDK jni getUserGDPRConsentStatus() not found");
    }
    return "";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    NSString *status = [TGSDK getUserGDPRConsentStatus];
    return (status?[status UTF8String]:"");
#endif
}

void TGSDKCocos2dxHelper::setIsAgeRestrictedUser(const std::string status) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 minfo,
                                                 JTGSDKClass,
                                                 "setIsAgeRestrictedUser",
                                                 "(Ljava/lang/String;)V");
    if (isHave) {
        jstring jstatus = minfo.env->NewStringUTF(status.c_str());
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID,
                                        jstatus);
        minfo.env->DeleteLocalRef(jstatus);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDK jni setIsAgeRestrictedUser( status ) not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setIsAgeRestrictedUser:[NSString stringWithUTF8String:status.c_str()]];
#endif
}

std::string TGSDKCocos2dxHelper::getIsAgeRestrictedUser() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                             minfo,
                                             JTGSDKClass,
                                             "getIsAgeRestrictedUser",
                                             "()Ljava/lang/String;"
    );
    if (isHave) {
        jstring jstatus = (jstring)minfo.env->CallStaticObjectMethod(
                                                         minfo.classID,
                                                         minfo.methodID);
        std::string status = JniHelper::jstring2string(jstatus);
        minfo.env->DeleteLocalRef(jstatus);
        minfo.env->DeleteLocalRef(minfo.classID);
        return status;
    } else {
        LOGD("TGSDK jni getIsAgeRestrictedUser() not found");
    }
    return "";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    NSString *status = [TGSDK getIsAgeRestrictedUser];
    return (status?[status UTF8String]:"");
#endif
}

#ifdef TGSDK_COCOS2DX_2X
static TGSDKCocos2dxSDKDelegate* __tgsdk_sdk_delegate = NULL;
static TGSDKCocos2dxPreloadDelegate* __tgsdk_preload_delegate = NULL;
static TGSDKCocos2dxADDelegate* __tgsdk_ad_delegate = NULL;
static TGSDKCocos2dxRewardDelegate* __tgsdk_reward_delegate = NULL;
static TGSDKCocos2dxBannerDelegate* __tgsdk_banner_delegate = NULL;
void TGSDKCocos2dxHelper::setSDKDelegate(TGSDKCocos2dxSDKDelegate *delegate) {
    __tgsdk_sdk_delegate = delegate;
}
void TGSDKCocos2dxHelper::setPreloadDelegate(TGSDKCocos2dxPreloadDelegate *delegate) {
    __tgsdk_preload_delegate = delegate;
}
void TGSDKCocos2dxHelper::setADDelegate(TGSDKCocos2dxADDelegate *delegate) {
    __tgsdk_ad_delegate = delegate;
}
void TGSDKCocos2dxHelper::setRewardDelegate(TGSDKCocos2dxRewardDelegate *delegate) {
    __tgsdk_reward_delegate = delegate;
}
void TGSDKCocos2dxHelper::setBannerDelegate(TGSDKCocos2dxBannerDelegate *delegate) {
    __tgsdk_banner_delegate = delegate;
}
#endif


void TGSDKCocos2dxHelper::handleEvent(const std::string event, const std::string result) {
#ifdef TGSDK_COCOS2DX_2X
    if (event.compare(TGSDK_EVENT_INIT_SUCCESS) == 0) {
        if (__tgsdk_sdk_delegate) {
            __tgsdk_sdk_delegate->onInitSuccess(result);
        }
    } else if (event.compare(TGSDK_EVENT_INIT_FAILED) == 0) {
        if (__tgsdk_sdk_delegate) {
            __tgsdk_sdk_delegate->onInitFailed(result);
        }
    } else if (event.compare(TGSDK_EVENT_PRELOAD_SUCCESS) == 0) {
        if (__tgsdk_preload_delegate) {
            __tgsdk_preload_delegate->onPreloadSuccess(result);
        }
    } else if (event.compare(TGSDK_EVENT_PRELOAD_FAILED) == 0) {
        if (__tgsdk_preload_delegate) {
            __tgsdk_preload_delegate->onPreloadFailed(result);
        }
    } else if (event.compare(TGSDK_EVENT_CPAD_LOADED) == 0) {
        if (__tgsdk_preload_delegate) {
            __tgsdk_preload_delegate->onCPADLoaded(result);
        }
    } else if (event.compare(TGSDK_EVENT_VIDEOAD_LOADED) == 0) {
        if (__tgsdk_preload_delegate) {
            __tgsdk_preload_delegate->onVideoADLoaded(result);
        }
    } else if (event.compare(TGSDK_EVENT_AD_SHOW_SUCCESS) == 0) {
        if (__tgsdk_ad_delegate) {
            __tgsdk_ad_delegate->onShowSuccess(result);
        }
    } else if (event.compare(TGSDK_EVENT_AD_SHOW_FAILED) == 0) {
        if (__tgsdk_ad_delegate) {
            __tgsdk_ad_delegate->onShowFailed(result);
        }
    } else if (event.compare(TGSDK_EVENT_AD_COMPLETE) == 0) {
        if (__tgsdk_ad_delegate) {
            __tgsdk_ad_delegate->onADComplete(result);
        }
    } else if (event.compare(TGSDK_EVENT_AD_CLICK) == 0) {
        if (__tgsdk_ad_delegate) {
            __tgsdk_ad_delegate->onADClick(result);
        }
    } else if (event.compare(TGSDK_EVENT_AD_CLOSE) == 0) {
        if (__tgsdk_ad_delegate) {
            __tgsdk_ad_delegate->onADClose(result);
        }
    } else if (event.compare(TGSDK_EVENT_REWARD_SUCCESS) == 0) {
        if (__tgsdk_reward_delegate) {
            __tgsdk_reward_delegate->onADAwardSuccess(result);
        }
    } else if (event.compare(TGSDK_EVENT_REWARD_FAILED) == 0) {
        if (__tgsdk_reward_delegate) {
            __tgsdk_reward_delegate->onADAwardFailed(result);
        }
    } else if (event.compare(TGSDK_EVENT_BANNER_LOADED) == 0) {
        if (__tgsdk_banner_delegate) {
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            __tgsdk_banner_delegate->onBannerLoaded(scene, ret);
        }
    } else if (event.compare(TGSDK_EVENT_BANNER_FAILED) == 0) {
        if (__tgsdk_banner_delegate) {
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::size_t fret = result.find("|", fscene+1);
            std::string ret = result.substr(fscene+1, fret);
            std::string err = result.substr(fret+1);
            __tgsdk_banner_delegate->onBannerFailed(scene, ret, err);
        }
    } else if (event.compare(TGSDK_EVENT_BANNER_CLICK) == 0) {
        if (__tgsdk_banner_delegate) {
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            __tgsdk_banner_delegate->onBannerClick(scene, ret);
        }
    } else if (event.compare(TGSDK_EVENT_BANNER_CLOSE) == 0) {
        if (__tgsdk_banner_delegate) {
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            __tgsdk_banner_delegate->onBannerClose(scene, ret);
        }
    }
#else
#ifdef TGSDK_BIND_COCOS_CREATOR
    CustomEvent customEvent;
    customEvent.name = event;
    EventDispatcher::dispatchCustomEvent(customEvent);
    cocos2d::Application::getInstance()->getScheduler()->performFunctionInCocosThread([&, event, result]{
        std::string cb = event;
        cb.replace(0, 6, "");
        LOGD("Event listener TGSDK.%s ( %s ) will be called", cb.c_str(), result.c_str());
        se::ValueArray args;
        se::Value callback;
        bool ok = true;
        bool found = jsb_TGSDK_class->getProto()->getProperty(cb.c_str(), &callback);
        if (!found) {
            LOGD("Callback Function yomob.TGSDK.__proto__.%s ( %s ) not found...", cb.c_str(), result.c_str());
            return;
        }
        if (event.compare(TGSDK_EVENT_BANNER_LOADED) == 0 ||
            event.compare(TGSDK_EVENT_BANNER_CLICK) == 0 ||
            event.compare(TGSDK_EVENT_BANNER_CLOSE) == 0 ) {
            
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            
            args.resize(2);
            ok &= std_string_to_seval(scene, &args[0]);
            ok &= std_string_to_seval(ret, &args[1]);
        } else if (event.compare(TGSDK_EVENT_BANNER_FAILED) == 0) {
            
            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::size_t fret = result.find("|", fscene+1);
            std::string ret = result.substr(fscene+1, fret);
            std::string err = result.substr(fret+1);
            
            args.resize(3);
            ok &= std_string_to_seval(scene, &args[0]);
            ok &= std_string_to_seval(ret, &args[1]);
            ok &= std_string_to_seval(err, &args[2]);
        } else {
            args.resize(1);
            ok &= std_string_to_seval(result, &args[0]);
        }
        if (ok) {
            callback.toObject()->call(args, callback.toObject());
        } else {
            SE_PRECONDITION2_VOID(ok, "JSB TGSDK.%s ( %s ): Error processing arguments", cb.c_str(), result.c_str());
        }
    });
#else
    cocos2d::EventCustom customEvent(event);
    customEvent.setUserData((void*) result.c_str());
    auto dispatcher = cocos2d::Director::getInstance()->getEventDispatcher();
    dispatcher->dispatchEvent(&customEvent);
#endif
#endif
#ifdef TGSDK_BIND_JS
    Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, event, result]{
        JSContext *cx = ScriptingCore::getInstance()->getGlobalContext();
        std::string cb = event;
        cb.replace(0, 6, "");
        LOGD("Event listener TGSDK.%s ( %s ) will be called", cb.c_str(), result.c_str());
        int call_argc = 1;
        if (event.compare(TGSDK_EVENT_BANNER_LOADED) == 0 || 
            event.compare(TGSDK_EVENT_BANNER_CLICK) == 0 || 
            event.compare(TGSDK_EVENT_BANNER_CLOSE) == 0 ) {

            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            call_argc = 2;

            jsval v[] = { std_string_to_jsval(cx, scene), std_string_to_jsval(cx, ret) };
            ScriptingCore::getInstance()->executeFunctionWithOwner(OBJECT_TO_JSVAL(jsb_TGSDK_prototype), cb.c_str(), call_argc, v);
        } else if (event.compare(TGSDK_EVENT_BANNER_FAILED) == 0) {

            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::size_t fret = result.find("|", fscene+1);
            std::string ret = result.substr(fscene+1, fret);
            std::string err = result.substr(fret+1);
            call_argc = 3;

            jsval v[] = { std_string_to_jsval(cx, scene), std_string_to_jsval(cx, ret), std_string_to_jsval(cx, err) };
            ScriptingCore::getInstance()->executeFunctionWithOwner(OBJECT_TO_JSVAL(jsb_TGSDK_prototype), cb.c_str(), call_argc, v);
        } else {
            jsval v[] = { std_string_to_jsval(cx, result) };
            ScriptingCore::getInstance()->executeFunctionWithOwner(OBJECT_TO_JSVAL(jsb_TGSDK_prototype), cb.c_str(), call_argc, v);
        }
    });
#endif
#ifdef TGSDK_BIND_LUA
    Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, event, result]{
        std::string cb = event;
        cb.replace(0, 6, "");
        LOGD("Event listener TGSDK.%s ( %s ) called", cb.c_str(), result.c_str());
        auto engine = LuaEngine::getInstance();
        lua_State* L = engine->getLuaStack()->getLuaState();
        lua_getglobal(L, "yomob");
        lua_getfield(L, -1, "TGSDK");
        lua_getfield(L, -1, cb.c_str());
        int call_argc = 1;
        if (event.compare(TGSDK_EVENT_BANNER_LOADED) == 0 || 
            event.compare(TGSDK_EVENT_BANNER_CLICK) == 0 || 
            event.compare(TGSDK_EVENT_BANNER_CLOSE) == 0 ) {

            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::string ret = result.substr(fscene+1);
            call_argc = 2;

            lua_pushstring(L, scene.c_str());
            lua_pushstring(L, ret.c_str());

        } else if (event.compare(TGSDK_EVENT_BANNER_FAILED) == 0) {

            std::size_t fscene = result.find("|");
            std::string scene = result.substr(0, fscene);
            std::size_t fret = result.find("|", fscene+1);
            std::string ret = result.substr(fscene+1, fret);
            std::string err = result.substr(fret+1);
            call_argc = 3;

            lua_pushstring(L, scene.c_str());
            lua_pushstring(L, ret.c_str());
            lua_pushstring(L, err.c_str());
        } else {
            lua_pushstring(L, result.c_str());
        }
        int error = lua_pcall(L, call_argc, 0, 0);
        if (error) {
            LOGD("Lua TGSDK.%s Error: %s", cb.c_str(), lua_tostring(L, -1));
            lua_pop(L, 1);
        }
    });
#endif
}

void TGSDKCocos2dxHelper::bindScript() {
#ifdef TGSDK_BIND_JS
    ScriptingCore* sc = ScriptingCore::getInstance();
    sc->addRegisterCallback(register_jsb_tgsdk);
#endif
#ifdef TGSDK_BIND_LUA
    auto engine = LuaEngine::getInstance();
    lua_State* L = engine->getLuaStack()->getLuaState();
    tolua_tgsdk_open(L);
#endif
#ifdef TGSDK_BIND_COCOS_CREATOR
    se::ScriptEngine* se = se::ScriptEngine::getInstance();
    se->addRegisterCallback(register_jsb_tgsdk);
#endif
}
