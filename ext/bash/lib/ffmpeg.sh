#!/usr/bin/env bash
# http://askubuntu.com/a/148567
# https://trac.ffmpeg.org/wiki/UbuntuCompilationGuide
# http://juliensimon.blogspot.ca/2013/08/howto-compiling-ffmpeg-x264-mp3-aac.html

export FFMPEG_VERSION="git" # @specify (or a version to download: "2.1.4")
export FFMPEG_YASM_VERSION="1.2.0"
export FFMPEG_XVID_VERSION="1.3.2"

function get-ffmpeg-url {
  echo "http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz"
}

function get-ffmpeg-yasm-url {
  echo "http://www.tortall.net/projects/yasm/releases/yasm-$FFMPEG_YASM_VERSION.tar.gz"
}

function get-ffmpeg-xvid-url {
  echo "http://downloads.xvid.org/downloads/xvidcore-$FFMPEG_XVID_VERSION.tar.gz"
}

function ffmpeg-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Install Dependencies"
  install-packages build-essential git libfaac-dev libgpac-dev \
    libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev \
    libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev \
    libvorbis-dev libxfixes-dev zlib1g-dev libgsm1-dev

  announce-item "Yasm"
  announce-item "> Download"
  download $(get-ffmpeg-yasm-url)

  announce-item "> Extract"
  extract yasm-$FFMPEG_YASM_VERSION.tar.gz
  cd yasm-$FFMPEG_YASM_VERSION

  announce-item "> Configure"
  ./configure

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  make distclean
  cd ..

  announce-item "X264"
  announce-item "> Download"
  git clone --depth 1 git://git.videolan.org/x264

  announce-item "> Configure"
  cd x264
  ./configure --prefix=/usr/local --enable-shared

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  make distclean
  cd ..

  announce-item "Xvid"
  announce-item "> Download"
  download $(get-ffmpeg-xvid-url)

  announce-item "> Extract"
  extract xvidcore-$FFMPEG_XVID_VERSION.tar.gz
  cd xvidcore/build/generic

  announce-item "> Configure"
  ./configure --prefix=/usr/local

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  cd ../../..

  announce "Download $FFMPEG_VERSION"
  if [ $FFMPEG_VERSION == "git" ]; then
    git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
    cd ffmpeg
  else
    download $(get-ffmpeg-url)

    announce "Extract"
    extract ffmpeg-$FFMPEG_VERSION.tar.gz
    cd ffmpeg-$FFMPEG_VERSION
  fi

  announce "Configure"
  ./configure --prefix=/usr/local --enable-gpl --enable-version3 \
    --enable-nonfree --enable-shared --enable-libopencore-amrnb \
    --enable-libopencore-amrwb --enable-libfaac --enable-libgsm \
    --enable-libmp3lame --enable-libtheora --enable-libvorbis \
    --enable-libx264 --enable-libxvid

  announce "Compile"
  make

  announce "Install"
  make install
  make distclean
  ldconfig -v

  cd ~/
  rm -rf "$tmpdir"
}
