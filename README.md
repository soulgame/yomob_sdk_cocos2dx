# Yomob SDK for Cocos2d-x【1.8.5】

>**【注意】由于 `1.8.4` 版本删除了被标记为 `deprecated` 的接口和方法，如果使用以前版本的 TGSDK 接入会无法成功编译，请尽快升级你的 TGSDK 到 1.8.4 版本或使用 Tag 为 1.8.4 之前的 Cocos2d-x 封装代码来兼容以前的版本**


>**【注意】由于 `1.8.3` 版本更改了广告行为事件通知的结构，如果使用以前版本的 TGSDK 接入会无法成功编译，请尽快升级你的 TGSDK 到 1.8.3 版本或使用 Tag 为 1.8.3 之前的 Cocos2d-x 封装代码来兼容以前的版本**

>**【注意】由于 `1.8.1` 版本新增了 Banner 广告支持，如果使用以前版本的 TGSDK 接入会由于缺少新接口的实现导致无法成功编译，请尽快升级你的 TGSDK 到 1.8.1 版本或是使用 Tag 为 1.8.1 之前的 Cocos2d-x 封装代码来兼容以前的版本**


>**【注意】由于 `1.8.x` 版本新增了 GDPR 相关合规接口，如果使用以前版本的 TGSDK 接入会由于缺少新接口的实现导致无法成功编译，请尽快升级你的 TGSDK 到 1.8.x 版本或是使用 Tag 为 1.8.0 之前的 Cocos2d-x 封装代码来兼容以前的版本**

>**【注意】由于 `1.7.x` 版本新增了付费用户追踪接口，如果使用以前版本的 TGSDK 接入会由于缺少新接口的实现导致无法成功编译，请尽快升级你的 TGSDK 到 1.7.x 版本或是使用 Tag 为 1.7.0 之前的 Cocos2d-x 封装代码来兼容以前的版本**

>**【注意】由于 `1.6.x` 版本新增了场景参数接口，如果使用 1.5.x 以前的版本 TGSDK 接入会由于缺少新接口的实现导致无法成功编译，请尽快升级你的 TGSDK 到 1.6.x 版本或是使用 Tag 为 `1.5.x` 的 Cocos2d-x 封装代码来兼容 1.5.x 以前的 TGSDK 接口实现**
>
>**【注意】由于 `1.6.5` 版本新增了广告测试工具接口，如果你使用 1.6.5 版本以前的 TGSDK 接入会由于缺少新接口实现导致无法成功编译，请尽快升级你的 TGSDK 到最新版本或是使用 Tag 为 `1.6.4` 的 Cocos2d-x 封装代码来兼容**

## 1、概述

为了方便使用 cocos2d-x 引擎开发的产品使用 Yomob 的广告 SDK，我们给 Yomob 的广告 SDK 做了一层封装，并提供了更适合 cocos2d-x 使用的 API 以及 JavaScript 绑定和 Lua 绑定支持。

## 2、如何集成

首先先按照[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs) 将 Yomob SDK 集成到你的 cocos2d-x 项目中。

然后将 `TGSDKCocos2dxHelper.h` 和 `TGSDKCocos2dxHelper.mm` 两个文件放入你的 cocos2d-x 项目的 `Classes` 文件夹下。

> **【注意】如果是针对 Android 进行编译时需要将 `TGSDKCocos2dxHelper.mm` 文件重命名为 `TGSDKCocos2dxHelper.cpp` 否则编译时无法正常识别源代码文件**

如果你使用的是 `JavaScript` 脚本，那么需要加入宏 `TGSDK_BIND_JS`（对于使用 Cocos Creator 生成的项目，需要使用不同的宏，要用`TGSDK_BIND_COCOS_CREATOR`），

 如果你使用的是 `Lua` 脚本，那么需要加入宏 `TGSDK_BIND_LUA` 具体做法如下：

iOS :

```
Build Settings ----> Preprocessor Macros

添加 `TGSDK_BIND_JS=1`
```

Android：

编辑 `jni/Application.mk` 在后面添加

