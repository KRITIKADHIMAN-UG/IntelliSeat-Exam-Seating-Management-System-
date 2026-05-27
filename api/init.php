<?php
require __DIR__ . '/config.php';
require_auth();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_error('Method not allowed.', 405);
}

require_once __DIR__ . '/seed_students.php';
$inserted = exam_seating_seed_students($mysqli);

$total = (int)$mysqli->query('SELECT COUNT(*) AS c FROM students')->fetch_assoc()['c'];
json_ok([
    'message' => "Student data refreshed. $inserted new records added.",
    'count' => $total
]);
