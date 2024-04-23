#!/bin/bash

## check that x264/x265 libraries (dev version) installed
if ! dpkg --list | grep -q '^.i  libx264-dev'
then
    echo you need to install libx264-dev, stop.
    exit 1
elif ! dpkg --list | grep '^.i  libx265-dev'
then
    echo you need to install libx265-dev, stop.
    exit 1
fi

## build certs, we can do that first
./make-cert

## download mediamtx
wget https://github.com/bluenviron/mediamtx/releases/download/v1.8.0/mediamtx_v1.8.0_linux_amd64.tar.gz
tar xvfz mediamtx_v1.8.0_linux_amd64.tar.gz mediamtx

## build simple http server
wget https://www.kraxel.org/releases/webfs/webfs-1.21.tar.gz
tar xvfz webfs-1.21.tar.gz
cd webfs-1.21
cat <<EOF >Make.config
LIB          := lib
SYSTEM       := linux
USE_SENDFILE := yes
USE_THREADS  := no
USE_SSL      := yes
USE_DIET     := no
EOF
make
cd ..

## get sample video
mkdir -p samples
cd samples
wget https://archive.org/download/Technico1949/Technico1949.mp4
cd ..

git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
cd ffmpeg
git apply ../ffmpeg-hls-cut.diff
./configure --enable-gpl --enable-libx264 --enable-libx265
make

