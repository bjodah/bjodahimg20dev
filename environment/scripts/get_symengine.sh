#!/bin/bash -eu
#
# Example usage:
#
#  $ CXXFLAGS="-O3 -funroll-loops" ./get_symengine.sh v0.4.0 /opt/symengine-0.4.0 Release -DWITH_TCMALLOC=ON
#
TAG=$1
if [[ "$TAG" == v* ]]; then
    FNAME=symengine-${TAG:1}.tar.gz
else
    FNAME=symengine-${TAG}.tar.gz
fi
if [ ! -e $FNAME ]; then
    if [[ "$TAG" == v* ]]; then
        URL=https://github.com/symengine/symengine/releases/download/$TAG/symengine-${TAG:1}.tar.gz
    else
        URL=https://github.com/symengine/symengine/archive/$TAG.tar.gz
    fi
    curl -Ls $URL -o $FNAME
fi
SRCDIR="$PWD/${FNAME%.tar.gz}"
if [ ! -d $SRCDIR ]; then
    tar xzf $FNAME
    SRCDIR=$(echo "$SRCDIR"*/)
    if [ ! -d "$SRCDIR" ]; then
        2>&1 echo "Expected a foldername of extracted file: $SRCDIR"
        exit 1
    fi
fi
sed -i 's/-march=native//' $SRCDIR/cmake/UserOverride.cmake  # https://github.com/symengine/symengine/issues/1542
TMP_BLD_DIR=$(mktemp -d); trap "{ rm -r $TMP_BLD_DIR; }" INT TERM EXIT
cd $TMP_BLD_DIR
cmake -DBUILD_SHARED_LIBS=ON -DWITH_LLVM=ON -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF -DCMAKE_INSTALL_PREFIX=$2 -DCMAKE_BUILD_TYPE=$3 "${@:4}" "$SRCDIR"
make
ctest --output-on-failure --exclude-regex "(test_bipartite)|(test_hopcroft_karp)"  # https://github.com/symengine/symengine/pull/1543
make install
