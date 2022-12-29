#!/bin/bash

version="$(awk -F "=" '/version=/ {print $2}' ./module.prop)"
FILENAME="Sing4Magisk_$version.zip"

zip -r -o -X -ll "$FILENAME" ./ -x '.git/*' -x 'build.sh' -x '.github/*' -x 'Sing4Magisk.json' -x '.gitignore' -x 'README*.md' -x '*.zip'
