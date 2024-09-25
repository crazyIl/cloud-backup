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

// 按创建时间排序文件，最新的文件排在前面
usort($files, function ($a, $b) {
    return filemtime($b) - filemtime($a);
});

// 获取最新的10个文件
$latestFiles = array_slice($files, 0, 10);

// 输出文件名，用换行分隔
foreach ($latestFiles as $file) {
    echo basename($file) . "\n";
}
