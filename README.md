# auth0_sdk

A Flutter plugin for auth0

## Getting Started

When implementing this library in a Flutter project you need to add some configuration in project

### Android

Add the your Auth0 domain and scheme in your app build.gradle file

```groovy
apply plugin: 'com.android.application'

android {
    compileSdkVersion 30
    defaultConfig {
        applicationId "com.auth0.samples"
        minSdkVersion 21
        targetSdkVersion 30
        //...

        //---> Add the next line
        manifestPlaceholders = [auth0Domain: "@string/com_auth0_domain", auth0Scheme: "https"]
        //<---
    }
    //...
}
```


### iOS

In your application's `Info.plist` file, register your Bundle Identifer as a custom scheme.

```xml
<!-- Info.plist -->

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>auth0</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_BUNDLE_IDENTIFIER</string>
        </array>
    </dict>
</array>
```

Also don't forget to configure the callbacks for each application in your Auth0 application configuration.

