<?php
include_once 'common.php';

// 检查是否提供了webSiteKey和userKey
if (!isset($_GET['webSiteKey']) || !isset($_GET['userKey'])) {
    echo "缺少 webSiteKey 或 userKey。";
    exit;
}

// 获取用户提交的 webSiteKey 和 userKey
$webSiteKey = $_GET['webSiteKey'];
$userKey = $_GET['userKey'];

// 验证 webSiteKey 是否正确
if ($webSiteKey !== WEBSITE_KEY) {
    echo "无效的 webSiteKey。";
    exit;
}

// 校验 userKey 是否为空
if (empty($userKey)) {
    echo 'userKey 不能为空。';
    return;
}

// 使用正则表达式校验 userKey 只能包含 a-zA-Z0-9-_ 
if (!preg_match('/^[a-zA-Z0-9_-]+$/', $userKey)) {
    echo '无效的 userKey，userKey 只能包含字母、数字、下划线和连字符。';
    return;
}

// 定义用户对应的文件夹路径
$folder = 'backup' . DIRECTORY_SEPARATOR . $userKey;

// 检查文件夹是否存在
if (!is_dir($folder)) {
    echo "用户文件夹不存在。";
    exit;
}

// 获取文件夹中的所有文件
$files = glob($folder . '/*');

// 检查是否有文件
if ($files === false || count($files) === 0) {
    echo "文件夹为空或不存在文件。";
    exit;
}

// 按创建时间排序文件，最新的文件排在最后
usort($files, function ($a, $b) {
    return filemtime($a) - filemtime($b);
});

// 获取最后一个文件（最新的文件）
$latestFile = end($files);

// 检查文件是否存在并可读
if (file_exists($latestFile) && is_readable($latestFile)) {
    // 获取文件的basename(文件名)
    $fileName = basename($latestFile);
    
    // 设置下载头
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $fileName . '"');
    header('Content-Length: ' . filesize($latestFile));
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Expires: 0');

    // 读取文件并输出
    readfile($latestFile);
    exit;
} else {
    echo "无法读取文件: " . $latestFile;
    exit;
}
