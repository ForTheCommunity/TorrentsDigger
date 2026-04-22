### Contributing Guides.

1. install [Dart, Flutter](https://docs.flutter.dev/install#get-started) and their dependencies.
2. install [Rust](https://www.rust-lang.org/tools/install)
3. install [Flutter Rust Bridge](https://cjycode.com/flutter_rust_bridge/quickstart)
4. install [Just](https://just.systems)
5. clone this Repo.
```
git clone https://gitlab.com/ForTheCommunity/torrentsdigger.git
```

6. Run these commands inside the project root directory. These two commands should always be run in the background while doing development.

```
just f_w
```
```
just frb_w
```

7. Run App :
```
just run
```

###  List all available Just Recipes :
```
just --list
```


## Note : Check [Current Versions File](./.current_versions.txt) for Rust & Flutter version. Use these version for developing this project.




# Guides for building Torrents Digger for Flatpak.

## 1. We use [Flatpak-Flutter](https://github.com/TheAppgineer/flatpak-flutter) for generating essential files, that is necessary for building our project for Flatpak.
```
{..<PATH>..}/flatpak-flutter.py flatpak-flutter.yml
```

## 2. Install Required Platform Extensions:
```
flatpak install flathub org.freedesktop.Sdk//25.08 org.freedesktop.Platform//25.08 org.freedesktop.Sdk.Extension.llvm20/x86_64/25.08
```

## 3. Compiling App & Preparing Local Repository.

```
flatpak-builder --repo=repo --force-clean --sandbox --user build io.gitlab.ForTheCommunity.torrentsdigger.yml
```

## 4. Building .flatpak package.
```
flatpak build-bundle repo torrents_digger.flatpak io.gitlab.ForTheCommunity.torrentsdigger
```

## 5. Install Generated Flatpak (in Userspace).
```
 flatpak install --user ./torrents_digger.flatpak
```

## 6. Run Installed Flatpak.
```
flatpak run io.gitlab.ForTheCommunity.torrentsdigger
```

## 7. Installing Flatpak-Builder.
```
flatpak install flathub org.flatpak.Builder
```

## 8. Manifest Lint Check.
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.gitlab.ForTheCommunity.torrentsdigger.yml
```

## 9. Repo Lint Check:
```
flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
```