FROM bjodah/bjodahimg20:v1.2
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>

RUN \
    export CC=clang-10 CXX=clang++-10 && \
    export LLVM_ORG_VER=10.0.1-rc1 && \
    export LLVM_MAJOR=$(echo $LLVM_ORG_VER | cut -f1 -d.) && \
    curl -Ls https://github.com/llvm/llvm-project/archive/llvmorg-${LLVM_ORG_VER}.tar.gz | tar xz -C /tmp && \
    mkdir /tmp/build_libcxx && \
    cd /tmp/build_libcxx && \
    cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_SANITIZER=MemoryWithOrigins -DLLVM_CONFIG_PATH=/usr/bin/llvm-config-$LLVM_MAJOR -DCMAKE_INSTALL_PREFIX=/opt/libcxx${LLVM_MAJOR}_msan /tmp/llvm-project-llvmorg-${LLVM_ORG_VER}/libcxx && \
    cmake --build . && \
    cmake --build . --target install && \
    mkdir /tmp/build_libcxxabi &&  \
    cd /tmp/build_libcxxabi &&  \
    cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_SANITIZER=MemoryWithOrigins -DLLVM_CONFIG_PATH=/usr/bin/llvm-config-${LLVM_MAJOR} -DCMAKE_INSTALL_PREFIX=/opt/libcxx${LLVM_MAJOR}_msan -DLIBCXXABI_LIBCXX_INCLUDES=/opt/libcxx${LLVM_MAJOR}_msan/include/c++/v1 -DLIBCXXABI_LIBCXX_PATH=/tmp/llvm-project-llvmorg-${LLVM_ORG_VER}/libcxx  /tmp/llvm-project-llvmorg-${LLVM_ORG_VER}/libcxxabi &&  \
    cmake --build .  && \
    cmake --build . --target install && \
    cp /tmp/llvm-project-llvmorg-${LLVM_ORG_VER}/libcxxabi/include/* /opt/libcxx${LLVM_MAJOR}_msan/include/ && \
    rm -r /tmp/build_* /tmp/llvm-project*


COPY scripts/get_sundials.sh /opt/
# -fsanitize-memory-track-origins=2
RUN \
    CC=clang-10 CFLAGS="-fsanitize=memory -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -fno-optimize-sibling-calls -O1" /opt/get_sundials.sh 5.3.0 /opt/sundials-5.3.0-msan -DLAPACK_ENABLE=OFF -DKLU_ENABLE=OFF -DSUNDIALS_INDEX_SIZE=32 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY scripts/get_symengine.sh /opt/
RUN \
    CC=clang-10 CXX=clang++-10 CXXFLAGS="-std=c++14" \
        /opt/get_symengine.sh 0179ce2f1b4cbcc8e0940555446d49f78c54f762 /opt/symengine-0179ce2-rel Release -DWITH_CPP14=ON -DWITH_COTIRE=OFF -DWITH_BFD=OFF -DWITH_LLVM=ON && \
    CC=clang-10 CXX=clang++-10 CXXFLAGS="-std=c++14" \
        /opt/get_symengine.sh 0179ce2f1b4cbcc8e0940555446d49f78c54f762 /opt/symengine-0179ce2-tcm Release -DWITH_CPP14=ON -DWITH_COTIRE=OFF -DWITH_BFD=OFF -DWITH_LLVM=ON -DWITH_TCMALLOC=ON && \
    export CMAKE_PREFIX_PATH=/usr/lib/llvm-10 && \
    export CPLUS_INCLUDE_PATH=/opt/boost_1_73_p/include && cd /tmp && \
    CC=gcc-10   CXX=g++-10 CXXFLAGS="-std=c++14 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -fsized-deallocation" \
        /opt/get_symengine.sh 0179ce2f1b4cbcc8e0940555446d49f78c54f762 /opt/symengine-0179ce2-dbg Debug   -DWITH_CPP14=ON -DWITH_COTIRE=OFF -DWITH_BFD=OFF -DWITH_LLVM=OFF -DINTEGER_CLASS=boostmp

RUN CC=clang-10 CXX=clang++-10 \
    CXXFLAGS="-std=c++14 $CXXFLAGS -fsanitize=memory -fsanitize-memory-track-origins=2 -stdlib=libc++ -I/opt/libcxx10_msan/include -I/opt/libcxx10_msan/include/c++/v1 -fno-omit-frame-pointer -fno-optimize-sibling-calls -O1 -glldb -DHAVE_GCC_ABI_DEMANGLE=no" \
    LDFLAGS="-fsanitize=memory -fsanitize-memory-track-origins=2 $LDFLAGS -Wl,-rpath,/opt/libcxx10_msan/lib -L/opt/libcxx10_msan/lib -lc++abi" \
        /opt/get_symengine.sh 0179ce2f1b4cbcc8e0940555446d49f78c54f762 /opt/symengine-0179ce2-msan Debug -DWITH_CPP14=ON -DWITH_COTIRE=OFF -DWITH_BFD=OFF -DWITH_SYMENGINE_RCP=ON -DINTEGER_CLASS=boostmp \
        -DBOOST_ROOT=/opt/boost_1_73_p

RUN \
    curl -Ls "https://vorboss.dl.sourceforge.net/project/swig/swig/swig-4.0.1/swig-4.0.1.tar.gz" | tar xz && cd swig-* && CXX=g++-10 CC=gcc-10 ./configure && make && make install

RUN \
    sed -i 's/rights="none"/rights="read | write"/g' /etc/ImageMagick-6/policy.xml && \
    strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5 && echo stackoverflow.com/questions/54582864/ >/dev/null && \
    wkhtmltopdf --help >/dev/null

RUN \
    apt-get update && apt-get dist-upgrade -y && \
    apt-get --quiet --assume-yes --no-install-recommends install rr gcovr tmux libjson-c-dev libwebsockets-dev hunspell less texinfo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
    mkdir -p /tmp/cpy39/build && cd /tmp/cpy39 && \
    curl -Ls https://www.github.com/python/cpython/archive/3.9.tar.gz | tar xz -C /tmp/cpy39 --strip-components=1 && \
    cp -ra /tmp/cpy39 /tmp/cpy39-dbg && \
    cd /tmp/cpy39/build && \
    CC=gcc-10 CXX=g++-10 CFLAGS="-O2" .././configure \
      --prefix=/opt/cpython-3.9 \
      --enable-loadable-sqlite-extensions \
      --enable-shared \
      --with-ensurepip=yes \
      LDFLAGS=-Wl,-rpath=/opt/cpython-3.9/lib \
      && \
    make install && \
    /opt/cpython-3.9/bin/python3 -c "import sqlite3, uuid, lzma, bz2" && \
        cd /tmp; rm -r /tmp/cpy39

#        && \
#      CC=clang-10 CXX=clang++-10 CFLAGS="-Og -glldb -fsanitize=address -fno-omit-frame-pointer" .././configure \
#      --with-address-sanitizer \
#      --disable-ipv6 \
# NPY_DISTUTILS_APPEND_FLAGS=1 LDFLAGS="-fsanitize=address"

RUN \
    cd /tmp/cpy39-dbg/build && \
    CC=gcc-10 CXX=g++-10 CFLAGS="-Og -g -ggdb3" .././configure \
      --without-pymalloc \
      --with-valgrind \
      --with-pydebug \
      --verbose \
      --prefix=/opt/cpython-3.9-dbg \
      --enable-loadable-sqlite-extensions \
      --enable-shared \
      --with-ensurepip=yes \
      LDFLAGS="-Wl,-rpath=/opt/cpython-3.9-dbg/lib" \
      && \
    make install && \
    /opt/cpython-3.9-dbg/bin/python3 -c "import sqlite3, uuid, lzma, bz2" && \
    /opt/cpython-3.9-dbg/bin/python3 -m pip install --upgrade --upgrade-strategy=eager pip && \
    /opt/cpython-3.9-dbg/bin/python3 -m pip install --use-feature=2020-resolver cython pytest && \
    /opt/cpython-3.9-dbg/bin/python3 -m pip install --use-feature=2020-resolver numpy && \
    /opt/cpython-3.9-dbg/bin/python3 -m pip install --use-feature=2020-resolver scipy && \
    cd /tmp; rm -rf /tmp/* /var/tmp/* ~/.cache/pip

RUN \
    apt-get update && apt-get dist-upgrade -y && \
    apt-get --quiet --assume-yes --no-install-recommends install libmagick++-dev libgif-dev libgnutls28-dev libacl1-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
    cd /tmp && \
        git clone --depth 1 --branch emacs-27 git://github.com/emacs-mirror/emacs && cd emacs && ./autogen.sh && \
        CC=gcc-10 CXX=g++-10 ./configure --with-imagemagick --with-modules --prefix=/opt/emacs-27 && \
        make && make install && cd /tmp && rm -r emacs

RUN cd /tmp && \
    git clone --depth=1 --recursive https://github.com/MaskRay/ccls && cd ccls && \
    CC=gcc-10 CXX=g++-10 cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH=$(llvm-config-10 --prefix) \
        -DLLVM_INCLUDE_DIR=$(llvm-config-10 --includedir) \
        -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10/ && \
    cmake --build Release && \
    cmake --build Release --target install && \
    cd /tmp && rm -r *

RUN \
    cd /tmp/ && \
    git clone --depth=1 https://github.com/tsl0922/ttyd.git && \
        cd ttyd && mkdir build && cd build && \
        CC=gcc-10 CXX=g++-10 cmake .. && \
        make && make install && \
    cd /tmp && rm -r ttyd





# COPY scripts/get_sundials-5.3.0.sh /opt/
# RUN \
#     CC=clang-10 CFLAGS="-fsanitize=memory -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -fno-optimize-sibling-calls -O1" /opt/get_sundials-5.3.0.sh 5.3.0 /opt/sundials-5.3.0-msan -DLAPACK_ENABLE=OFF -DKLU_ENABLE=OFF -DSUNDIALS_INDEX_SIZE=32 && \
#     CC=gcc-10 /opt/get_sundials-5.3.0.sh 5.3.0 /opt/sundials-5.3.0-klu-lapack -DLAPACK_ENABLE=ON -DKLU_ENABLE=ON -DKLU_INCLUDE_DIR=/usr/include/suitesparse -DKLU_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu -DSUNDIALS_INDEX_SIZE=32 && \
#     CC=gcc-10 /opt/get_sundials-5.3.0.sh 5.3.0 /opt/sundials-5.3.0-noklu-nolapack-extended-int64 -DLAPACK_ENABLE=OFF -DKLU_ENABLE=OFF -DSUNDIALS_PRECISION:STRING="extended" -DSUNDIALS_INDEX_SIZE=64 && \
#     CC=gcc-10 /opt/get_sundials-5.3.0.sh 5.3.0 /opt/sundials-5.3.0-noklu-nolapack-single-int32 -DLAPACK_ENABLE=OFF -DKLU_ENABLE=OFF -DSUNDIALS_PRECISION:STRING="single" -DSUNDIALS_INDEX_SIZE=32

# RUN \
#     apt-get update && apt-get dist-upgrade -y && \
#     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   

# RUN \
#     curl -LOs https://github.com/python/cpython/archive/v3.8.2.tar.gz && \
#     tar xzf v3.8.2.tar.gz && \
#     cd cpython-3.8.2 && \
#     CC=gcc-10 CFLAGS="-O2" ./configure --prefix=/opt/cpython-3.8 --enable-loadable-sqlite-extensions --enable-shared --with-ensurepip=yes LDFLAGS=-Wl,-rpath=/opt/cpython-3.8/lib && \
#     make -j 4 && \
#     LD_LIBRARY_PATH=. ./python -c "import sqlite3, uuid, lzma, bz2" && make install && \
#     cd .. && rm -r cpython-3.8.2 && /opt/cpython-3.8/bin/python3 -m pip install --upgrade --upgrade-strategy=eager pip && \
#     /opt/cpython-3.8/bin/python3 -m pip install setuptools wheel appdirs pybind11 numpy cython scipy matplotlib pycparser pytest-pep8 pytest-cov pytest-flakes pytest-flake8 pytest-xdist pytest-docstyle && \
#     rm v3.8.2.tar.gz


# RUN \
#     cd /tmp && \
#     curl -LOs "https://bitbucket.org/pypy/pypy/downloads/pypy3.6-v7.3.0-linux64.tar.bz2" && \
#     tar xjf pypy3.6*.tar.bz2 -C /opt && rm pypy3.6*.tar.bz2 && \
#     /opt/pypy3.6-*/bin/pypy3 -m ensurepip && \
#     /opt/pypy3.6-*/bin/pypy3 -m pip install --upgrade --upgrade-strategy=eager pip && \
#     /opt/pypy3.6-*/bin/pypy3 -m pip install numpy pytest sympy && \
#     rm -rf /tmp/* /var/tmp/* ~/.cache/pip


