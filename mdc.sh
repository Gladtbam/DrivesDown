#!/bin/bash
# i=movie
 i=6
 rclone copy video:/torrent/$i/ .
 aria2c -x 64 --bt-remove-unselected-file=true --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --max-concurrent-downloads=10 *.torrent
 ./Movie_Data_Capture
 rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2,jpg,txt}" /home/runner/work/DrivesDown/DrivesDown/download/JAV_output video:/AV/
# rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2,jpg,txt}" /home/runner/work/DrivesDown/DrivesDown/download/ video:/未刮削/
 rm -rf `ls | egrep -v '(Movie_Data_Capture|config.ini|*.sh)'`
 rclone delete video:/torrent/$i/
 rclone rmdir video:/torrent/$i/
