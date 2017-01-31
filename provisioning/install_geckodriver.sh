#!/usr/bin/env bash

set -e

VERSION="0.13.0"

OS_NAME="linux64"
if [[ $(uname) == "Darwin" ]]; then
  OS_NAME="macos"
fi

echo ">>> Installing geckodriver for ${OS_NAME}"
echo ">>> Downloading..."
wget https://github.com/mozilla/geckodriver/releases/download/v${VERSION}/geckodriver-v${VERSION}-${OS_NAME}.tar.gz

echo ">>> Installing..."
tar -xvzf geckodriver-v${VERSION}-${OS_NAME}.tar.gz
chmod +x geckodriver
if [ "$TRAVIS" = "true" ]; then
 sudo mv geckodriver /usr/local/bin
else
  mv geckodriver /usr/local/bin
fi

echo ">>> Cleaning up..."
rm geckodriver-v${VERSION}-${OS_NAME}.tar.gz

echo ">>> Done"
