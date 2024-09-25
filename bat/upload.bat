@echo off
chcp 65001 >nul
setlocal

:: 读取配置文件
call :readConfig "config.ini"

:: 检查并设置文件夹路径
call :setFolderPath %1
echo 使用的文件夹路径: %folderPath%

:: 如果folderPath后缀文件是 7z 直接上传
if "%folderPath:~-3%"==".7z" (
    echo 检测到文件后缀为 7z，直接上传文件
    call :uploadFile %folderPath%
    pause
    exit /b
)

:: 获取当前时间戳
call :getWriteZipFileName
echo 写到文件: %writeFileName%

:: 压缩文件
call :compressFolder %folderPath% %writeFileName%
if %errorlevel% neq 0 (
    echo 压缩失败
    pause
    exit /b
)

:: 上传文件
call :uploadFile %writeFileName%

pause
exit /b

:: ----------------------------------------------------------------------------
:: 函数定义部分
:: ----------------------------------------------------------------------------

:: 设置文件夹路径

:setFolderPath
if "%~1"=="" (
    set "folderPath=%defaultFolder%"
) else (
    set "folderPath=%~1"
)
exit /b

:: 获取当前时间戳 (格式为 YYYY_MM_DD_HH_MM_SS)
:getWriteZipFileName
for /f "tokens=2 delims==." %%i in ('wmic os get localdatetime /value') do set datetime=%%i
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%
set timeStamp=%year%_%month%_%day%_%hour%_%minute%_%second%
set writeFileName="%timeStamp%.7z"
exit /b

:: 压缩文件夹到7z
:: 参数1：要压缩的文件夹路径
:: 参数2：时间戳，用于生成压缩文件名
:compressFolder
set "zipFile=%writeFileName%"
"%zipPath%" a -t7z "%zipFile%" "%~1\*" -mx9
if not exist "%zipFile%" (
    exit /b 1
)
echo 压缩成功，文件名为：%zipFile%
exit /b

:: 上传文件到服务器
:: 参数1：时间戳，用于生成压缩文件名
:uploadFile
echo 正在上传文件...
set "zipFile=%~1"
curl -F "file=@%zipFile%" -F "webSiteKey=%webSiteKey%" -F "userKey=%userKey%" %uploadUrl%
echo.
exit /b %errorlevel%


:: 读取配置文件
:readConfig
set "configFile=%~1"
for /f "tokens=1,2 delims==" %%A in (%configFile%) do (
    set "%%A=%%B"
)
exit /b
