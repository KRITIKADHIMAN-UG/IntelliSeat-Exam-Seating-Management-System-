<?php
require __DIR__ . '/config.php';
require_auth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $rows = [];
    $result = $mysqli->query(
        'SELECT shift_id, shift_name, start_time, end_time FROM shifts ORDER BY shift_id ASC'
    );
    if (!$result) {
        json_error($mysqli->error, 500);
    }
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    json_ok(['shifts' => $rows]);
}

if ($method === 'POST') {
    $body = read_json_body();
    $shiftId = (int)($body['shift_id'] ?? 0);
    if ($shiftId <= 0) {
        json_error('Shift ID must be a positive number.');
    }
    $name = validate_name($body['shift_name'] ?? '', 'Shift name');
    $start = trim($body['start_time'] ?? '');
    $end = trim($body['end_time'] ?? '');
    if (!preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $start) || !preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $end)) {
        json_error('Shift times must be in HH:MM format.');
    }

    $stmt = $mysqli->prepare(
        'INSERT INTO shifts (shift_id, shift_name, start_time, end_time) VALUES (?, ?, ?, ?)'
    );
    $stmt->bind_param('isss', $shiftId, $name, $start, $end);
    if (!$stmt->execute()) {
        if ($mysqli->errno === 1062) {
            json_error('Shift ID already exists.');
        }
        json_error($stmt->error, 500);
    }
    json_ok(['message' => 'Shift added successfully.']);
}

json_error('Method not allowed.', 405);
