<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_URI'] === '/api/health') {
    http_response_code(200);
    echo json_encode(['status' => 'ok']);
    exit;
}

$tests = [];

$tests['php_version'] = PHP_VERSION;

$host     = getenv('MYSQL_HOST');
$user     = getenv('MYSQL_USER');
$password = getenv('MYSQL_PASSWORD');
$db       = getenv('MYSQL_DATABASE');

if ($host && $user && $password && $db) {
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $password);
        $tests['database'] = 'Connected OK';
    } catch (Exception $e) {
        $tests['database'] = 'FAILED: ' . $e->getMessage();
    }
}

echo json_encode($tests, JSON_PRETTY_PRINT);
