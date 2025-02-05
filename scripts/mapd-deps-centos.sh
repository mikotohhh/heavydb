#!/bin/bash

set -e
set -x

# Parse inputs
TSAN=false
COMPRESS=false
SAVE_SPACE=false
CACHE=

while (( $# )); do
  case "$1" in
    --compress)
      COMPRESS=true
      ;;
    --savespace)
      SAVE_SPACE=true
      ;;
    --tsan)
      TSAN=true
      ;;
    --cache=*)
      CACHE="${1#*=}"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [[ -n $CACHE && ( ! -d $CACHE  ||  ! -w $CACHE )  ]]; then
  # To prevent possible mistakes CACHE must be a writable directory
  echo "Invalid cache argument [$CACHE] supplied. Ignoring."
  CACHE=
fi

if [[ ! -x  "$(command -v sudo)" ]] ; then
  if [ "$EUID" -eq 0 ] ; then
    yum install -y sudo  
  else
    echo "ERROR - sudo not installed and not running as root"
    exit
  fi
fi

SUFFIX=${SUFFIX:=$(date +%Y%m%d)}
PREFIX=${MAPD_PATH:="/usr/local/mapd-deps/$SUFFIX"}

if [ ! -w $(dirname $PREFIX) ] ; then
    SUDO=sudo
fi
$SUDO mkdir -p $PREFIX
$SUDO chown -R $(id -u) $PREFIX
export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib64:$PREFIX/lib:$LD_LIBRARY_PATH

# Needed to find xmltooling and xml_security_c
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig:$PKG_CONFIG_PATH

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPTS_DIR/common-functions.sh

sudo yum groupinstall -y "Development Tools"
sudo yum install -y \
    ca-certificates \
    zlib-devel \
    epel-release \
    which \
    libssh \
    openssl-devel \
    ncurses-devel \
    git \
    java-1.8.0-openjdk-devel \
    java-1.8.0-openjdk-headless \
    gperftools \
    gperftools-devel \
    gperftools-libs \
    python-devel \
    wget \
    curl \
    python3 \
    openldap-devel \
    patchelf
sudo yum install -y \
    jq \
    pxz

generate_deps_version_file
# mold fast linker
install_mold_precompiled_x86_64

# gmp, mpc, mpfr, autoconf, automake
# note: if gmp fails on POWER8:
# wget https://gmplib.org/repo/gmp/raw-rev/4a6d258b467f
# patch -p1 < 4a6d258b467f
# https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz
download_make_install ${HTTP_DEPS}/gmp-6.1.2.tar.xz "" "--enable-fat"

# http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.xz
download_make_install ${HTTP_DEPS}/mpfr-4.0.1.tar.xz "" "--with-gmp=$PREFIX"
download_make_install ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz "" "--with-gmp=$PREFIX"
download_make_install ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz # "" "--build=powerpc64le-unknown-linux-gnu"  
download_make_install ftp://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz 

install_centos_gcc

export CC=$PREFIX/bin/gcc
export CXX=$PREFIX/bin/g++

install_ninja

install_maven

install_cmake

install_boost

download_make_install ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz


# http://zlib.net/zlib-1.2.8.tar.xz
download_make_install ${HTTP_DEPS}/zlib-1.2.8.tar.xz

install_memkind

install_bzip2

# https://www.openssl.org/source/openssl-1.0.2u.tar.gz
download_make_install ${HTTP_DEPS}/openssl-1.0.2u.tar.gz "" "linux-$(uname -m) no-shared no-dso -fPIC"

# libarchive
CFLAGS="-fPIC" download_make_install ${HTTP_DEPS}/xz-5.2.4.tar.xz "" "--disable-shared --with-pic"
CFLAGS="-fPIC" download_make_install ${HTTP_DEPS}/libarchive-3.3.2.tar.gz "" "--without-openssl --disable-shared" 

CFLAGS="-fPIC" download_make_install ftp://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz # "" "--build=powerpc64le-unknown-linux-gnu" 

download_make_install ftp://ftp.gnu.org/gnu/bison/bison-3.4.2.tar.xz # "" "--build=powerpc64le-unknown-linux-gnu" 

# https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flexpp-bisonpp/bisonpp-1.21-45.tar.gz
download_make_install ${HTTP_DEPS}/bisonpp-1.21-45.tar.gz bison++-1.21

CFLAGS="-fPIC" download_make_install ftp://ftp.gnu.org/gnu/readline/readline-7.0.tar.gz

install_double_conversion

install_archive

VERS=0.3.5
CXXFLAGS="-fPIC -std=c++11" download_make_install https://github.com/google/glog/archive/v$VERS.tar.gz glog-$VERS "--enable-shared=no" # --build=powerpc64le-unknown-linux-gnu"

