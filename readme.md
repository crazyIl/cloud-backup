## 服务端部署

1. 将 `php` 目录下的文件复制到站点目录中。
2. 修改 `common.php` 文件中的 `WEBSITE_KEY` 变量，将其设置为你的站点密钥。
3. 配置 Nginx 拒绝访问 `backup` 文件夹（可选，防止文件被直接下载）：

```nginx
location /backup/ {
    deny all;
}
```

## 客户端使用

1. 复制 `config.ini.example` 文件，并将其重命名为 `config.ini`。
2. 修改 `config.ini` 配置文件中的相关参数。

| 字段              | 说明                                    |
|-----------------|---------------------------------------|
| `defaultFolder` | 需要打包上传的目录                             |
| `zipPath`       | 7z.exe 的路径                            |
| `uploadUrl`     | 上传的 URL 地址                            |
| `downloadUrl`   | 下载的 URL 地址                            |
| `webSiteKey`    | 站点密钥，对应 `common.php` 中的 `WEBSITE_KEY` |
| `userKey`       | 用户秘钥：自定义字符串，用于标识用户文件夹                 |

### 脚本说明

#### `upload.bat`

该脚本用于自动压缩并上传存档，支持以下使用方式：

- **双击运行**：自动打包`defaultFolder`目录中的内容并上传。
- **拖拽文件夹**：将指定文件夹拖拽到脚本上，打包并上传该文件夹。
- **拖拽 `.7z` 文件**：将 `.7z` 文件拖拽到脚本上，直接上传该压缩文件。

#### `download-un7z.bat`

该脚本用于下载并解压存档，支持以下使用方式：

- **双击运行**：下载最后一个备份文件并解压到`defaultFolder`目录。
- **拖拽文件夹**：将指定文件夹拖拽到脚本上，下载并解压到该文件夹中。
