# Yomob SDK for Cocos2d-x

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

如果你使用的是 `JavaScript` 脚本，那么需要加入宏 `TGSDK_BIND_JS`，

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

如果你要构建 Android 工程，并且你使用的 Yomob 广告 SDK 的版本是 **1.4.3(含)** 以前的版本，那么你还需要将 `java` 文件夹下的文件放入你的项目 `proj.android/src` 文件夹下

>com/soulgame/sgsdk/tgsdklib/cocos2dx/TGSDKCocos2dxHelper.java

　
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

>**【注意】1.4.3（含）之前的版本需要手动加入上述 Java 源代码文件，之后的版本不需要手动加入 Java 源文件，但是都必须调用上述的 `setup` 方法！！！**

## 3、脚本绑定

如果你使用了 `JavaScript` 或者 `Lua` 脚本，那么你需要执行脚本绑定方法将 `TGSDK` 对象绑定到脚本运行环境去，具体的做法是在 `AppDelegate.cpp` 文件的 `bool AppDelegate::applicationDidFinishLaunching()` 方法中加入

```
#include "TGSDKCocos2dxHelper.h"

bool AppDelegate::applicationDidFinishLaunching() {
    // Other code ......
    yomob::TGSDKCocos2dxHelper::bindScript();
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
|:-:|:-|
|TGBannerNormal|300*50|
|TGBannerLarge|300*90|
|TGBannerMediumRectangle|300*250|

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

### 场景参数（1.6.0 以上）

什么是场景参数？具体请参看[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs)

**C++**

```
std::string param1 = yomob::TGSDKCocos2dxHelper::getStringParameterFromAdScene("Your Scene id", "Your Key");

int param2 = yomob::TGSDKCocos2dxHelper::getIntParameterFromAdScene("Your Scene id", "Your Key");

float param3 = yomob::TGSDKCocos2dxHelper::getFloatParameterFromAdScene("Your Scene id", "Your Key");
```

**JavaScript**

```
var param = yomob.TGSDK.parameterFromAdScene("Your Scene id", "Your Key");
```

**Lua**

```
local param = yomob.TGSDK.parameterFromAdScene("Your Scene id", "Your Key")
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
// 静态广告资源下载完成
#define TGSDK_EVENT_CPAD_LOADED     "TGSDK_onCPADLoaded"
// 视频广告资源下载完成
#define TGSDK_EVENT_VIDEOAD_LOADED  "TGSDK_onVideoADLoaded"

// 广告显示成功
#define TGSDK_EVENT_AD_SHOW_SUCCESS "TGSDK_onShowSuccess"
// 广告显示失败
#define TGSDK_EVENT_AD_SHOW_FAILED  "TGSDK_onShowFailed"
// 广告播放完成
#define TGSDK_EVENT_AD_COMPLETE     "TGSDK_onADComplete"
// 广告被点击
#define TGSDK_EVENT_AD_CLICK        "TGSDK_onADClick"
// 广告被关闭
#define TGSDK_EVENT_AD_CLOSE        "TGSDK_onADClose"

// 广告奖励条件达成
#define TGSDK_EVENT_REWARD_SUCCESS "TGSDK_onADAwardSuccess"
// 广告奖励条件未达成
#define TGSDK_EVENT_REWARD_FAILED  "TGSDK_onADAwardFailed"

// Banner 广告成功展示
#define TGSDK_EVENT_BANNER_LOADED  "TGSDK_onBannerLoaded"
// Banner 广告展示失败
#define TGSDK_EVENT_BANNER_FAILED  "TGSDK_onBannerFailed"
// Banner 广告被点击
#define TGSDK_EVENT_BANNER_CLICK   "TGSDK_onBannerClick"
// Banner 广告被关闭
#define TGSDK_EVENT_BANNER_CLOSE   "TGSDK_onBannerClose"

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
// 静态广告资源下载完成
yomob.TGSDK.TGSDK_EVENT_CPAD_LOADED    
// 视频广告资源下载完成
yomob.TGSDK.TGSDK_EVENT_VIDEOAD_LOADED 

