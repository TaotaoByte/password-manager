# 首版验收记录

## 2026-11-19：Android 界面预览 v0.3.0-android

- 发布 APK 在 Android 14 模拟器安装并解锁虚构 KDBX，核对简体中文账号列表、浅色与深色界面，以及底部弧边折射。实点库菜单、输入查询找到测试账号，再锁定回到解锁界面。默认截屏保护未改；截图仅在模拟器的演示实例中开启截屏模式后拍摄。
- 同一 APK 在 Android 11 模拟器安装并打开测试库，核对列表和半透明降级底栏。Android 12 的模糊分支及红米 K80 Pro 实机的画面、流畅度和系统自动填充仍待验证。
- 17 个单元测试通过，Lint 无新增错误（391 个警告、1 个提示、7 个已有基线错误）。4 个原生库的 16 KB ELF 对齐和 APK Zipalign 检查通过。
- APK SHA-256：`084f3f01487a6f55aed5090f7c2eb015eb171661799753ad358ed541bb323209`。

## 2026-11-19：三端界面与发布

- Windows 11 使用二栏首页与统一的浅色、深色样式。六组核心回归、四个 GUI 流程和双主题界面测试通过，覆盖小窗口、最近库和搜索。
- Android 测试 APK 已构建，单元测试和 16 KB ELF／APK 对齐检查通过。Lint 无未基线化错误，386 个警告、1 个提示，仍保留首版的 7 个上游基线项。
- Android 14 模拟器打开虚构库，检查两种颜色模式。实点底部按钮，打开库菜单、输入查询找到测试条目、锁定并回到密码库解锁界面。
- Chromium 扩展的默认弹窗与设置页已用加载实际打包目录的 Chrome for Testing 检查，验证冷启动、设置按钮键盘焦点、浅色和深色。该测试环境没有连接桌面密码库。实际安装的 Chrome 与 Edge 共 22 项上游测试通过，2 项按上游配置跳过。定制 ID 的真实配对、网站保存与更新仍待端到端复测。
- Redmi K80 Pro 的 HyperOS 权限、键盘内建议和后台启动需要实机确认。
- 本轮构建记录位于 `build/ui2-windows-final.log`、`build/ui2-android-final.log`、`build/ui2-browser-tests.log` 和 `build/ui2-browser-preview.log`。发布截图及来源说明见 README。

日期：2026-11-08。全部交互测试使用项目专用模拟器和公开的虚构账号，没有读取真实密码或操作真实手机。

## 2026-11-19：Windows 界面与项目入口更新

- 已重新构建并更新 `dist/windows/KeePassXC.exe` 和 `dist/LocalVault-Windows-x64.zip`；新增根目录启动文件及「00-先看这里.md」。
- 欢迎页改为中文卡片布局；浅色、深色共用布局并使用各自配色，默认沿用系统主题。打开密码库后显示账号工具栏、新建文字按钮和搜索框；小窗口首页支持滚动。
- Windows 11 原生 Qt 环境：界面测试 5 项 PASS（包含初始化／清理），覆盖创建／打开／导入信号、最近文件完整路径及移除、浅色／深色、800×560 布局、工具栏状态及虚构账号的搜索／清空。没有修改系统主题来测试操作系统切换事件。
- 六组核心测试全部重新通过；快捷新增确认／取消、锁定、备份、合并的 GUI 回归全部重新通过（含初始化／清理 6 项 PASS）。
- 额外 GUI 测试中，新增、删除、设置通过。完整 `testSearch` 在密码复制断言处失败，Windows 返回 `OleSetClipboard` / `OpenClipboard` 错误；单独原生重试仍失败。搜索筛选、清空另由界面测试覆盖通过，**原生系统剪贴板密码复制仍待复测**。未关闭剪贴板保护、历史排除或其他安全设置来绕过失败。无头模式的完整搜索测试未完成并已结束，不计作通过。
- 部署前后原有 `dist/windows/config/keepassxc.ini` 的 SHA-256 一致；安装的 EXE 与独立打包目录一致。旧版三个 EXE 备份在 `.tools/rollback/windows-20261119-154543`。ZIP 使用独立默认配置（中文、自动主题、保存前备份），不包含本机个人配置或密码库。
- 本轮未修改安卓或浏览器扩展产物，先前的设备验证范围和待验收项继续适用。

