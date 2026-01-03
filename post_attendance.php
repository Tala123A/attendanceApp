<?php

header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}


header('Content-Type: application/json');

$servername = "localhost";
$username = "root";     
$password = "";          
$dbname = "attendance_db";


$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed']));
}


if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
    exit;
}

if ($_POST['api_key'] !== 'ATTENDANCE123') {
    echo json_encode(['status' => 'error', 'message' => 'Invalid API key']);
    exit;
}

$student_id = intval($_POST['student_id']);
$present = intval($_POST['present']);
$date = $_POST['date'] ?? date('Y-m-d');

if (!$student_id || ($present !== 0 && $present !== 1)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
    exit;
}

$stmt = $conn->prepare("SELECT present FROM attendance WHERE student_id=? AND date=?");
$stmt->bind_param("is", $student_id, $date);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {

    $stmt_update = $conn->prepare("UPDATE attendance SET present=? WHERE student_id=? AND date=?");
    $stmt_update->bind_param("iis", $present, $student_id, $date);
    $stmt_update->execute();
} else {
    
    $stmt_insert = $conn->prepare("INSERT INTO attendance (student_id, date, present) VALUES (?, ?, ?)");
    $stmt_insert->bind_param("isi", $student_id, $date, $present);
    $stmt_insert->execute();


    if ($present === 0) {
        $stmt_abs = $conn->prepare("UPDATE students SET absences = absences - 1 WHERE id=? AND absences>0");
        $stmt_abs->bind_param("i", $student_id);
        $stmt_abs->execute();
    }
}

echo json_encode(['status' => 'success']);
$conn->close();
?>
