<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_URI'] === '/api/health') {
    http_response_code(200);
    echo json_encode(['status' => 'ok']);
    exit;
}

$tests = [];

$tests['php_version'] = PHP_VERSION;

$dsn = getenv('DATABASE_URL');
if ($dsn) {
    try {
        $pdo = new PDO($dsn);
        $tests['database'] = 'Connected OK';
    } catch (Exception $e) {
        $tests['database'] = 'FAILED: ' . $e->getMessage();
    }
}

echo json_encode($tests, JSON_PRETTY_PRINT);
