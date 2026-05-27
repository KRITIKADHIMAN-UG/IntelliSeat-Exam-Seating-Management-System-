<?php
require __DIR__ . '/config.php';
require_auth();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_error('Method not allowed.', 405);
}

$colCheck = $mysqli->query("SHOW COLUMNS FROM students LIKE 'default_hall'");
if ($colCheck && $colCheck->num_rows === 0) {
    $mysqli->query('ALTER TABLE students ADD COLUMN default_hall VARCHAR(50) NULL AFTER shift_id');
}

$count = (int)$mysqli->query('SELECT COUNT(*) AS c FROM students')->fetch_assoc()['c'];

if ($count < 100) {
    require_once __DIR__ . '/seed_students.php';
    exam_seating_seed_students($mysqli);
}

$examCount = (int)$mysqli->query('SELECT COUNT(*) AS c FROM exams')->fetch_assoc()['c'];
if ($examCount === 0) {
    $exams = [
        [1, 'Data Structures', 'CSE', 5, '2026-06-10'],
        [2, 'Database Management Systems', 'CSE', 5, '2026-06-12'],
        [3, 'Operating Systems', 'ECE', 6, '2026-06-15'],
    ];
    $stmt = $mysqli->prepare(
        'INSERT IGNORE INTO exams (exam_id, subject, department, semester, exam_date) VALUES (?, ?, ?, ?, ?)'
    );
    foreach ($exams as $ex) {
        $stmt->bind_param('issis', $ex[0], $ex[1], $ex[2], $ex[3], $ex[4]);
        $stmt->execute();
    }
}

$finalStudents = (int)$mysqli->query('SELECT COUNT(*) AS c FROM students')->fetch_assoc()['c'];
$finalExams = (int)$mysqli->query('SELECT COUNT(*) AS c FROM exams')->fetch_assoc()['c'];
$finalShifts = (int)$mysqli->query('SELECT COUNT(*) AS c FROM shifts')->fetch_assoc()['c'];

json_ok([
    'message' => 'Data ready.',
    'students' => $finalStudents,
    'exams' => $finalExams,
    'shifts' => $finalShifts
]);
