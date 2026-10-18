#!/bin/bash
# 当前文件：在 macOS 上本地构建 Folia iOS IPA 的脚本。
# 用法：
#   无签名（用于 AltStore / SideStore / TrollStore 侧载）：
#     ./build-ios-ipa.sh
#   有签名（需要 Apple Developer 证书与描述文件）：
#     ./build-ios-ipa.sh --sign

set -euo pipefail

cd "$(dirname "$0")"

SIGN=false
if [ "${1:-}" = "--sign" ]; then
  SIGN=true
fi

echo "==> 安装依赖"
npm ci --no-audit --no-fund

echo "==> 构建 Web 资源（Capacitor 模式）"
npm run build:capacitor

echo "==> 同步 iOS 平台"
npx cap sync ios

echo "==> 生成 iOS 图标与启动图"
if [ ! -f assets/icon.png ]; then
  node -e "require('sharp')('build/icon.png').resize(1024,1024).png().toFile('assets/icon.png')"
fi
npx capacitor-assets generate --ios --iconBackgroundColor '#09090b' --splashBackgroundColor '#09090b'

cd ios/App

if [ "$SIGN" = true ]; then
  echo "==> 构建签名 IPA"
  xcodebuild \
    -scheme App \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath build/Folia.xcarchive \
    -allowProvisioningUpdates \
    archive

  cat > exportOptions.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>uploadSymbols</key>
  <false/>
  <key>signingStyle</key>
  <string>automatic</string>
</dict>
</plist>
EOF

  xcodebuild \
    -exportArchive \
    -archivePath build/Folia.xcarchive \
    -exportPath build/ipa \
    -exportOptionsPlist exportOptions.plist \
    -allowProvisioningUpdates

  IPA=$(ls build/ipa/*.ipa | head -1)
  echo "==> 签名 IPA 已生成：$IPA"
  cp "$IPA" ../../Folia-signed.ipa
else
  echo "==> 构建无签名 IPA（可侧载）"
  xcodebuild \
    -scheme App \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath build/Folia.xcarchive \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    archive

  echo "==> 打包为 IPA"
  mkdir -p build/Payload
  cp -R build/Folia.xcarchive/Products/Applications/App.app build/Payload/
  rm -rf build/Payload/App.app/_CodeSignature
  rm -f build/Payload/App.app/embedded.mobileprovision
  cd build
  zip -qr ../../Folia-unsigned.ipa Payload
  cd ../..
  echo "==> 无签名 IPA 已生成：Folia-unsigned.ipa"
fi

cd ../..
echo "==> 完成！"