```
APP_STL := gnustl_static

# Uncomment this line to compile to armeabi-v7a, your application will run faster but support less devices
#APP_ABI := armeabi-v7a

APP_CPPFLAGS := -frtti -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -fsigned-char
APP_LDFLAGS := -latomic

APP_ABI := armeabi

USE_ARM_MODE := 1

ifeq ($(NDK_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif

##添加宏
APP_CPPFLAGS += -DTGSDK_BIND_JS
```

### 对于 Cocos Creator 支持

> **对于 Cocos Creator 支持**，Cocos Creator 对于 JS 的处理和 Cocos2dx-js 不太一样，所以封装的代码也不能共用。因此需要将宏配置为 `TGSDK_BIND_COCOS_CREATOR` 才可以支持 Cocos Creator 的 JavaScript 封装。

- 在 Application.mk 中增加宏定义

```
APP_CPPFLAGS += -DTGSDK_BIND_COCOS_CREATOR
```

- 将 `TGSDKCocos2dxHelper.h` 和 `TGSDKCocos2dxHelper.cpp` 文件放到你的 Classes 文件夹中

- 在 Android.mk 文件中增加 `TGSDKCocos2dxHelper.cpp`，举例：

```

LOCAL_SRC_FILES := hellojavascript/main.cpp \
				   ../../../Classes/AppDelegate.cpp \
				   ../../../Classes/jsb_module_register.cpp \
				   ../../../Classes/TGSDKCocos2dxHelper.cpp \


```

- 将 TGSDK 中的所有 aar 和 `dependencies` 文件夹中所有的 jar 放进项目的 libs 文件夹

- 将 TGSDK 中的 `uses_permissions.txt` 和 `uses_provider.txt` 文件内容合并到你的 `AndroidManifest.xml` 文件中

- 修改项目的 `build.gradle` 文件，加入依赖，举例：

```
dependencies {
    implementation 'com.android.support:appcompat-v7:25.3.1'
    implementation 'com.android.support:support-v4:26.0.1'
    implementation 'com.android.support:recyclerview-v7:25.3.1'
    implementation fileTree(dir: 'libs', include: ['*.jar','*.aar'])
    implementation fileTree(dir: "/Applications/CocosCreator.app/Contents/Resources/cocos2d-x/cocos/platform/android/java/libs", include: ['*.jar'])
    implementation project(':libcocos2dx')
}
```

- 修改项目的 `build.gradle` 文件，在 `defaultConfig` 部分加入 `ndk abiFilters`，举例：

```
apply plugin: 'com.android.application'

android {
    compileSdkVersion PROP_COMPILE_SDK_VERSION.toInteger()
    buildToolsVersion PROP_BUILD_TOOLS_VERSION

    defaultConfig {
        applicationId "com.soulgame.tgsdksampleapp.android"
        minSdkVersion PROP_MIN_SDK_VERSION
        targetSdkVersion PROP_TARGET_SDK_VERSION
        versionCode 1
        versionName "1.0"

        ndk {
            abiFilters "armeabi-v7a"
        }

```

- 将 TGSDK 中的 `proguard-project.txt` 内容添加到项目中的 `proguard-rules.pro` 文件中。

### 修改主 Activity 代码

如果你要构建 Android 工程，还要在启动的 Activity 里面加入一行

```
package org.cocos2dx.lua;

import org.cocos2dx.lib.Cocos2dxActivity;
import com.soulgame.sgsdk.tgsdklib.cocos2dx.TGSDKCocos2dxHelper;
import android.os.Bundle;


public class AppActivity extends Cocos2dxActivity{  

    @Override
	protected void onCreate(Bundle savedInstanceState) {
	    super.onCreate(savedInstanceState);
		// 初始化 TGSDK for cocos2d-x
        TGSDKCocos2dxHelper.setup(this);
    }
	
}
```

## 3、脚本绑定

如果你使用了 `JavaScript` 或者 `Lua` 脚本，那么你需要执行脚本绑定方法将 `TGSDK` 对象绑定到脚本运行环境去，具体的做法是在 `AppDelegate.cpp` 文件的 `bool AppDelegate::applicationDidFinishLaunching()` 方法中加入

```
#include "TGSDKCocos2dxHelper.h"

bool AppDelegate::applicationDidFinishLaunching() {
    // Other code ......
    yomob::TGSDKCocos2dxHelper::bindScript();
    jsb_register_all_modules();
    // Other code ......
}
```

