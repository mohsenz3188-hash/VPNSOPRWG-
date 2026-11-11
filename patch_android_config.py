import os
import re

manifest_path = "android/app/src/main/AndroidManifest.xml"
build_gradle_path = "android/app/build.gradle"

manifest_content = '''<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SYSTEM_EXEMPTED" />

    <application
        android:label="Pasargad VPN"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- WireGuard Native Android VpnService Declaration -->
        <service
            android:name="billion.group.wireguard_flutter.WgVpnService"
            android:permission="android.permission.BIND_VPN_SERVICE"
            android:exported="false">
            <intent-filter>
                <action android:name="android.net.VpnService" />
            </intent-filter>
        </service>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
'''

os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
with open(manifest_path, "w", encoding="utf-8") as f:
    f.write(manifest_content)

if os.path.exists(build_gradle_path):
    with open(build_gradle_path, "r", encoding="utf-8") as f:
        gradle = f.read()
    gradle = re.sub(r"minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24", gradle)
    gradle = re.sub(r"minSdkVersion\s+flutter\.minSdkVersion", "minSdkVersion 24", gradle)
    with open(build_gradle_path, "w", encoding="utf-8") as f:
        f.write(gradle)
