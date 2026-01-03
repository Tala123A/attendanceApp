<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, api_key");

// Use Railway MySQL environment variables
$servername = getenv("DB_HOST");
$username   = getenv("DB_USER");
$password   = getenv("DB_PASS");
$dbname     = getenv("DB_NAME");

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed: '.$conn->connect_error]));
}
?>
