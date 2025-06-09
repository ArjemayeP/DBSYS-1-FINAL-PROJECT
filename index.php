<?php
$host = "localhost";
$user = "root";
$password = "";

// Connect without specifying a database
$conn = mysqli_connect($host, $user, $password);
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

// Create the database only if it does not exist
$sql = "CREATE DATABASE IF NOT EXISTS inventor_system";
if (mysqli_query($conn, $sql)) {
    echo "Database checked/created successfully!";
} else {
    echo "Error creating database: " . mysqli_error($conn);
}

mysqli_close($conn);
?>