<?php
include_once 'common.php';

// 允许的压缩文件格式
$allowedExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];


// 检查是否有文件上传，并且 POST 请求必须包含 webSiteKey 和 userKey
if ($_SERVER['REQUEST_METHOD'] != 'POST' || !isset($_FILES['file']) || !isset($_POST['webSiteKey']) || !isset($_POST['userKey'])) {
    echo '无效的请求，请确认填写了 webSiteKey 和 userKey，并上传了文件。';
    return;
}

// 获取用户输入的 webSiteKey 和 userKey
$webSiteKey = $_POST['webSiteKey'];
$userKey = $_POST['userKey'];

// 验证 webSiteKey 是否正确
if ($webSiteKey !== WEBSITE_KEY) {
    echo '无效的 webSiteKey，上传失败。';
    return;
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

// 获取上传文件的信息
$fileTmpPath = $_FILES['file']['tmp_name'];
$fileOriginalName = $_FILES['file']['name'];
$fileExtension = pathinfo($fileOriginalName, PATHINFO_EXTENSION);

// 校验文件后缀是否为允许的压缩包格式
if (!in_array(strtolower($fileExtension), $allowedExtensions)) {
    echo '无效的文件类型，仅允许上传压缩文件：' . implode(', ', $allowedExtensions);
    return;
}

// 创建 backup 文件夹
$backupDir = 'backup' . DIRECTORY_SEPARATOR . $userKey;
if (!is_dir($backupDir)) {
    mkdir($backupDir, 0777, true);
}

// 生成新的文件名，格式为： 年月日时分秒.压缩包扩展名
$newFileName = date('Y_m_d_H_i_s') . '.' . $fileExtension;

// 目标路径
$destinationPath = $backupDir . DIRECTORY_SEPARATOR . $newFileName;

// 移动文件到 userKey 文件夹下的 backup 目录
if (move_uploaded_file($fileTmpPath, $destinationPath)) {
    echo '文件上传成功！文件名为：' . $newFileName;
} else {
    echo '文件上传失败，请重试。';
}