# Libevent needed for folly
VERS=2.1.10
download_make_install https://github.com/libevent/libevent/releases/download/release-$VERS-stable/libevent-$VERS-stable.tar.gz

install_folly

# llvm
# http://thrysoee.dk/editline/libedit-20170329-3.1.tar.gz
download_make_install ${HTTP_DEPS}/libedit-20170329-3.1.tar.gz

# (see common-functions.sh)
install_llvm 

install_iwyu 

VERS=7.75.0
# https://curl.haxx.se/download/curl-$VERS.tar.xz
download_make_install ${HTTP_DEPS}/curl-$VERS.tar.xz "" "--disable-ldap --disable-ldaps"

# thrift
install_thrift

# librdkafka
install_rdkafka static

# backend rendering
VERS=1.6.21
# http://download.sourceforge.net/libpng/libpng-$VERS.tar.xz
download_make_install ${HTTP_DEPS}/libpng-$VERS.tar.xz

install_snappy
 
VERS=3.52.16
CFLAGS="-fPIC" CXXFLAGS="-fPIC" download_make_install ${HTTP_DEPS}/libiodbc-${VERS}.tar.gz

# c-blosc
install_blosc

# Geo Support
install_gdal
install_geos
install_pdal


download_make_install https://mirrors.sarata.com/gnu/binutils/binutils-2.32.tar.xz

# TBB
install_tbb static

# OneDAL
install_onedal

# Go
install_go

# install AWS core and s3 sdk
install_awscpp -j $(nproc)

# Apache Arrow (see common-functions.sh)
install_arrow

# glslang (with spirv-tools)
VERS=11.6.0 # stable 8/25/21
rm -rf glslang
mkdir -p glslang
pushd glslang
wget --continue https://github.com/KhronosGroup/glslang/archive/$VERS.tar.gz
tar xvf $VERS.tar.gz
pushd glslang-$VERS
./update_glslang_sources.py
mkdir build
pushd build
cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    ..
make -j $(nproc)
make install
popd # build
popd # glslang-$VERS
popd # glslang

# spirv-cross
VERS=2020-06-29 # latest from 6/29/20
rm -rf spirv-cross
mkdir -p spirv-cross
pushd spirv-cross
wget --continue https://github.com/KhronosGroup/SPIRV-Cross/archive/$VERS.tar.gz
tar xvf $VERS.tar.gz
pushd SPIRV-Cross-$VERS
mkdir build
pushd build
cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_POSITION_INDEPENDENT_CODE=on \
    -DSPIRV_CROSS_ENABLE_TESTS=off \
    ..
make -j $(nproc)
make install
popd # build
popd # SPIRV-Cross-$VERS
popd # spirv-cross

# Vulkan
install_vulkan

# GLM (GL Mathematics)
install_glm

# install opensaml and its dependencies
VERS=3.2.2
download ${HTTP_DEPS}/xerces-c-$VERS.tar.gz
extract xerces-c-$VERS.tar.gz
XERCESCROOT=$PWD/xerces-c-$VERS
mkdir $XERCESCROOT/build
pushd $XERCESCROOT/build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=off -Dnetwork=off -DCMAKE_BUILD_TYPE=release ..
makej
make install
popd

download_make_install ${HTTP_DEPS}/xml-security-c-2.0.2.tar.gz "" "--without-xalan --enable-static --disable-shared"
download_make_install ${HTTP_DEPS}/xmltooling-3.0.4-nolog4shib.tar.gz "" "--enable-static --disable-shared"
CXXFLAGS="-std=c++14" download_make_install ${HTTP_DEPS}/opensaml-3.0.1-nolog4shib.tar.gz "" "--enable-static --disable-shared"

sed -e "s|%MAPD_DEPS_ROOT%|$PREFIX|g" mapd-deps.modulefile.in > mapd-deps-$SUFFIX.modulefile
sed -e "s|%MAPD_DEPS_ROOT%|$PREFIX|g" mapd-deps.sh.in > mapd-deps-$SUFFIX.sh

cp mapd-deps-$SUFFIX.sh mapd-deps-$SUFFIX.modulefile $PREFIX

if [ "$COMPRESS" = "true" ] ; then
    if [ "$TSAN" = "false" ]; then
      TARBALL_TSAN=""
    elif [ "$TSAN" = "true" ]; then
      TARBALL_TSAN="tsan-"
    fi
    tar -cvf mapd-deps-${TARBALL_TSAN}${SUFFIX}.tar -C $(dirname $PREFIX) $SUFFIX
    pxz mapd-deps-${TARBALL_TSAN}${SUFFIX}.tar
fi
