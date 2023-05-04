#!/bin/bash

rclone copy -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2,jpg,txt}" /home/runner/work/DrivesDown/DrivesDown/aliyundrive/来自分享/ONEPIECE anime:/ONEPIECE