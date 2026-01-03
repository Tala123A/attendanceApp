<?php

header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
include "db.php";


if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}
include "db.php";

$result = $conn->query("SELECT id, name, absences FROM students");
$students = [];

while ($row = $result->fetch_assoc()) {
    $stmt = $conn->prepare("SELECT date, present FROM attendance WHERE student_id = ?");
    $stmt->bind_param("i", $row['id']);
    $stmt->execute();
    $attResult = $stmt->get_result();

    $attendanceByDate = [];
    while ($att = $attResult->fetch_assoc()) {
        $attendanceByDate[$att['date']] = (bool)$att['present'];
    }

    $students[] = [
        "id" => (int)$row['id'],
        "name" => $row['name'],
        "absences" => (int)$row['absences'],
        "attendanceByDate" => $attendanceByDate
    ];
}

header('Content-Type: application/json');
echo json_encode($students);
?>
