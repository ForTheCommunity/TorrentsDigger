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
    cd flatpak && just clean && cd ..

# For Building Android Apk.
build_android_apk:
    clear ; flutter build apk --release


dns_test:
    sudo tcpdump -i any port 53 -n
