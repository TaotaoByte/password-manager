#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root="$PWD"
package_dir="$root/build/windows-package"
if [ -n "${LOCALVAULT_PACKAGE_DIR:-}" ]; then
    package_dir="$(cygpath -u "$LOCALVAULT_PACKAGE_DIR")"
fi
cmake -S upstream/keepassxc -B build/windows -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$root/dist/windows" \
  -DKPXC_FEATURE_BROWSER=ON -DKPXC_FEATURE_UPDATES=OFF -DKPXC_FEATURE_DOCS=OFF \
  -DWITH_TESTS=ON -DWITH_GUI_TESTS=ON -DOVERRIDE_VERSION=2.8.0-localvault.1 \
  -DGIT_HEAD_OVERRIDE=1c2f23ef5914c0f442a00533def1689857afb5a7
cmake --build build/windows --parallel 4
ctest --test-dir build/windows --output-on-failure \
  -R '^(testentry|testautotype|testmerge|testkdbx4|testkeys|testbrowser)$'
# GUI tests create their own temporary database and config.
build/windows/tests/gui/testgui.exe testQuickSaveConfirmAndCancel testDatabaseLocking testSaveBackup testMergeDatabase \
  -o "$root/build/windows/gui-results.txt,txt"
LOCALVAULT_PREVIEW_DIR="$root/build/ui-previews" \
LOCALVAULT_TRANSLATIONS_DIR="$root/build/windows/share/translations" \
  build/windows/tests/gui/testlocalvaultappearance.exe -o "$root/build/windows/appearance-results.txt,txt"
cmake --install build/windows --config Release --prefix "$package_dir"
# KeePassXC 2.8 uses a .portable marker and a config subdirectory.
touch "$package_dir/.portable"
mkdir -p "$package_dir/config"
if [ ! -f "$package_dir/config/keepassxc.ini" ]; then
    printf '[General]\nBackupBeforeSave=true\n\n[GUI]\nLanguage=zh_CN\nApplicationTheme=auto\n' > "$package_dir/config/keepassxc.ini"
fi
mkdir -p "$package_dir/licenses"
cp upstream/keepassxc/COPYING "$package_dir/licenses/KeePassXC-COPYING.txt"
mkdir -p "$package_dir/licenses/dependencies"
cp -R /ucrt64/share/licenses/. "$package_dir/licenses/dependencies/"
cp docs/ANDROID-SETUP.zh-CN.md "$package_dir/安卓设置与同步.md"
cp docs/WINDOWS-SETUP.zh-CN.md "$package_dir/Windows使用说明.md"
pacman -Q > "$package_dir/build-dependencies.txt"
printf '\nWindows package built and regression tests passed.\n'