>**【注意】脚本绑定方法一定要在任何脚本文件执行之前调用完成！**

## 4、如何使用

### Debug 模式开关

C++

```
yomob::TGSDKCocos2dxHelper::setDebugModel(true);
```

JavaScript

```
yomob.TGSDK.setDebugModel(true);
```

Lua

```
yomob.TGSDK.setDebugModel(true)
```


>**【注意】release 环境正式发布产品时记得关闭 Debug 模式**

### 初始化 TGSDK

**C++**

```
#include "TGSDKCocos2dxHelper.h"

yomob::TGSDKCocos2dxHelper::initialize("Yomob AppID");
```

**JavaScript**

```
yomob.TGSDK.initialize("Yomob AppID");
```

**Lua**

```
yomob.TGSDK.initialize("Yomob AppID")
```

### 当前网络状况

**C++**

```
#include "TGSDKCocos2dxHelper.h"

int net = yomob::TGSDKCocos2dxHelper::isWIFI();
// net = 0  3G/4G 网络
// net = 1  WIFI 网络
// net = 2  未知网络/没有网络
```

**JavaScript**

```
var net = yomob.TGSDK.isWIFI();
```

**Lua**

```
local net = yomob.TGSDK.isWIFI()
```

### 预加载广告

**C++**

```
yomob::TGSDKCocos2dxHelper::preload();
```

**JavaScript**

```
yomob.TGSDK.preload();
```

**Lua**

```
yomob.TGSDK.preload()
```

### 显示广告

**C++**

```
if (yomob::TGSDKCocos2dxHelper::couldShowAd("Scene ID")) {
    yomob::TGSDKCocos2dxHelper::showAd("Scene ID");
}
```

**JavaScript**

```
if (yomob.TGSDK.couldShowAd("Scene ID")) {
    yomob.TGSDK.showAd("Scene ID");
}
```

**Lua**

```
if yomob.TGSDK.couldShowAd("Scene ID") then
    yomob.TGSDK.showAd("Scene ID")
end
```

### 播放 Banner 广告

**C++**

```
yomob::TGSDKCocos2dxHelper::setBannerConfig(
    "Scene ID",
    "TGBannerNormal",
    x, y,
    width, height,
    interval
);
```

**JavaScript**

```
yomob.TGSDK.setBannerConfig(
    "Scene ID",
    "TGBannerNormal",
    x, y,
    width, height,
    interval
);
```

**Lua**

```
yomob.TGSDK.setBannerConfig(
    "Scene ID",
    "TGBannerNormal",
    x, y,
    width, height,
    interval
)
```


参数解释：

- scene Banner 广告对应注册的广告场景 ID

- type Banner 广告尺寸类型， 其中分为三种类型：

|Banner类型对应字符串|Banner尺寸|
|:-:|:-:|
|TGBannerNormal|300\*50|
|TGBannerLarge|300\*90|
|TGBannerMediumRectangle|300\*250|

- x、y  Banner 放置的位置对应的 X 坐标和 Y 坐标，单位：px

- width、height Banner 广告预留展示位置的宽高，单位：px

- interval Banner 广告轮播切换广告内容的间隔时间，单位：秒

坐标以屏幕左上角为零点，interval为轮播时间，以秒为单位，建议在30-120范围内。需要时还可以关闭Banner广告：

**C++**

```
yomob::TGSDKCocos2dxHelper::closeBanner("Scene ID");
```

**JavaScript**

```
yomob.TGSDK.closeBanner("Scene ID");
```

**Lua**

```
yomob.TGSDK.closeBanner("Scene ID")
```

> **[注意]** 当不需要展示 Banner 广告或者展示 Banner 广告的视图被关闭销毁时，请一定调用 `closeBanner("Scene ID")` 方法手动关闭 Banner 广告，否则会影响下一次的 Banner 广告正常展示。


### 显示广告测试工具（1.6.5 以上）

**C++**

```
yomob::TGSDKCocos2dxHelper::showTestView("Scene ID");
```

**JavaScript**

```
yomob.TGSDK.showTestView("Scene ID");
```

**Lua**

```
yomob.TGSDK.showTestView("Scene ID")
```

### 付费用户追踪（1.7.0 以上）

