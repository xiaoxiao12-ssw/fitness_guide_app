import os
import shutil
import re

def apply_branding():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    manifest_path = os.path.join(base_dir, "android", "app", "src", "main", "AndroidManifest.xml")
    
    print(f"Updating AndroidManifest.xml at {manifest_path}...")
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # 1. Update android:label to 少伟健身通
        content = re.sub(r'android:label="[^"]*"', 'android:label="少伟健身通"', content, count=1)
        print("Updated android:label to 少伟健身通")
        
        # 2. Ensure icon is @mipmap/ic_launcher & allow cleartext traffic for in-app video preview
        if 'android:icon="' in content:
            content = re.sub(r'android:icon="[^"]*"', 'android:icon="@mipmap/ic_launcher"', content, count=1)
        if 'android:usesCleartextTraffic' not in content and '<application' in content:
            content = content.replace('<application', '<application\n        android:usesCleartextTraffic="true"', 1)
            print("Added android:usesCleartextTraffic=true")
        
        # 3. Add INTERNET & CAMERA permissions if not present
        if 'android.permission.INTERNET' not in content:
            internet_perm = '    <uses-permission android:name="android.permission.INTERNET"/>\n'
            if '<application' in content:
                content = content.replace('<application', internet_perm + '    <application', 1)
                print("Added android.permission.INTERNET")

        if 'android.permission.CAMERA' not in content:
            camera_perm = (
                '    <uses-permission android:name="android.permission.CAMERA"/>\n'
                '    <uses-feature android:name="android.hardware.camera" android:required="false"/>\n'
            )
            if '<application' in content:
                content = content.replace('<application', camera_perm + '    <application', 1)
                print("Added android.permission.CAMERA")

        # 4. Add <queries> for url_launcher
        if '<queries>' not in content:
            queries_block = '''
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
    </queries>
'''
            if '</manifest>' in content:
                content = content.replace('</manifest>', queries_block + '</manifest>', 1)
                print("Added <queries> block for url_launcher")

        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(content)
    else:
        print("Warning: AndroidManifest.xml not found yet!")

    # Copy launcher icons to android res
    assets_icon_dir = os.path.join(base_dir, "assets", "icon")
    android_res_dir = os.path.join(base_dir, "android", "app", "src", "main", "res")
    
    # Remove anydpi-v26 if present
    anydpi_dir = os.path.join(android_res_dir, "mipmap-anydpi-v26")
    if os.path.exists(anydpi_dir):
        shutil.rmtree(anydpi_dir)
        print("Removed mipmap-anydpi-v26 to ensure full custom launcher icon display")

    mipmaps = ["mipmap-mdpi", "mipmap-hdpi", "mipmap-xhdpi", "mipmap-xxhdpi", "mipmap-xxxhdpi"]
    for folder in mipmaps:
        src = os.path.join(assets_icon_dir, folder, "ic_launcher.png")
        dst_folder = os.path.join(android_res_dir, folder)
        os.makedirs(dst_folder, exist_ok=True)
        if os.path.exists(src):
            shutil.copy(src, os.path.join(dst_folder, "ic_launcher.png"))
            print(f"Copied {folder}/ic_launcher.png")
            
    print("Branding application complete!")

if __name__ == "__main__":
    apply_branding()
