//
//  TGSDKCocos2dxHelper.cpp
//  tgsdk_cocos_js
//
//  Created by Yomob on 2016/12/15.
//
//

#include "TGSDKCocos2dxHelper.h"

using namespace yomob;

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <android/log.h>
#define  LOG_TAG    "TGSDK"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  JTGSDKCocos2dxHelper "com/soulgame/sgsdk/tgsdklib/cocos2dx/TGSDKCocos2dxHelper"
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "TGSDK.h"
#define LOGD(...) NSLog(@__VA_ARGS__)
#endif

#ifdef TGSDK_BIND_JS
#include "jsapi.h"
#include "jsfriendapi.h"
#include "scripting/js-bindings/manual/ScriptingCore.h"

#define JSTGSDKClass "TGSDK"
JSClass *jsb_TGSDK_class;
JSObject *jsb_TGSDK_prototype;

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
    JS_ReportError(cx, "JSB TGSDK.showAd: Wrong number of arguments");
    return false;
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

bool jsb_TGSDK_function_preload(JSContext* cx, uint32_t argc, jsval* vp) {
    LOGD("JSB TGSDK.preload called");
    JS::CallArgs args = JS::CallArgsFromVp(argc, vp);
    TGSDKCocos2dxHelper::preload();
    args.rval().set(JSVAL_NULL);
    return true;
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

void register_jsb_tgsdk(JSContext* cx, JS::HandleObject global) {
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
        JS_FN("initialize", jsb_TGSDK_function_initialize, 2, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("preload", jsb_TGSDK_function_preload, 0, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("couldShowAd", jsb_TGSDK_function_couldShowAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showAd", jsb_TGSDK_function_showAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FS_END
    };
    
    jsb_TGSDK_prototype = JS_InitClass(cx, global,
                                       JS::NullPtr(),
                                       jsb_TGSDK_class,
                                       jsb_TGSDK_constructor, 0,
                                       nullptr,
                                       nullptr,
                                       nullptr,
                                       funcs);
}
#endif
#ifdef TGSDK_BIND_LUA
#endif



#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
extern "C" {
    void Java_com_soulgame_sgsdk_tgsdklib_cocos2dx_TGSDKCocos2dxHelper_onEvent(JNIEnv *env, jobject thiz, jstring jevent, jstring jresult) {
        std::string event = cocos2d::StringUtils::getStringUTFCharsJNI(env, jevent);
        std::string result = cocos2d::StringUtils::getStringUTFCharsJNI(env, jresult);
        TGSDKCocos2dxHelper::handleEvent(event, result);
    }
}
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
@interface TGSDKCocos2dxHelperiOSDelegate : NSObject<TGPreloadADDelegate, TGADDelegate, TGRewardVideoADDelegate>
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

@end
#endif

void TGSDKCocos2dxHelper::setDebugModel(bool debug) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 JTGSDKCocos2dxHelper,
                                                 "setDebugModel",
                                                 "(Z)V"
                                                 );
    if (isHave) {
        minfo.env->CallStaticVoidMethod(
                                        minfo.classID,
                                        minfo.methodID
                                        debug);
        minfo.env->DeleteLocalRef(minfo.classID);
    } else {
        LOGD("TGSDKCocos2dxHelper jni setDebugModel not found");
    }
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [TGSDK setDebugModel:(debug?YES:NO)];
#endif
}

void TGSDKCocos2dxHelper::initialize() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
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
                                                 JTGSDKCocos2dxHelper,
                                                 "initialize",
                                                 "(Ljava/lang/String;Ljava/lang/String;)V");
    if (isHave) {
        jstring jappid = minfo.env->NewStringUTF(appid.c_str());
        jstring jchannelid = minfo.env->NewStringUTF8(channelid.c_str());
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

void TGSDKCocos2dxHelper::preload() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
                                                 JTGSDKCocos2dxHelper,
                                                 "preload",
                                                 "(V)V"
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
    [TGSDK preloadAd:[TGSDKCocos2dxHelperiOSDelegate getInstance]];
#endif
}

bool TGSDKCocos2dxHelper::couldShowAd(const std::string scene) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(
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
        return (jboolean?true:false);
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

void TGSDKCocos2dxHelper::handleEvent(const std::string event, const std::string result) {
    cocos2d::EventCustom customEvent(event);
    customEvent.setUserData((void*) result.c_str());
    auto dispatcher = cocos2d::Director::getInstance()->getEventDispatcher();
    dispatcher->dispatchEvent(&customEvent);
}

void TGSDKCocos2dxHelper::bindScript() {
#ifdef TGSDK_BIND_JS
    ScriptingCore* sc = ScriptingCore::getInstance();
    sc->addRegisterCallback(register_jsb_tgsdk);
#endif
#ifdef TGSDK_BIND_LUA
#endif
}
