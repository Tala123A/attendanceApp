<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, api_key");

// Get MySQL URL from environment
$mysql_url = getenv("DB_URL");

// Parse URL
$parts = parse_url($mysql_url);

$servername = $parts['host'];
$username   = $parts['user'];
$password   = $parts['pass'];
$dbname     = ltrim($parts['path'], '/');

// Connect to MySQL
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}
?>
