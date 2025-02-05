#!/bin/bash
set -xe

pkg install -y gcc g++ cmake make autoconf automake libtool python2 python3
pkg install -y mbedtls mbedtls-static zlib rapidjson pcre2

git clone https://github.com/curl/curl --depth=1 --branch curl-8_6_0
cd curl
cmake -DCURL_USE_MBEDTLS=ON -DHTTP_ONLY=ON -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_USE_LIBSSH2=OFF -DBUILD_CURL_EXE=OFF . > /dev/null
make install -j2 > /dev/null
cd ..

git clone https://github.com/jbeder/yaml-cpp --depth=1
cd yaml-cpp
cmake -DCMAKE_BUILD_TYPE=Release -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF . > /dev/null
make install -j3 > /dev/null
cd ..

git clone https://github.com/ftk/quickjspp --depth=1
cd quickjspp
cmake -DCMAKE_BUILD_TYPE=Release .
make quickjs -j3 > /dev/null
install -d /usr/local/lib/quickjs/
install -m644 quickjs/libquickjs.a /usr/local/lib/quickjs/
install -d /usr/local/include/quickjs/
install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h /usr/local/include/quickjs/
install -m644 quickjspp.hpp /usr/local/include/
cd ..

git clone https://github.com/PerMalmberg/libcron --depth=1
cd libcron
git submodule update --init
cmake -DCMAKE_BUILD_TYPE=Release .
make libcron install -j3
cd ..

git clone https://github.com/ToruNiina/toml11 --branch="v3.7.1" --depth=1
cd toml11
cmake -DCMAKE_CXX_STANDARD=11 .
make install -j4
cd ..

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
cmake -DCMAKE_BUILD_TYPE=Release .
make -j3
rm subconverter
# shellcheck disable=SC2046
g++ -o base/subconverter $(find CMakeFiles/subconverter.dir/src/ -name "*.o") -static -lpcre2-8 -lyaml-cpp -L/usr/local/lib -lcurl -lmbedtls -lmbedcrypto -lmbedx509 -lz -l:quickjs/libquickjs.a -llibcron [...]

python3 -m ensurepip
python3 -m pip install gitpython
python3 scripts/update_rules.py -c scripts/rules_config.conf

cd base
chmod +rx subconverter
chmod +r ./*
cd ..
mv base subconverter