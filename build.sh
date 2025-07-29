#!/bin/bash

if [ $# -ne 1 ]; then
    echo "not found target"
    exit 1
fi

TARGET=$1

git clone https://github.com/holepunchto/bare.git bare --depth=1
cd bare

npm i -g bare-make
npm i
bare-make generate --no-cache

bare-make build

mkdir ../dist

cp -r ./build/bin/bare ../dist/bare

cd ..

ls -lh dist

tar -czf ./bare-${TARGET}.tar.gz -C dist .
ls -l ./bare-${TARGET}.tar.gz