#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = srt version

# load functions
. $1/functions.sh


SOFTWARE=srt

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
  git clone --depth 1 https://github.com/Haivision/srt.git
  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # prepare build
  mkdir ../srt_build
  checkStatus $? "create srt build directory failed"
  cd ../srt_build

  checkStatus $? "change directory to srt build failed"

  export OPENSSL_ROOT_DIR="$3"
  export OPENSSL_LIB_DIR="$3"/lib
  export OPENSSL_INCLUDE_DIR="$3"/include/

  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_BINDIR=bin -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DENABLE_APPS=OFF -DUSE_STATIC_LIBSTDCXX=ON ../srt/
  checkStatus $? "configuration of srt failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/srt_build"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"

}

make_compile () {

  cd "$2/${SOFTWARE}/srt_build/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

}

build_main () {


set -x

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@
