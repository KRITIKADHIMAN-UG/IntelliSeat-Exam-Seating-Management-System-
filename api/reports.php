<?php
require __DIR__ . '/config.php';
require_auth();

$examId = isset($_GET['exam_id']) ? (int)$_GET['exam_id'] : 0;
$sql = 'SELECT st.hall_name, st.seat_no, st.student_roll_no, s.name, s.department,
               s.subject, s.semester, e.subject AS exam_subject, e.exam_date,
               sh.shift_name, sh.start_time, sh.end_time
        FROM seating st
        JOIN students s ON s.roll_no = st.student_roll_no
        JOIN exams e ON e.exam_id = st.exam_id
        LEFT JOIN shifts sh ON sh.shift_id = st.shift_id';
if ($examId > 0) {
    $sql .= ' WHERE st.exam_id = ' . $examId;
}
$sql .= ' ORDER BY st.hall_name, st.seat_no ASC';

$result = $mysqli->query($sql);
if (!$result) {
    json_error($mysqli->error, 500);
}
$rows = [];
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}
json_ok(['report' => $rows, 'generated_at' => date('Y-m-d H:i:s')]);
