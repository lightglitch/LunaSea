#!/usr/bin/env bash

# Remove old builds
rm -rf build
rm -rf output/*.ipa
# Clean and build
flutter clean
flutter build ipa --export-options-plist=ios/ExportOptions.plist
# Copy IPA to root of project
mkdir -p output
cp build/ios/ipa/LunaSea.ipa output/LunaSea-arm64-release.ipa
# Remove build files
rm -rf build
rm -rf ios/build
