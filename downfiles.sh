#rclone copy onedrive:/软件/cadence/Linux虚拟机/EDA.part01.rar $GITHUB_WORKSPACE/download
#wget -P $GITHUB_WORKSPACE/download http://www-static.cc.gatech.edu/data_files/large_models/bunny.ply.g
#cp ../*.torrent .
#aria2c -x 64 --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --select-file=1-5 *.torrent

#rclone copy -v anime:/电影/ video:/未刮削/

rclone copy video:/torrent/ .
aria2c *.torrent
rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ video:/未刮削/
