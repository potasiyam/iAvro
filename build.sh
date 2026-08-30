#!/bin/bash
# ponytail: hand-rolled clang build — no Xcode/CocoaPods needed, CLT only.
# Vendor/ holds FMDB 2.7.5 + RegexKitLite 4.0 (the Podfile deps), fetched once.
set -e
cd "$(dirname "$0")"
SDK=$(xcrun --show-sdk-path)
ARCHS="-arch arm64"
MINVER=11.0  # ponytail: Big Sur floor — first arm64 macOS; raise if a newer API sneaks in
APP="build/Avro Keyboard.app"
ID=com.omicronlab.inputmethod.AvroKeyboard

mkdir -p build
for f in *.m Vendor/*.m; do
  clang -c $ARCHS -mmacosx-version-min=$MINVER -isysroot "$SDK" -IVendor -Wno-deprecated-declarations \
    -o "build/$(basename "${f%.m}").o" "$f"
done
clang $ARCHS -mmacosx-version-min=$MINVER -isysroot "$SDK" -o "build/Avro Keyboard" build/*.o \
  -framework Cocoa -framework InputMethodKit -lsqlite3 -licucore

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/en.lproj" "$APP/Contents/Resources/Icons"
cp "build/Avro Keyboard" "$APP/Contents/MacOS/Avro Keyboard"
sed -e "s/\$(PRODUCT_BUNDLE_IDENTIFIER)/$ID/" -e 's/«PROJECTNAME»/Avro Keyboard/' \
  Info.plist > "$APP/Contents/Info.plist"
cp -R English.lproj/MainMenu.nib English.lproj/preferences.nib English.lproj/InfoPlist.strings "$APP/Contents/Resources/en.lproj/"
cp Icons/*.png "$APP/Contents/Resources/Icons/"
cp -R Credits.rtfd data.json regex.json autodict.dct autodict.plist database.db3 preferences.plist "$APP/Contents/Resources/"
codesign --force -s - "$APP"
echo "Built: $APP"
