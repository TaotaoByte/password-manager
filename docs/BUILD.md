# 构建

固定源版本见 `upstream.lock.json`；定制直接保存在 `upstream` 下，补丁由 `scripts/export-patches.py` 导出。首次网络受限时可以使用带官方 SHA-256 的 `scripts/download.py` 下载大文件，禁止跳过校验。

## Windows

使用项目内 `.tools/msys64`，或指定自己的 MSYS2 根目录。UCRT64 依赖：

```sh
pacman -S --needed mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-qt6-base mingw-w64-ucrt-x86_64-qt6-tools mingw-w64-ucrt-x86_64-qt6-svg mingw-w64-ucrt-x86_64-libbotan mingw-w64-ucrt-x86_64-argon2 mingw-w64-ucrt-x86_64-minizip mingw-w64-ucrt-x86_64-qrencode mingw-w64-ucrt-x86_64-openssl mingw-w64-ucrt-x86_64-readline
```

```powershell
./scripts/Build-Windows.ps1
```

脚本在测试通过后先安装到 `build/windows-package`，从该目录生成便携 ZIP，再更新 `dist/windows`。发布包使用独立的中文默认配置，主题为自动；部署时保留已有 `config`，旧版可执行文件备份到 `.tools/rollback`。若目标程序仍在运行，部署会停止，需正常退出后执行 `scripts/Deploy-Windows.ps1`，已生成的新版和 ZIP 会保留。

便携包包含上游许可证及实际构建依赖版本。独立构建目录为 `build/windows`。新增的 `testlocalvaultappearance` 使用临时配置和内存中的虚构账号，验证欢迎页操作、最近文件路径、两种主题与小窗口布局，并生成 `build/ui-previews` 中的预览，不读取个人密码库。定制版关闭自动更新，升级应通过固定新上游版本、审查和重放补丁完成。

## Android

JDK 17 或 21、Gradle 8.14.2、Android SDK platform 36、build-tools 35.0.0，项目声明的依赖仍从上游仓库解析。SDK 与私有签名材料不纳入项目。

```powershell
./scripts/Build-Android.ps1 -JavaHome 'C:/Java/JDK21' -AndroidSdk 'C:/Android/Sdk'
```

默认生成测试签名 APK。正式长期使用的 APK 必须用自己的持久签名密钥构建；用环境变量 `LOCALVAULT_KEYSTORE`、`LOCALVAULT_KEY_ALIAS`、`LOCALVAULT_STORE_PASSWORD`、`LOCALVAULT_KEY_PASSWORD` 提供签名配置，然后添加 `-Release`。不要将密钥或口令写进脚本、日志或仓库。丢失签名密钥将无法原地升级。

定制版 applicationId 为 `dev.localvault.keepassdx.libre`，可与原版并存；自动填充服务需重新选择，原版生物识别和设置不会自动迁移。打开或传入相同加密 KDBX 文件即可复用数据。

构建脚本默认禁用配置缓存并使用进程内 Kotlin 编译，避免 Windows 遗留守护进程锁定 R.jar。SDK 原生构建还使用 NDK 25.2.9519653 与 CMake 3.22.1，Gradle 可在已有许可的 SDK 中补齐。

本机因 Maven 大文件下载不稳定，使用 `.tools/offline-tests.init.gradle` 为一个经官方 SHA-256 校验的 Robolectric 运行库指定本地缓存；业务依赖仓库未改动。全新环境没有该文件时使用上游正常仓库。

`app/lint-baseline.xml` 只保留 7 个来自固定上游、影响 API 21 以下的矢量资源问题。新增界面仅提供英文回退与简体中文，对该独立资源文件声明有限翻译范围。其他 Lint 检查继续执行，现有警告数量见验收记录。

## 浏览器

先用 `scripts/Restore-Sources.ps1` 恢复固定版本与界面补丁，再运行 `scripts/Package-Browser.ps1`。脚本将 Chromium 开发测试版生成到 `dist/browser`，并生成 ZIP。安装、手动授权扩展 ID 和配对步骤见 Windows 使用说明。浏览器密码通信协议沿用上游。
