# 使用方法

1. 在Windows或者Linux平台安装Rclone，执行`rclone config`创建相应的rclone.conf  
![rclone.conf](https://github.com/Gladtbam/Image_Oneself/raw/main/DrivesDown/rclone_conf.png)

2. 上传rclone.conf

1. 点击存储库上方的Settings &rarr; Secrets &rarr; New secret,如图：
![secrets](https://github.com/Gladtbam/Image_Oneself/raw/main/DrivesDown/secrets.png)

2. 创建secrets

    在Name填入`RCLONE_CONF`，复制整个rclone.conf填入Value(所有引号前都需要添加 `\` 转义)，创建密钥   

3. 下载文件

- 方法1、 使用SSH，利用SSH远程输入命令调用rclone，[SSH使用方法参考](https://github.com/Gladtbam/OpenWRT_Action#ssh%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)  
    需修改drivedown.yml中`SSH_ACTIONS: false`为`true`

- 方法2、 修改files.sh,将调用rclone命令输入files.sh中，运行过程执行脚本调用  
    ***注意***：调用rclone下载的下载路径请务必设置为$GITHUB_WORKSPACE/download，如果想要修改未其它路径，请同步修改`drivedown.yml`第44行的路径

4. 取回文件

    使用奶牛快传取回文件，奶牛快传链接在Actions日志中

