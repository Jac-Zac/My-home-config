#!/usr/bin/env sh

SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID)

case ${SOURCE} in
'com.apple.keylayout.ABC') LABEL='ABC' ;;
'com.apple.keylayout.Italian-Pro') LABEL='IT' ;;
esac

sketchybar --set $NAME label="$LABEL"
