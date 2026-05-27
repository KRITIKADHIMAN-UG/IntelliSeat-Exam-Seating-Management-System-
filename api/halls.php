<?php
require __DIR__ . '/config.php';
require_auth();

$result = $mysqli->query('SELECT hall_id, hall_name, capacity FROM halls ORDER BY hall_id ASC');
if (!$result) {
    json_error($mysqli->error, 500);
}
$rows = [];
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}
json_ok(['halls' => $rows]);
