Mina System Branding Icon Assets

Copy instructions:

1) Android launcher icons:
Copy android/app/src/main/res/mipmap-* folders into the project root and replace existing ic_launcher.png files.

2) Windows icon:
Copy windows/runner/resources/app_icon.ico into the project root and replace the existing file.

3) Branding assets:
Copy assets/branding/mina_system_logo_full.png and assets/branding/mina_system_app_icon_1024.png into the project root.
Then add this to pubspec.yaml under flutter/assets if you want to use them inside the app:
  - assets/branding/

4) Store assets:
Use docs/release/store_assets/android/play_store_icon_512.png for Google Play store icon preparation.

5) iOS:
iOS prepared icons are included under docs/release/store_assets/ios_prepared, but iOS integration should be done later on macOS/Xcode.
