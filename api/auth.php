<?php
require __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

if ($method === 'GET' && $action === 'check') {
    if (!empty($_SESSION['user_id'])) {
        json_ok(['authenticated' => true, 'username' => $_SESSION['username'] ?? 'admin']);
    }
    json_ok(['authenticated' => false]);
}

if ($method === 'POST' && $action === 'logout') {
    session_destroy();
    json_ok(['message' => 'Logged out.']);
}

if ($method === 'POST') {
    $body = read_json_body();
    $username = trim($body['username'] ?? '');
    $password = $body['password'] ?? '';

    if ($username === '' || $password === '') {
        json_error('Username and password are required.');
    }

    $count = $mysqli->query('SELECT COUNT(*) AS c FROM users')->fetch_assoc()['c'];
    if ((int)$count === 0) {
        $hash = password_hash('admin123', PASSWORD_DEFAULT);
        $stmt = $mysqli->prepare('INSERT INTO users (username, password_hash) VALUES (?, ?)');
        $defaultUser = 'admin';
        $stmt->bind_param('ss', $defaultUser, $hash);
        $stmt->execute();
    }

    $stmt = $mysqli->prepare('SELECT id, username, password_hash FROM users WHERE username = ?');
    $stmt->bind_param('s', $username);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        json_error('Invalid username or password.', 401);
    }

    $_SESSION['user_id'] = (int)$user['id'];
    $_SESSION['username'] = $user['username'];
    json_ok(['message' => 'Login successful.', 'username' => $user['username']]);
}

json_error('Method not allowed.', 405);
