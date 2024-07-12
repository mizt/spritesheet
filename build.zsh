cd "$(dirname "$0")"
cd ./

set -eu

clang++ -std=c++20 -Wc++20-extensions -fobjc-arc -O3 \
-framework Cocoa \
-I../libs/turbojpeg -L../libs/turbojpeg -lturbojpeg \
./main.mm \
-o ./main

./main