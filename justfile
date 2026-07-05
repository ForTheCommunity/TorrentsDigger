# Build Runner(Freezed). (Development)
f_w:
    # clear; dart run build_runner watch -d
    clear; \
    RED='\033[0;31m'; \
    YELLOW='\033[1;33m'; \
    ROSE='\033[1;35m'; \
    NC='\033[0m'; \
    printf "${ROSE}_____Executing Build Runner_____\\n${NC}"; \
    while true; do \
    dart run build_runner watch -d; \
    if [ $? -ne 0 ]; then \
    printf "${RED}_____Dart Build Runner Failed_____\\n${NC}"; \
    printf "${ROSE}_____ReExecuting Build Runner_____\\n${NC}"; \
    else \
    printf "${YELLOW}_____Dart Build Runner is Running_____\\n${NC}"; \    break; \
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
