## Sample mediamtx+ffmpeg+hls setup

The goal of this repo is to have a simple setup with mediamtx

        SOURCE  -->  MTX  | -->  FFMPEG --> HLS  
                          | -->  SAVE TO FILE (MP4)

Secondary goal was to insert a debug line in ffmpeg where HLS segments are cut.

## Setup

modify `[alt_names]` section in `make-cert` shell script to include
all the DNS names/IPs of the machine you will running this on

run `./setup.sh` to setup and download/build components:
  * make-cert
  * mediamtx 1.8.0 (binary download)
  * webfs-1.21 source download & build (command line http server)
  * git clone ffmpeg & patch & build
  * sample video to use as source
  
## Notes

This repo has a medamtx.yml configuration in it which specifies the
recording to a file, and running the ffmpeg command for HLS (in the
`hls` script) on publisher connect.

## Making it run

Each of the following commands should be done in their own terminal

        ./mediamtx
        ffmpeg/ffmpeg -re -stream_loop -1 -i samples/Technico1949.mp4 -c copy -f rtsp rtsp://localhost:8554/test-stream
        sudo ./webfsd -S -p 443 -F -R $(pwd)/hls_out -u $(id -un) -m $(pwd)/mime.types -C host.keycrt

Alternatively, you can use this command to publish the webcam 
from a macbook to the server:

        ffmpeg -fflags nobuffer -f avfoundation -pix_fmt yuyv422 -video_size 320x240 -framerate 30 -i "0:1" -ac 2 -vf format=yuyv422 -vcodec libx265 -maxrate 2000k -bufsize 2000k -g 2 -acodec aac -ar 44100 -b:a 128k -f rtsp rtsp://<ip-of-mediamtx-server>:8554/test-stream

## Viewing

The HLS stream can be viewed by going to https://hostname/hls.html

You will need to trust the `myCA-root.pem` certificate for this to work.

## Areas of future exploration

 * hls variants
 * "empty" stream when nothing publishing
    * mediamtx supports this it looks like
 * dash
 * hardware-assisted encoding
