@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 读取配置文件
call :readConfig "config.ini"

:: 检查并设置文件夹路径
call :setFolderPath %1
echo 使用的文件夹路径: %folder%

:: 下载文件
call :downloadFile
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

:: 下载文件
:downloadFile
echo 正在从接口下载文件...
curl -OJ "%downloadUrl%?webSiteKey=%webSiteKey%&userKey=%userKey%"

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