package io.jchat.android;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class JMessageReactPackage implements ReactPackage {

    private boolean mShutdownToast;

    public JMessageReactPackage() {
        mShutdownToast = false;
    }

    public JMessageReactPackage(boolean shutdownToast) {
        mShutdownToast = shutdownToast;
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> result = new ArrayList<>();
        result.add(new JMessageModule(reactContext, mShutdownToast));
        return result;
    }

    public List<Class<? extends JavaScriptModule>> createJSModules() {
        return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        List<ViewManager> viewManagers = new ArrayList<>();
        viewManagers.add(new BubbleMsgManager());
        return  viewManagers;
    }
}