什么是付费用户追踪？具体请参看[《YoMob 广告 SDK 官方文档》](https://support.yomob.com/docs/sdk/introduction/ios/#TGSDK_tagPayingUser)

付费用户标识

**C++**

```
    typedef enum {
        TGSDKCocos2dxNonPayingUser,        // 非付费用户
        TGSDKCocos2dxSmallPaymentUser,     // 小额付费用户
        TGSDKCocos2dxMediumPaymentUser,    // 中等额度付费用户
        TGSDKCocos2dxLargePaymentUser      // 大额付费用户
    } TGSDKCocosedxPayingUser;

```

**JavaScript & Lua**

```
yomob.TGSDK.TGPAYINGUSER_NON_PAYING_USER        // 非付费用户
yomob.TGSDK.TGPAYINGUSER_SMALL_PAYMENT_USER     // 小额付费用户
yomob.TGSDK.TGPAYINGUSER_MEDIUM_PAYMENT_USER    // 中等额度付费用户
yomob.TGSDK.TGPAYINGUSER_LARGE_PAYMENT_USER     // 大额付费用户
```

调用方法

**C++**

```
yomob::TGSDKCocos2dxHelper::tagPayingUser(
        TGSDKCocos2dxSmallPaymentUser,
        "USD",
        10, 500);
```

**JavaScript**

```
yomob.TGSDK.tagPayingUser(
        yomob.TGSDK.TGPAYINGUSER_NON_PAYING_USER,
        "", 0, 0
);
```

**Lua**

```
yomob.TGSDK.tagPayingUser(
        yomob.TGSDK.TGPAYINGUSER_LARGE_PAYMENT_USER,
        "CNY", 648, 1280
)
```

### GDPR 合规支持(1.8.0 以上)

截至 2018 年 5 月 25 日，“通用数据保护条例”（GDPR）将在欧盟实施。 为了遵守GDPR，开发者有两种选择。

- 推荐做法： 开发者自行控制用户级别的 GDPR 同意过程，然后将用户的选择传达给 TGSDK。 为此，开发人员可以使用自己的机制收集用户的同意，然后通过调用 TGSDK 的 API 来更新或查询用户的同意状态。

- 默认做法：允许 TGSDK 自行处理要求。 TGSDK 会在为欧洲用户请求广告之前展示同意对话框，并会记住用户对后续广告的同意或拒绝。

**C++**

```
// 获取用户针对 GDRP 法规的选择状态
// yes = 同意
// no = 拒绝
// 空字符串 = 用户未做出选择

std::string status = yomob::TGSDKCocos2dxHelper::getUserGDPRConsentStatus();


// 设置用户针对 GDPR 法规的选择状态
// yes = 同意
// no = 拒绝

yomob::TGSDKCocos2dxHelper::setUserGDPRConsentStatus("yes");


// 获取用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是
// 空字符串 = 用户未做出选择

std::string status = yomob::TGSDKCocos2dxHelper::getIsAgeRestrictedUser();


// 设置用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是

yomob::TGSDKCocos2dxHelper::setIsAgeRestrictedUser("no");
```

**JavaScript**

```
// 获取用户针对 GDRP 法规的选择状态
// yes = 同意
// no = 拒绝
// 空字符串 = 用户未做出选择

var status = yomob.TGSDK.getUserGDPRConsentStatus();


// 设置用户针对 GDPR 法规的选择状态
// yes = 同意
// no = 拒绝

yomob.TGSDK.setUserGDPRConsentStatus("yes");


// 获取用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是
// 空字符串 = 用户未做出选择

var status = yomob.TGSDK.getIsAgeRestrictedUser();


// 设置用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是

yomob.TGSDK.setIsAgeRestrictedUser("no");

```

**Lua**

```
// 获取用户针对 GDRP 法规的选择状态
// yes = 同意
// no = 拒绝
// 空字符串 = 用户未做出选择

local status = yomob.TGSDK.getUserGDPRConsentStatus()


// 设置用户针对 GDPR 法规的选择状态
// yes = 同意
// no = 拒绝

yomob.TGSDK.setUserGDPRConsentStatus("yes")


// 获取用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是
// 空字符串 = 用户未做出选择

local status = yomob.TGSDK.getIsAgeRestrictedUser()


// 设置用户是否是未成年受监管的用户
// yes = 是，是受监管用户
// no = 不是

yomob.TGSDK.setIsAgeRestrictedUser("no")
```

### 用户广告行为追踪

什么是用户广告行为追踪？具体请参看[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs)

**C++**

```
// 广告 UI 被用户看到
yomob::TGSDKCocos2dxHelper::showAdScene("Scene ID");
// 广告播放被用户明确拒绝
yomob::TGSDKCocos2dxHelper::reportAdRejected("Scene ID");
```

**JavaScript**

```
// 广告 UI 被用户看到
yomob.TGSDK.showAdScene("Scene ID");
// 广告播放被用户明确拒绝
yomob.TGSDK.showAdScene("Scene ID");
```

**Lua**

```
-- 广告 UI 被用户看到
yomob.TGSDK.showAdScene("Scene ID")
-- 广告播放被用户明确拒绝
yomob.TGSDK.reportAdRejected("Scene ID")
```

### 事件回调触发

所有[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs)中描述的相关事件我们在 cocos2d-x 中都使用 `CustomEvent` 事件进行了触发，具体的事件有

**C++**

```
// SDK 初始化成功
#define TGSDK_EVENT_INIT_SUCCESS "TGSDK_onInitSuccess"
// SDK 初始化失败
#define TGSDK_EVENT_INIT_FAILED  "TGSDK_onInitFailed"

// 广告预加载成功
#define TGSDK_EVENT_PRELOAD_SUCCESS "TGSDK_onPreloadSuccess"
// 广告预加载失败
#define TGSDK_EVENT_PRELOAD_FAILED  "TGSDK_onPreloadFailed"

// 激励视频广告资源下载完成【1.8.3 新增】
#define TGSDK_EVENT_AWARD_VIDEO_LOADED "TGSDK_onAwardVideoLoaded"
// 插屏视频广告资源下载完成1.8.3 新增】
#define TGSDK_EVENT_INTERSTITIAL_VIDEO_LOADED "TGSDK_onInterstitialVideoLoaded"
// 插屏视频广告资源下载完成1.8.3 新增】
#define TGSDK_EVENT_INTERSTITIAL_LOADED "TGSDK_onInterstitialLoaded"

// 广告显示成功【1.8.3 新增】
#define TGSDK_EVENT_ON_AD_SHOW_SUCCESS "TGSDK_onADShowSuccess"
// 广告显示失败【1.8.3 新增】
#define TGSDK_EVENT_ON_AD_SHOW_FAILED  "TGSDK_onADShowFailed"
// 广告被点击【1.8.3 新增】
#define TGSDK_EVENT_ON_AD_CLICK        "TGSDK_onADClicked"
// 广告被关闭【1.8.3 新增】
#define TGSDK_EVENT_ON_AD_CLOSE        "TGSDK_onADClosed"

```

**JavaScript & Lua**

```
// SDK 初始化成功
yomob.TGSDK.TGSDK_EVENT_INIT_SUCCESS
// SDK 初始化失败
yomob.TGSDK.TGSDK_EVENT_INIT_FAILED 

// 广告预加载成功
yomob.TGSDK.TGSDK_EVENT_PRELOAD_SUCCESS
// 广告预加载失败
yomob.TGSDK.TGSDK_EVENT_PRELOAD_FAILED 


// 激励视频广告资源下载完成【1.8.3 新增】
yomob.TGSDK_EVENT_AWARD_VIDEO_LOADED
// 插屏视频广告资源下载完成1.8.3 新增】
yomob.TGSDK_EVENT_INTERSTITIAL_VIDEO_LOADED
// 插屏视频广告资源下载完成1.8.3 新增】
yomob.TGSDK_EVENT_INTERSTITIAL_LOADED


// 广告显示成功【1.8.3 新增】
yomob.TGSDK_EVENT_ON_AD_SHOW_SUCCESS
// 广告显示失败【1.8.3 新增】
yomob.TGSDK_EVENT_ON_AD_SHOW_FAILED
// 广告被点击【1.8.3 新增】
yomob.TGSDK_EVENT_ON_AD_CLICK
// 广告被关闭【1.8.3 新增】
yomob.TGSDK_EVENT_ON_AD_CLOSE


```

如果不想使用 `CustomEvent` 的方式来处理回调事件的话，我们还支持回调方法

**C++**

```
EventListenerCustom* sdkListener = NULL;
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_INIT_SUCCESS, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK init Success : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_INIT_FAILED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK init Failed : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_PRELOAD_SUCCESS, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK preload Success : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_PRELOAD_FAILED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK preload Failed : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_CPAD_LOADED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK CPAD loaded : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_VIDEOAD_LOADED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK VideoAD loaded : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_AD_SHOW_SUCCESS, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK AD Show Success : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_AD_SHOW_FAILED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK AD Show Failed : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_AD_CLICK, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK AD Click : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_AD_CLOSE, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK AD Close : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_AD_COMPLETE, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK AD Complete : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_REWARD_SUCCESS, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Reward Success : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_REWARD_FAILED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Reward Failed : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_BANNER_LOADED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Banner loaded : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_BANNER_FAILED, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Banner failed : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_BANNER_CLICK, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Banner click : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
    
    sdkListener = EventListenerCustom::create(TGSDK_EVENT_BANNER_CLOSE, [](EventCustom* evt){
        const char * ret = (const char*)evt->getUserData();
        CCLOG("Cocos2dx TGSDK Banner close : %s", ret);
    });
    Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(sdkListener, 1);
```

**JavaScript**

```javascript
yomob.TGSDK.prototype.onInitSuccess = function(ret) {
    cc.log("SDK 初始化完成");
};


yomob.TGSDK.prototype.onInitFailed = function(ret) {
    cc.log("SDK 初始化失败");
};


yomob.TGSDK.prototype.onPreloadSuccess = function(ret) {
    cc.log("广告预加载成功");
};


yomob.TGSDK.prototype.onPreloadFailed = function(ret) {
    cc.log("广告预加载失败");
};


yomob.TGSDK.prototype.onAwardVideoLoaded = function(ret) {
    cc.log("奖励视频广告资源下载完成");
};

yomob.TGSDK.prototype.onInterstitialVideoLoaded = function(ret) {
    cc.log("插屏视频广告资源下载完成");
};

yomob.TGSDK.prototype.onInterstitialLoaded = function(ret){
    cc.log("静态插屏广告资源下载完成");
};

yomob.TGSDK.prototype.onADShowSuccess = function(scene, ret) {
    cc.log("广告展示成功");
};

yomob.TGSDK.prototype.onADShowFailed = function(scene, ret, err) {
    cc.log("广告展示失败");
};

yomob.TGSDK.prototype.onADClicked = function(scene, ret) {
    cc.log("广告被点击了")
};

yomob.TGSDK.prototype.onADClosed = function(scene, ret, reward){
    if (reward) {
        cc.log("广告关闭，并且可以领取奖励");
    } else {
        cc.log("广告关闭，没有达成奖励条件，无法领取奖励");
    }
};
```

**Lua**

```lua
yomob.TGSDK.onInitSuccess = function(ret)
    print("SDK 初始化完成")
end

yomob.TGSDK.onInitFailed = function(ret)
    print("SDK 初始化失败")
end

yomob.TGSDK.onPreloadSuccess = function(ret)
    print("广告预加载成功")
end

yomob.TGSDK.onPreloadFailed = function(ret)
    print("广告预加载失败")
end

yomob.TGSDK.onAwardVideoLoaded = function(ret)
    print("激励视频广告资源加载成功")
end

yomob.TGSDK.onInterstitialVideoLoaded = function(ret)
    print("插屏视频广告资源加载成功")
end

yomob.TGSDK.onInterstitialLoaded = function(ret)
    print("静态插屏广告资源加载成功")
end

yomob.TGSDK.onADShowSuccess = function(scene, ret)
    print("广告展示成功")
end

yomob.TGSDK.onADShowFailed = function(scene, ret, err)
    print("广告展示失败")
end

yomob.TGSDK.onADClicked = function(scene, ret)
    print("广告被点击了")
end

yomob.TGSDK.onADClosed = function(scene, ret, reward)
    if (reward) then
        print("广告关闭，并且可以领取奖励")
    else
        print("广告关闭，没有达成奖励条件，无法领取奖励")
    end
end

```