// 广告显示成功
yomob.TGSDK.TGSDK_EVENT_AD_SHOW_SUCCESS
// 广告显示失败
yomob.TGSDK.TGSDK_EVENT_AD_SHOW_FAILED 
// 广告播放完成
yomob.TGSDK.TGSDK_EVENT_AD_COMPLETE    
// 广告被点击
yomob.TGSDK.TGSDK_EVENT_AD_CLICK       
// 广告被关闭
yomob.TGSDK.TGSDK_EVENT_AD_CLOSE       

// 广告奖励条件达成
yomob.TGSDK.TGSDK_EVENT_REWARD_SUCCESS
// 广告奖励条件未达成
yomob.TGSDK.TGSDK_EVENT_REWARD_FAILED 

// Banner 广告成功展示
yomob.TGSDK.TGSDK_EVENT_BANNER_LOADED
// Banner 广告展示失败
yomob.TGSDK.TGSDK_EVENT_BANNER_FAILED
// Banner 广告被点击
yomob.TGSDK.TGSDK_EVENT_BANNER_CLICK
// Banner 广告被关闭
yomob.TGSDK.TGSDK_EVENT_BANNER_CLOSE

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

```
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

yomob.TGSDK.prototype.onCPADLoaded = function(ret) {
    cc.log("静态广告资源下载完成");
};

yomob.TGSDK.prototype.onVideoADLoaded = function(ret) {
    cc.log("视频广告资源下载完成");
};

yomob.TGSDK.prototype.onShowSuccess = function(ret) {
    cc.log("广告显示成功");
};

yomob.TGSDK.prototype.onShowFailed = function(ret){
    cc.log("广告显示失败");
};

yomob.TGSDK.prototype.onADComplete = function(ret) {
    cc.log("广告播放完成");
};

yomob.TGSDK.prototype.onADClick = function(ret) {
    cc.log("广告被点击了");
};

yomob.TGSDK.prototype.onADClose = function(ret) {
    cc.log("广告被关闭了");
};

yomob.TGSDK.prototype.onADAwardSuccess = function(ret) {
    cc.log("广告奖励条件达成");
};

yomob.TGSDK.prototype.onADAwardFailed = function(ret) {
    cc.log("广告奖励条件未达成，不予奖励");
};

yomob.TGSDK.prototype.onBannerLoaded = function(scene, ret) {
    cc.log("Banner 广告成功播放");
};

yomob.TGSDK.prototype.onBannerFailed = function(scene, ret, err) {
    cc.log("Banner 广告展示失败");
};

yomob.TGSDK.prototype.onBannerClick = function(scene, ret) {
    cc.log("Banner 广告被点击");
};

yomob.TGSDK.prototype.onBannerClose = function(scene, ret) {
    cc.log("Banner 广告关闭");
};
```

**Lua**

```
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

yomob.TGSDK.onCPADLoaded = function(ret)
    print("静态广告资源下载完成")
end

yomob.TGSDK.onVideoADLoaded = function(ret)
    print("视频广告资源下载完成")
end

yomob.TGSDK.onShowSuccess = function(ret)
    print("广告显示成功")
end

yomob.TGSDK.onShowFailed = function(ret)
    print("广告显示失败")
end

yomob.TGSDK.onADComplete = function(ret)
    print("广告播放完成")
end

yomob.TGSDK.onADClick = function(ret)
    print("广告被点击了")
end

yomob.TGSDK.onADClose = function(ret)
    print("广告被关闭了")
end

yomob.TGSDK.onADAwardSuccess = function(ret)
    print("广告奖励条件达成")
end

yomob.TGSDK.onADAwardFailed = function(ret)
    print("广告奖励条件未达成，不予奖励")
end

yomob.TGSDK.onBannerLoaded = function(scene, ret)
    print("Banner 广告成功播放")
end

yomob.TGSDK.onBannerFailed = function(scene, ret, err)
    print("Banner 广告展示失败")
end

yomob.TGSDK.onBannerClick = function(scene, ret)
    print("Banner 广告被点击")
end

yomob.TGSDK.onBannerClose = function(scene, ret)
    print("Banner 广告关闭")
end
```