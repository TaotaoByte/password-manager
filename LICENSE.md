# 开源许可

LocalVault 由多个开源组件和本仓库的构建、测试、文档组成。各组件的许可证、版权声明和额外条款随对应源码保留。

| 范围 | 许可证 | 许可证全文 |
| --- | --- | --- |
| Windows 客户端、KeePassXC 定制补丁 | GPL-2.0-or-later，原文件的许可和附加条款继续适用 | [KeePassXC COPYING](licenses/KeePassXC-COPYING.txt) |
| Android 客户端、KeePassDX 定制补丁 | GPL-3.0-or-later，原文件的许可和附加条款继续适用 | [KeePassDX LICENSE](licenses/KeePassDX-LICENSE.txt) |
| Chromium 扩展、KeePassXC-Browser 定制补丁 | GPL-3.0，原文件的许可和附加条款继续适用 | [KeePassXC-Browser LICENSE](licenses/KeePassXC-Browser-LICENSE.txt) |
| 本仓库原创的构建脚本、测试和说明 | GPL-3.0-or-later | [GNU GPL 3.0](LICENSE) |

精确的上游提交号记录在 [upstream.lock.json](upstream.lock.json)。运行 [Restore-Sources.ps1](scripts/Restore-Sources.ps1) 下载这些源码并应用 [定制补丁](patches)，即可获得构建本项目所需的对应源码与上游版权声明。Windows 便携包附带运行时依赖的授权文本。第三方商标和名称归各自权利人所有。
