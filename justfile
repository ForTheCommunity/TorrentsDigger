AppName := "torrents_digger"
AppVersion := "1.0.7"

f_w:
	clear ; dart run build_runner watch -d

frb_w:
	clear ; flutter_rust_bridge_codegen generate --watch

run:
	clear ; flutter run

rl:
	clear ; flutter run -d linux

build_apk:
	clear ; flutter build apk --release

build_linux:
	clear ; flutter build linux --release

build_appimage:
	# installing dependencies
	apt-get update -y && sudo apt-get upgrade -y
	apt-get install curl git unzip xz-utils zip libglu1-mesa  build-essential libgtk-3-dev clang cmake ninja-build pkg-config liblzma-dev -y
	apt install file fuse -y
	# creating temporary dir for downloading/saving appimagetool and this is ignored in VCS.
	# Downloading AppImageToolKit
	mkdir -p build_deps_dir build_deps_dir releases
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
	ARCH=x86_64 ./build_deps_dir/appimagetool-x86_64.AppImage AppImage/AppDir {{AppName}}_{{AppVersion}}_x86_64_linux.AppImage
	mv {{AppName}}_{{AppVersion}}_x86_64_linux.AppImage releases
	sha256sum releases/{{AppName}}_{{AppVersion}}_x86_64_linux.AppImage > releases/{{AppName}}_{{AppVersion}}_x86_64_linux.AppImage.sha256.txt
