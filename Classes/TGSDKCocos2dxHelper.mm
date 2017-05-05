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

#ifdef TGSDK_BIND_JS
#include "jsapi.h"
#include "jsfriendapi.h"
#include "scripting/js-bindings/manual/ScriptingCore.h"

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
        JS_FN("couldShowAd", jsb_TGSDK_function_couldShowAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showAd", jsb_TGSDK_function_showAd, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showTestView", jsb_TGSDK_function_showTestView, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("reportAdRejected", jsb_TGSDK_function_reportAdRejected, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("showAdScene", jsb_TGSDK_function_showAdScene, 1, JSPROP_PERMANENT | JSPROP_ENUMERATE),
        JS_FN("sendCounter", jsb_TGSDK_function_sendCounter, 2, JSPROP_PERMANENT | JSPROP_ENUMERATE),
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
        tolua_function(tolua_S, "setSDKConfig", tolua_TGSDK_function_setSDKConfig);
        tolua_function(tolua_S, "getSDKConfig", tolua_TGSDK_function_getSDKConfig);
        tolua_function(tolua_S, "setDebugModel", tolua_TGSDK_function_setDebugModel);
        tolua_function(tolua_S, "initialize", tolua_TGSDK_function_initialize);
        tolua_function(tolua_S, "isWIFI", tolua_TGSDK_function_isWIFI);
        tolua_function(tolua_S, "preload", tolua_TGSDK_function_preload);
        tolua_function(tolua_S, "parameterFromAdScene", tolua_TGSDK_function_parameterFromAdScene);
        tolua_function(tolua_S, "couldShowAd", tolua_TGSDK_function_couldShowAd);
        tolua_function(tolua_S, "showAd", tolua_TGSDK_function_showAd);
        tolua_function(tolua_S, "showTestView", tolua_TGSDK_function_showTestView);
        tolua_function(tolua_S, "reportAdRejected", tolua_TGSDK_function_reportAdRejected);
        tolua_function(tolua_S, "showAdScene", tolua_TGSDK_function_showAdScene);
        tolua_function(tolua_S, "sendCounter", tolua_TGSDK_function_sendCounter);
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


void TGSDKCocos2dxHelper::handleEvent(const std::string event, const std::string result) {
    cocos2d::EventCustom customEvent(event);
    customEvent.setUserData((void*) result.c_str());
    auto dispatcher = cocos2d::Director::getInstance()->getEventDispatcher();
    dispatcher->dispatchEvent(&customEvent);
#ifdef TGSDK_BIND_JS
    Director::getInstance()->getScheduler()->performFunctionInCocosThread([&, event, result]{
        JSContext *cx = ScriptingCore::getInstance()->getGlobalContext();
        jsval v[] = { std_string_to_jsval(cx, result) };
        std::string cb = event;
        cb.replace(0, 6, "");
        LOGD("Event listener TGSDK.%s ( %s ) called", cb.c_str(), result.c_str());
        ScriptingCore::getInstance()->executeFunctionWithOwner(OBJECT_TO_JSVAL(jsb_TGSDK_prototype), cb.c_str(), 1, v);
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
        lua_pushstring(L, result.c_str());
        int error = lua_pcall(L, 1, 0, 0);
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
}
