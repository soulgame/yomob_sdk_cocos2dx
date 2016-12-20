package com.soulgame.sgsdk.tgsdklib.cocos2dx;

import android.app.Activity;

import com.soulgame.sgsdk.tgsdklib.TGSDK;
import com.soulgame.sgsdk.tgsdklib.TGSDKServiceResultCallBack;
import com.soulgame.sgsdk.tgsdklib.ad.ITGADListener;
import com.soulgame.sgsdk.tgsdklib.ad.ITGPreloadListener;
import com.soulgame.sgsdk.tgsdklib.ad.ITGRewardVideoADListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

/**
 * Created by leenjewel on 2016/12/15.
 */

public final class TGSDKCocos2dxHelper implements TGSDKServiceResultCallBack, ITGPreloadListener, ITGADListener, ITGRewardVideoADListener {

    private Activity _activity = null;

    static private TGSDKCocos2dxHelper _instance = null;

    static private TGSDKCocos2dxHelper getInstance() {
        if (null == _instance) {
            _instance = new TGSDKCocos2dxHelper();
        }
        return _instance;
    }

    static public void setup(Activity activity) {
        getInstance()._activity = activity;
    }

    static public void setDebugModel(boolean debug) {
        TGSDK.setDebugModel(debug);
    }

    static public void initialize() {
        TGSDK.initialize(getInstance()._activity, getInstance());
        TGSDK.setADListener(getInstance());
        TGSDK.setRewardVideoADListener(getInstance());
    }

    static public void initialize(String appid) {
        TGSDK.initialize(getInstance()._activity, appid, getInstance());
        TGSDK.setADListener(getInstance());
        TGSDK.setRewardVideoADListener(getInstance());
    }

    static public void initialize(String appid, String channelid) {
        TGSDK.initialize(getInstance()._activity, appid, channelid, getInstance());
        TGSDK.setADListener(getInstance());
        TGSDK.setRewardVideoADListener(getInstance());
    }

    static public void preload() {
        TGSDK.preloadAd(getInstance());
    }

    static public boolean couldShowAd(String scene) {
        return TGSDK.couldShowAd(scene);
    }

    static public void showAd(String scene) {
        TGSDK.showAd(getInstance()._activity, scene);
    }

    static public void sendCounter(String name, String metaData) {
        if (null != metaData && metaData.length() > 0) {
            try {
                JSONObject metadataJson = new JSONObject(metaData);
                TGSDK.SendCounter(name, metadataJson, true);
            } catch (JSONException e) {
                e.printStackTrace();
                TGSDK.SendCounter(name);
            }
        } else {
            TGSDK.SendCounter(name);
        }
    }

    native static public void onEvent(String what, String ret);

    @Override
    public void onShowSuccess(String result) {
        onEvent("TGSDK_onShowSuccess", result);
    }

    @Override
    public void onShowFailed(String result, String error) {
        onEvent("TGSDK_onShowFailed", error);
    }

    @Override
    public void onADComplete(String result) {
        onEvent("TGSDK_onADComplete", result);
    }

    @Override
    public void onADClick(String result) {
        onEvent("TGSDK_onADClick", result);
    }

    @Override
    public void onADClose(String result) {
        onEvent("TGSDK_onADClose", result);
    }

    @Override
    public void onPreloadSuccess(String result) {
        onEvent("TGSDK_onPreloadSuccess", result);
    }

    @Override
    public void onPreloadFailed(String scene, String error) {
        onEvent("TGSDK_onPreloadFailed", error);
    }

    @Override
    public void onCPADLoaded(String result) {
        onEvent("TGSDK_onCPADLoaded", result);
    }

    @Override
    public void onVideoADLoaded(String result) {
        onEvent("TGSDK_onVideoADLoaded", result);
    }

    @Override
    public void onADAwardSuccess(String result) {
        onEvent("TGSDK_onADAwardSuccess", result);
    }

    @Override
    public void onADAwardFailed(String result, String error) {
        onEvent("TGSDK_onADAwardFailed", error);
    }

    @Override
    public void onSuccess(Object tag, Map<String, String> result) {
        onEvent("TGSDK_onInitSuccess", "");
    }

    @Override
    public void onFailure(Object tag, String error) {
        onEvent("TGSDK_onInitFailed", error);
    }
}
