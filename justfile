run:
	clear ; flutter run
rl:
	clear ; flutter run -d linux
build_apk:
	clear ; flutter build apk --release
build_linux:
	clear ; flutter build linux --release
f_w:
	clear ; dart run build_runner watch -d
frb_w:
	clear ; flutter_rust_bridge_codegen generate --watch