# tar xzf v3.8.2.tar.gz && \
# cd cpython-3.8.2 && \
# CC=clang-10 CFLAGS="-Og" ./configure --prefix=/opt/cpython-3.8m-msan --enable-loadable-sqlite-extensions --with-memory-sanitizer --enable-shared --with-ensurepip=yes LDFLAGS=-Wl,-rpath=/opt/cpython-3.8-msan/lib && \
    


# RUN \
#     PATH=/opt/julia-1.4.0/bin:$PATH python3 -m pip install diffeqpy numba && \
#     PATH=/opt/julia-1.4.0/bin:$PATH python3 -c 'import diffeqpy; diffeqpy.install()' && \
#     PATH=/opt/julia-1.4.0/bin:$PATH python3 -m pytest --pyargs diffeqpy && \
#     rm -rf /tmp/* /var/tmp/* ~/.cache/pip

# RUN \
#     apt-get update && \
#     apt-get --quiet --assume-yes --no-install-recommends install inkscape ninja-build && \
#     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# RUN \
#     curl -Ls "https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.0-linux-x86_64.tar.gz" | tar xz -C /opt && \
#     PATH=/opt/julia-1.5.0/bin:$PATH julia -e 'using Pkg; \
#       Pkg.add("DifferentialEquations"); using DifferentialEquations; \
#       pkg"add https://github.com/JuliaDiffEq/DiffEqTutorials.jl"; using DiffEqTutorials; \
#       Pkg.add("IJulia"); using IJulia; \
#       Pkg.add("PyPlot"); using PyPlot; \
#       Pkg.add("Latexify"); using Latexify; \
#       Pkg.add("DiffEqBiological"); using DiffEqBiological; \
#       Pkg.add("ODEInterfaceDiffEq"); using ODEInterfaceDiffEq;' && \
#     cd /opt && git clone https://github.com/JuliaDiffEq/DiffEqTutorials.jl && \
#     PATH=/opt/julia-1.5.0/bin:$PATH julia -e 'using Pkg, DiffEqTutorials; \
#       cd(joinpath(dirname(pathof(DiffEqTutorials)), "..")); \
#       Pkg.pkg"activate ."; \
#       Pkg.pkg"instantiate"; \
#       DiffEqTutorials.weave_folder("introduction"); \
#       DiffEqTutorials.weave_folder("models"); \
#       DiffEqTutorials.weave_folder("ode_extras"); \
#       DiffEqTutorials.weave_folder("type_handling"); \
#       '

