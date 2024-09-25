@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 读取配置文件
call :readConfig "config.ini"

:: 检查并设置文件夹路径
call :setFolderPath %1
echo 使用的文件夹路径: %folder%

:: 获取文件列表
call :getFileList
if %errorlevel% neq 0 (
    echo 获取文件列表失败。
    pause
    exit /b
)

:: 检查文件列表是否为空
if %fileCount% equ 0 (
    echo 文件列表为空，无法继续操作。
    pause
    exit /b
)

:: 让用户选择文件
:selectFileLoop
call :selectFile
if %errorlevel% neq 0 (
    goto :selectFileLoop
)

echo 选择成功: %selectedFile%


:: 下载文件（如果未选择文件名，则不传 fileName）
call :downloadFile %selectedFile%
if %errorlevel% neq 0 (
    echo 文件下载失败。
    pause
    exit /b
)

:: 询问用户是否解压
set /p "confirm=文件已下载完成，是否解压文件 (y/[Enter]继续，其他退出)？"
if not "%confirm%"=="" if /i not "%confirm%"=="y" (
    echo 用户选择不解压文件。
    pause
    exit /b
)

:: 解压文件
call :extractFile %folder%
if %errorlevel% neq 0 (
    echo 文件解压失败，请检查7z文件或7-Zip工具。
    pause
    exit /b
)

:: 打开文件夹
start explorer "%folder%"
pause
exit /b

:: ----------------------------------------------------------------------------
:: 函数定义部分
:: ----------------------------------------------------------------------------

:: 检查并设置文件夹路径

:setFolderPath
if "%~1"=="" (
    set "folder=%defaultFolder%"
) else (
    set "folder=%~1"
)
:: 移除可能的双引号
set "folder=%folder:"=%"
exit /b

:: 获取文件列表
:getFileList
echo 正在从接口获取最近文件列表...
curl -s "%fileListUrl%?webSiteKey=%webSiteKey%&userKey=%userKey%" > cloud-backup-filelist-asdadnasd.txt

if errorlevel 1 (
    echo 获取文件列表失败。
    exit /b 1
)

:: 读取文件列表并保存到数组
set i=0
for /f "tokens=*" %%f in (cloud-backup-filelist-asdadnasd.txt) do (
    set /a i+=1
    set "file[!i!]=%%f"
    echo !i!. %%f
)
set fileCount=%i%
del cloud-backup-filelist-asdadnasd.txt
exit /b

:: 用户选择文件
:selectFile
set "selectedFile="
set /p "selection=请输入要下载的文件编号 (1-%fileCount%)，直接回车选择最新文件："

:: 如果用户没有输入则退出选择，下载最新文件
if "%selection%"=="" (
    echo 用户选择下载最新文件。
    exit /b 0
)

:: 验证输入是否为数字
for /f "delims=0123456789" %%a in ("%selection%") do (
    echo 输入无效，请输入数字。
    exit /b 1
)

:: 验证选择是否在有效范围内
if %selection% lss 1 (
    echo 无效的选择，请输入范围内的编号。
    exit /b 1
)

if %selection% gtr %fileCount% (
    echo 无效的选择，请输入范围内的编号。
    exit /b 1
)

:: 正确读取文件名并传递给外部变量
set "selectedFile=!file[%selection%]!"


:: 验证是否成功读取到文件名
if "%selectedFile%"=="" (
    echo 未能获取到有效的文件名。
    exit /b 1
)

echo 选择的文件: %selectedFile%
exit /b 0

:: 下载文件
:downloadFile
echo 正在从接口下载文件 %~1...
set "fileNameParam="
if not "%~1"=="" (
    set "fileNameParam=&fileName=%~1"
)

curl -OJ "%downloadUrl%?webSiteKey=%webSiteKey%&userKey=%userKey%%fileNameParam%"

if errorlevel 1 (
    echo 下载失败。
    exit /b 1
)

:: 获取最新下载的文件名（按修改时间排序）
for /f "delims=" %%f in ('dir /b /o-d /a-d *.7z') do (
    set "downloaded_file=%%f"
    goto :break
)

:break
echo 下载完成: %downloaded_file%
exit /b

:: 解压文件
:extractFile
:: 检查7-Zip是否存在
if not exist "%zipPath%" (
    echo 7-Zip未找到，请确保7-Zip已安装并且路径正确。
    exit /b 1
)

echo 正在解压文件到: %~1
"%zipPath%" x "%downloaded_file%" -o"%~1" -y
exit /b %errorlevel%

:: 读取配置文件
:readConfig
set "configFile=%~1"
for /f "tokens=1,2 delims==" %%A in (%configFile%) do (
    set "%%A=%%B"
)
exit /b
