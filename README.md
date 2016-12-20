#Yomob SDK for Cocos2d-x

##1、概述

为了方便使用 cocos2d-x 引擎开发的产品使用 Yomob 的广告 SDK，我们给 Yomob 的广告 SDK 做了一层封装，并提供了更适合 cocos2d-x 使用的 API 以及 JavaScript 绑定和 Lua 绑定支持。

##2、如何集成

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

##3、脚本绑定

如果你使用了 `JavaScript` 或者 `Lua` 脚本，那么你需要执行脚本绑定方法将 `TGSDK` 对象绑定到脚本运行环境去，具体的做法是在 `AppDelegate.cpp` 文件的 `bool AppDelegate::applicationDidFinishLaunching()` 方法中加入

```
#include "TGSDKCocos2dxHelper.h"

bool AppDelegate::applicationDidFinishLaunching() {
    // Other code ......
    yomob::TGSDKCocos2dxHelper::bindScript();
    // Other code ......
}
```

##4、如何使用

###初始化 TGSDK

C++
```
#include "TGSDKCocos2dxHelper.h"

yomob::TGSDKCocos2dxHelper::initialize("Yomob AppID");
```

JavaScript
```
yomob.TGSDK.initialize("Yomob AppID");
```

Lua
```
yomob.TGSDK.initialize("Yomob AppID")
```

###预加载广告

C++
```
yomob::TGSDKCocos2dxHelper::preload();
```

JavaScript
```
yomob.TGSDK.preload();
```

Lua
```
yomob.TGSDK.preload()
```

###显示广告

C++
```
if (yomob::TGSDKCocos2dxHelper::couldShowAd("Scene ID")) {
    yomob::TGSDKCocos2dxHelper::showAd("Scene ID");
}
```

JavaScript
```
if (yomob.TGSDK.couldShowAd("Scene ID")) {
    yomob.TGSDK.showAd("Scene ID");
}
```

Lua
```
if yomob.TGSDK.couldShowAd("Scene ID") then
    yomob.TGSDK.showAd("Scene ID")
end
```

###用户广告行为追踪

什么是用户广告行为追踪？具体请参看[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs)

C++
```
// 广告 UI 被用户看到
yomob::TGSDKCocos2dxHelper::showAdScene("Scene ID");
// 广告播放被用户明确拒绝
yomob::TGSDKCocos2dxHelper::reportAdRejected("Scene ID");
```

JavaScript
```
// 广告 UI 被用户看到
yomob.TGSDK.showAdScene("Scene ID");
// 广告播放被用户明确拒绝
yomob.TGSDK.showAdScene("Scene ID");
```

Lua
```
-- 广告 UI 被用户看到
yomob.TGSDK.showAdScene("Scene ID")
-- 广告播放被用户明确拒绝
yomob.TGSDK.reportAdRejected("Scene ID")
```

###事件回调触发

所有[《Yomob 广告 SDK 官方文档》](https://support.yomob.com/docs)中描述的相关事件我们在 cocos2d-x 中都使用 `CustomEvent` 事件进行了触发，具体的事件有

C++
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

```

JavaScript & Lua
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

```

如果不想使用 `CustomEvent` 的方式来处理回调事件的话，我们还支持回调方法

JavaScript
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
```

Lua
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
```