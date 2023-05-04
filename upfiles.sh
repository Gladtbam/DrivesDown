#!/bin/bash

wget https://nyaa.si/download/1652523.torrent
aria2c --seed-time=120 *.torrent 
rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ anime:/未刮削/
rm -rf *.torrent


#wget https://nyaa.si/download/1509305.torrent
#for ((i=1, j=200; i<=1372; i=i+200, j=j+200))
#do
#aria2c -x 64 --bt-remove-unselected-file=true --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --select-file=$i-$j *.torrent
#echo "$i-$j 开始上传"
#rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ anime:/未刮削/
#echo "$i-$j 上传完成"
#done

#bash /home/runner/.aria2/upload.sh
#rclone copy video:/torrent/ .
#aria2c *.torrent
#rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ auto:/软件/MATLAB/
#rclone delete video:/torrent/