# ~/.julia/conda/3/bin/pip install jupyter_contrib_nbextensions && \
# PATH=/opt/julia-1.5.0/bin:$PATH julia -e 'using Pkg; \
#   Pkg.add("WebIO"); using WebIO; \
#   Pkg.add("ORCA"); using ORCA; \
#   Pkg.add("PloylyJS"); using PlotlyJS; \

#RUN \
#    cd /tmp && curl -LOs http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-repo-ubuntu2004_10.1.168-1_amd64.deb && \
#    dpkg -i cuda-repo-ubuntu2004_10.1.168-1_amd64.deb && \
#    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub && \
#    apt-get update && \
#    apt-get --quiet --assume-yes --no-install-recommends install cuda && \
#    rm -r /tmp/*

# RUN curl -Ls https://github.com/catchorg/Catch2/releases/download/v2.9.2/catch.hpp -o /opt/catch2-2.9.2/include/catch.hpp --create-dirs && \
#     curl -Ls https://github.com/catchorg/Clara/releases/download/v1.1.5/clara.hpp -o /opt/clara-1.1.5/include/clara.hpp --create-dirs && \
#     curl -Ls https://github.com/nlohmann/json/releases/download/v3.7.0/json.hpp -o /opt/nlohmann_json-3.7.0/include/json.hpp --create-dirs && \
#     cd /tmp && curl -Ls https://github.com/USCiLab/cereal/archive/v1.2.2.tar.gz | tar xz -C /opt/ && \
#     cd /tmp && curl -Ls https://github.com/msgpack/msgpack-c/releases/download/cpp-3.2.0/msgpack-3.2.0.tar.gz | tar xz && cd msgpack-* && mkdir build && cd build/ && \
#     cmake -DCMAKE_INSTALL_PREFIX:PATH="/opt/msgpack-3.2.0" .. && make install && \
#     cd /tmp && curl -Ls https://github.com/abseil/abseil-cpp/archive/20190808.tar.gz | tar xz && cd abseil-cpp-20190808 && mkdir build && cd build/ && \
#     cmake -DCMAKE_INSTALL_PREFIX:PATH="/opt/abseil-cpp-20190808" .. && make install && \
#     cd /tmp && curl -Ls http://bitbucket.org/eigen/eigen/get/3.3.7.tar.bz2 | tar xj && cd eigen-* && mkdir build && cd build/ && \
#     cmake -DCMAKE_INSTALL_PREFIX:PATH="/opt/eigen-3.3.7" .. && make install && \
# curl -Ls https://github.com/danmar/cppcheck/archive/1.90.tar.gz | tar xz -C /tmp/build-cppcheck
