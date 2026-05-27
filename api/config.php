<?php
session_start();

header('Content-Type: application/json; charset=utf-8');
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if ($origin !== '') {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Access-Control-Allow-Credentials: true');
}
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$dbHost = '127.0.0.1';
$dbUser = 'root';
$dbPass = '';
$dbName = 'exam_seating_db';

if (is_file(__DIR__ . '/config.local.php')) {
    require __DIR__ . '/config.local.php';
}

$dbHost = getenv('DB_HOST') ?: $dbHost;
$dbUser = getenv('DB_USER') ?: $dbUser;
$dbPass = getenv('DB_PASS') ?: $dbPass;
$dbName = getenv('DB_NAME') ?: $dbName;

$mysqli = @new mysqli($dbHost, $dbUser, $dbPass, $dbName);
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection failed. Start MySQL and import schema.sql.']);
    exit;
}
$mysqli->set_charset('utf8mb4');

function json_ok($data = [])
{
    echo json_encode(array_merge(['ok' => true], $data));
    exit;
}

function json_error($message, $code = 400)
{
    http_response_code($code);
    echo json_encode(['ok' => false, 'error' => $message]);
    exit;
}

function read_json_body()
{
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        return [];
    }
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function require_auth()
{
    if (empty($_SESSION['user_id'])) {
        json_error('Unauthorized. Please login.', 401);
    }
}

function validate_name($value, $field = 'Name')
{
    $value = trim($value);
    if ($value === '' || !preg_match('/^[A-Za-z][A-Za-z\s\.\-\']{1,99}$/u', $value)) {
        json_error("$field must contain only letters and spaces (2-100 characters).");
    }
    return $value;
}

function validate_code($value, $field = 'Code')
{
    $value = trim($value);
    if ($value === '' || !preg_match('/^[A-Za-z0-9][A-Za-z0-9\s\-]{1,49}$/', $value)) {
        json_error("$field contains invalid characters.");
    }
    return $value;
}

function validate_roll($roll)
{
    $roll = (int)$roll;
    if ($roll < 1000 || $roll > 999999) {
        json_error('Roll number must be a valid positive number (1000-999999).');
    }
    return $roll;
}

function validate_semester($sem)
{
    $sem = (int)$sem;
    if ($sem < 1 || $sem > 8) {
        json_error('Semester must be between 1 and 8.');
    }
    return $sem;
}
