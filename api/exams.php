<?php
require __DIR__ . '/config.php';
require_auth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $rows = [];
    $result = $mysqli->query(
        'SELECT exam_id, subject, department, semester, exam_date FROM exams ORDER BY exam_date ASC'
    );
    if (!$result) {
        json_error($mysqli->error, 500);
    }
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    json_ok(['exams' => $rows]);
}

if ($method === 'POST') {
    $body = read_json_body();
    $examId = (int)($body['exam_id'] ?? 0);
    if ($examId <= 0) {
        json_error('Exam ID must be a positive number.');
    }
    $subject = validate_code($body['subject'] ?? '', 'Subject');
    $department = validate_code($body['department'] ?? '', 'Department');
    $semester = validate_semester($body['semester'] ?? 0);
    $date = trim($body['exam_date'] ?? '');
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
        json_error('Exam date must be in YYYY-MM-DD format.');
    }

    $stmt = $mysqli->prepare(
        'INSERT INTO exams (exam_id, subject, department, semester, exam_date) VALUES (?, ?, ?, ?, ?)'
    );
    $stmt->bind_param('issis', $examId, $subject, $department, $semester, $date);
    if (!$stmt->execute()) {
        if ($mysqli->errno === 1062) {
            json_error('Exam ID already exists.');
        }
        json_error($stmt->error, 500);
    }
    json_ok(['message' => 'Exam added successfully.']);
}

json_error('Method not allowed.', 405);
