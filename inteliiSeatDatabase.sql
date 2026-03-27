CREATE DATABASE exam_system;
USE exam_system;

CREATE TABLE students (
    roll_no INT PRIMARY KEY,
    name VARCHAR(50),
    branch VARCHAR(10)
);

CREATE TABLE exams (
    exam_id INT AUTO_INCREMENT PRIMARY KEY,
    subject VARCHAR(50),
    date DATE,
    shift VARCHAR(10)
);

CREATE TABLE seating (
    id INT AUTO_INCREMENT PRIMARY KEY,
    roll_no INT,
    room INT,
    row_no INT,
    col_no INT,
    shift VARCHAR(10)
);
