<?php
require __DIR__ . '/config.php';
require_auth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $rows = [];
    $result = $mysqli->query(
        'SELECT s.roll_no, s.name, s.department, s.subject, s.semester, s.shift_id,
                s.default_hall, sh.shift_name
         FROM students s
         LEFT JOIN shifts sh ON sh.shift_id = s.shift_id
         ORDER BY s.roll_no ASC'
    );
    if (!$result) {
        json_error($mysqli->error, 500);
    }
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    json_ok(['students' => $rows]);
}

if ($method === 'POST') {
    $body = read_json_body();
    $roll = validate_roll($body['roll_no'] ?? 0);
    $name = validate_name($body['name'] ?? '', 'Student name');
    $department = validate_code($body['department'] ?? '', 'Department');
    $subject = validate_code($body['subject'] ?? '', 'Subject');
    $semester = validate_semester($body['semester'] ?? 0);
    $shiftId = isset($body['shift_id']) && $body['shift_id'] !== ''
        ? (int)$body['shift_id'] : 1;
    $defaultHall = isset($body['default_hall']) && trim($body['default_hall']) !== ''
        ? validate_code($body['default_hall'], 'Hall')
        : 'Hall A';

    $stmt = $mysqli->prepare(
        'INSERT INTO students (roll_no, name, department, subject, semester, shift_id, default_hall)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $stmt->bind_param('isssiis', $roll, $name, $department, $subject, $semester, $shiftId, $defaultHall);
    if (!$stmt->execute()) {
        if ($mysqli->errno === 1062) {
            json_error('Duplicate roll number. Student already exists.');
        }
        json_error($stmt->error, 500);
    }
    json_ok(['message' => 'Student added successfully.']);
}

if ($method === 'DELETE') {
    $roll = validate_roll($_GET['roll_no'] ?? 0);
    $stmt = $mysqli->prepare('DELETE FROM students WHERE roll_no = ?');
    $stmt->bind_param('i', $roll);
    $stmt->execute();
    if ($stmt->affected_rows === 0) {
        json_error('Student not found.', 404);
    }
    json_ok(['message' => 'Student deleted.']);
}

json_error('Method not allowed.', 405);
