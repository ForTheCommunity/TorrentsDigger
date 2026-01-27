# Build Runner(Freezed). (Development)
f_w:
    # clear; dart run build_runner watch -d
    clear; \
    while true; do \
    dart run build_runner watch -d; \
    if [ $? -ne 0 ]; then \
    echo "_____Dart Build Runner Failed_____"; \
    echo "_____ReExecuting Build Runner_____"; \
    else \
    echo "_____Dart Build Runner is Running_____"; \
    break; \
    fi; \
    done

# FRB Codegen. (Development)
frb_w:
    clear ; flutter_rust_bridge_codegen generate --watch

# Flutter Run. (Development)
run:
    clear ; flutter run

# Flutter Run Linux. (Development)
rl:
    clear ; flutter run -d linux

# Clean
clean:
    flutter clean
    cd rust && cargo clean && cd ..
    cd lib_torrents_digger && cargo clean && cd ..
    cd tui && cargo clean && cd ..

# For Building Android Apk.
build_android_apk:
    clear ; flutter build apk --release

# For Building Universal APK in CI/CD
build_apk:
    flutter build apk --release
    # moving to releases dir
    mv build/app/outputs/flutter-apk/app-release.apk releases
    # Rename APK
    mv releases/app-release.apk releases/{{ env('UNIVERSAL_APK_NAME') }}
    # Generate SHA256
    sha256sum releases/{{ env('UNIVERSAL_APK_NAME') }} > releases/{{ env('UNIVERSAL_APK_NAME') }}.sha256.txt

# For Building APK per ABI in CI/CD
build_apk_per_abi:
    flutter build apk --release --split-per-abi
    # ARMEABI-V7A APK
    # moving to releases dir
    mv build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk releases
    # Rename APK
    mv releases/app-armeabi-v7a-release.apk releases/{{ env('ARMEABI_V7A_APK_NAME') }}
    # Generate SHA256
    sha256sum releases/{{ env('ARMEABI_V7A_APK_NAME') }} > releases/{{ env('ARMEABI_V7A_APK_NAME') }}.sha256.txt
    # ARM64-V8A APK
    # moving to releases dir
    mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk releases
    # Rename APK
    mv releases/app-arm64-v8a-release.apk releases/{{ env('ARM64_V8A_APK_NAME') }}
    # Generate SHA256
    sha256sum releases/{{ env('ARM64_V8A_APK_NAME') }} > releases/{{ env('ARM64_V8A_APK_NAME') }}.sha256.txt
    # X86_64 APK
    # moving to releases dir
    mv build/app/outputs/flutter-apk/app-x86_64-release.apk releases
    # Rename APK
    mv releases/app-x86_64-release.apk releases/{{ env('X86_64_APK_NAME') }}
    # Generate SHA256
    sha256sum releases/{{ env('X86_64_APK_NAME') }} > releases/{{ env('X86_64_APK_NAME') }}.sha256.txt

# For Building AppImage in CI/CD
build_appimage:
    # installing dependencies
    apt-get update -y && sudo apt-get upgrade -y
    apt-get install curl git unzip xz-utils zip libglu1-mesa build-essential libgtk-3-dev clang lld llvm cmake ninja-build pkg-config liblzma-dev -y
    apt install file fuse -y
    # creating temporary dir for downloading/saving appimagetool and this is ignored in VCS.
    # Downloading AppImageToolKit
    wget -P build_deps_dir -nc https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x build_deps_dir/appimagetool-x86_64.AppImage
    # Flutter Build release for linux
    flutter config --enable-linux-desktop
    flutter pub get
    flutter build linux --release
    # Copying release bundle to AppDir
    mkdir -p AppImage/AppDir/usr/bin
    cp -r build/linux/x64/release/bundle/* AppImage/AppDir/usr/bin/
    chmod +x AppImage/AppDir/AppRun
    ARCH=x86_64 ./build_deps_dir/appimagetool-x86_64.AppImage AppImage/AppDir {{ env('NEW_APPIMAGE_NAME') }}
    mv {{ env('NEW_APPIMAGE_NAME') }} releases/
    sha256sum releases/{{ env('NEW_APPIMAGE_NAME') }} > releases/{{ env('NEW_APPIMAGE_NAME') }}.sha256.txt