本轮报告：`build/ui-package.log`、`build/windows/appearance-results.txt`、`build/windows/ui-regression-results.txt`、`build/windows/ui-search-native-retry.txt`。预览在 `build/ui-previews`，全部来自私有临时配置与内存中的虚构账号；预览中禁用了全局热键并隐藏了一次性开发构建横幅，程序仍保留原有横幅。

## 已生成产物

- `dist/LocalVault-Windows-x64.zip`：Windows 11 x64 便携包，包含 `.portable`、中文配置、默认保存前备份及运行时许可证。
- `dist/android/LocalVault-Android-test.apk`：**测试签名、可调试 APK**，可与原版并存；长期使用的正式签名构建见 BUILD.md。
- `dist/KeePassXC-Browser-1.10.4.1-Chromium.zip`：Edge / Chrome 开发者模式测试包。日常建议安装官方商店版本。
- 源码位于 `upstream`，定制补丁位于 `patches`，精确上游提交号位于 `upstream.lock.json`。
- 产物摘要位于 `dist/SHA256SUMS.txt`。

## 已完成的检查

| 检查 | 结果与范围 |
|---|---|
| 安卓上游基线 | 固定的 KeePassDX 4.5.8 未修改源码在独立目录离线构建成功 |
| Windows 构建 | GCC / Qt UCRT64 构建成功；可独立运行便携 CLI，版本 2.8.0-localvault.1 |
| Windows 回归 | `testkdbx4`、`testkeys`、`testautotype`、`testentry`、`testmerge`、`testbrowser` 全部通过 |
| Windows GUI | 快捷新增确认／取消、密码库锁定、保存备份、合并测试通过；报告包含初始化与清理共 6 项 PASS |
| 自动输入 | 24 项测试通过；默认不按 Enter，用户显式输入序列保留 |
| 浏览器 | 本机独立无头 Chrome / Edge：22 项通过，2 项为上游主动跳过 |
| 安卓构建 | 定制 APK 构建成功，17 项单元测试通过，包含品牌识别、Android 11／14 引导生命周期 |
| Android Lint | 0 个未基线化错误，367 个警告、1 个提示；7 个未修改的上游 API 21 以下矢量资源错误精确列入 baseline，未全局关闭检查 |
| 16 KB 兼容 | arm64-v8a / x86_64 的 AES、Argon2 共 4 个 native ELF 检查通过，APK `zipalign -c -P 16 4` 通过 |
| 跨端读取与填充 | KeePassXC CLI 创建 KDBX 4 虚构库→Android 11 解锁→按 `AndroidApp` 匹配测试应用→真实系统 Autofill 填入账号及密码，均已验证 |
| 模拟器安装启动 | Android 11、14、17 均通过；17 实例实测页大小 16384 字节 |
| 源码维护 | 两份补丁导出、已修改源码的反向检查及 Restore-Sources 幂等运行通过；脚本语法与 diff 空白检查通过 |

Windows 自定义产品版本号不直接用于浏览器能力判断：浏览器回复保留对应上游数字版本 `2.8.0`，避免官方扩展将自定义后缀当成较旧 API。此行为有回归断言覆盖。

## 仍待验证

- 红米 K80 Pro 的实际 Android / HyperOS 完整版本、后台限制、指纹解锁及系统输入法行为。
- Android 14／17 完整填充链路，各版本的新增保存、改密更新、多账号与取消场景。
- Android 修改后的文件回传 Windows、冲突合并后再次传回安卓的完整双向流程；Windows 合并算法本身已有测试。
- Windows 真实第三方软件中的全局热键、焦点变化和权限差异，以及实际网站的扩展配对、注册／改密流程。
- 三星、OPPO／一加、vivo 实机验证。

模拟器中打开系统保存提示的完整流程未完成，因此不将其标记为通过。继承的上游功能与本轮实际验收结果分别记录，不宣称通过独立安全审计。

## 报告位置

- `build/windows-package.log`、`build/windows/Testing/Temporary/LastTest.log`、`build/windows/gui-results.txt`
- `build/browser-results.json`
- `build/android-final.log`
- `upstream/keepassdx/app/build/reports/tests/testLibreDebugUnitTest/index.html`
- `upstream/keepassdx/app/build/reports/lint-results-libreDebug.html`
- `build/android30-*.xml`：只包含一次性模拟器与虚构测试数据，不包含用户数据。

测试表单源码在 `tests/android-fixture`；通过 `Create-TestVault.py` 与 `Build-AndroidFixture.ps1` 构建，产物仅放 `build`，不打包进正式应用。测试库的公开主密码仅用于虚构数据，禁止复用于个人密码库。
