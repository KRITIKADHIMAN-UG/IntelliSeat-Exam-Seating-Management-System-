<?php
require __DIR__ . '/config.php';
require_auth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $examId = isset($_GET['exam_id']) ? (int)$_GET['exam_id'] : 0;
    $sql = 'SELECT st.seat_no, st.hall_name, st.student_roll_no, st.exam_id, st.shift_id,
                   s.name, s.department, s.subject, s.semester,
                   e.subject AS exam_subject, sh.shift_name
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
    json_ok(['seating' => $rows]);
}

if ($method === 'POST') {
    $body = read_json_body();
    $examId = (int)($body['exam_id'] ?? 0);
    $shiftId = isset($body['shift_id']) && $body['shift_id'] !== ''
        ? (int)$body['shift_id'] : 1;

    if ($examId <= 0) {
        json_error('Valid exam ID is required.');
    }

    $examCheck = $mysqli->prepare('SELECT exam_id FROM exams WHERE exam_id = ?');
    $examCheck->bind_param('i', $examId);
    $examCheck->execute();
    if (!$examCheck->get_result()->fetch_assoc()) {
        json_error('Exam not found.');
    }

    $halls = $body['halls'] ?? [];
    if (!is_array($halls) || count($halls) === 0) {
        $hallName = validate_code($body['hall_name'] ?? '', 'Hall name');
        $capacity = (int)($body['capacity'] ?? 0);
        if ($capacity <= 0) {
            json_error('Hall capacity must be greater than 0.');
        }
        $halls = [['name' => $hallName, 'capacity' => $capacity]];
    }

    $students = [];
    $studentSql = 'SELECT roll_no, department, subject, semester FROM students ORDER BY roll_no ASC';
    if (!empty($body['filter_department'])) {
        $dept = validate_code($body['filter_department'], 'Department');
        $stmt = $mysqli->prepare(
            'SELECT roll_no, department, subject, semester FROM students WHERE department = ? ORDER BY roll_no ASC'
        );
        $stmt->bind_param('s', $dept);
        $stmt->execute();
        $res = $stmt->get_result();
    } else {
        $res = $mysqli->query($studentSql);
    }
    while ($row = $res->fetch_assoc()) {
        $students[] = $row;
    }

    if (count($students) === 0) {
        json_error('No students available for seating. Run Initialize Students first.');
    }

    $mysqli->begin_transaction();
    try {
        $clear = $mysqli->prepare('DELETE FROM seating WHERE exam_id = ?');
        $clear->bind_param('i', $examId);
        if (!$clear->execute()) {
            throw new Exception($clear->error);
        }

        $insert = $mysqli->prepare(
            'INSERT INTO seating (exam_id, hall_name, seat_no, student_roll_no, shift_id)
             VALUES (?, ?, ?, ?, ?)'
        );

        $studentIndex = 0;
        $totalAssigned = 0;
        $hallSummary = [];

        foreach ($halls as $hall) {
            $hallName = validate_code($hall['name'] ?? $hall['hall_name'] ?? '', 'Hall name');
            $capacity = (int)($hall['capacity'] ?? 0);
            if ($capacity <= 0) {
                continue;
            }

            $assignedInHall = 0;
            for ($seat = 1; $seat <= $capacity; $seat++) {
                if ($studentIndex >= count($students)) {
                    break 2;
                }
                $roll = (int)$students[$studentIndex]['roll_no'];
                $insert->bind_param('isiii', $examId, $hallName, $seat, $roll, $shiftId);
                if (!$insert->execute()) {
                    throw new Exception($insert->error);
                }
                $studentIndex++;
                $assignedInHall++;
                $totalAssigned++;
            }
            if ($assignedInHall > 0) {
                $hallSummary[] = ['hall' => $hallName, 'assigned' => $assignedInHall];
            }
        }

        $mysqli->commit();
        json_ok([
            'message' => "Seating generated for $totalAssigned students across " . count($hallSummary) . " hall(s).",
            'assigned' => $totalAssigned,
            'halls' => $hallSummary,
            'remaining' => max(0, count($students) - $totalAssigned)
        ]);
    } catch (Exception $ex) {
        $mysqli->rollback();
        json_error($ex->getMessage(), 500);
    }
}

json_error('Method not allowed.', 405);
