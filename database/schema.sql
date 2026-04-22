-- Exam Seating Management System Schema
-- Compatible with MySQL 8+

CREATE DATABASE IF NOT EXISTS exam_seating_db;
USE exam_seating_db;

-- Students master table
CREATE TABLE IF NOT EXISTS students (
    roll_no INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exams master table
CREATE TABLE IF NOT EXISTS exams (
    exam_id INT PRIMARY KEY,
    subject VARCHAR(100) NOT NULL,
    exam_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shift table
CREATE TABLE IF NOT EXISTS shifts (
    shift_id INT PRIMARY KEY,
    shift_name VARCHAR(40) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student to exam mapping (many-to-many)
CREATE TABLE IF NOT EXISTS student_exam_map (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_roll_no INT NOT NULL,
    exam_id INT NOT NULL,
    mapped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_exam UNIQUE (student_roll_no, exam_id),
    CONSTRAINT fk_map_student
        FOREIGN KEY (student_roll_no) REFERENCES students(roll_no)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_map_exam
        FOREIGN KEY (exam_id) REFERENCES exams(exam_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Seating assignments
CREATE TABLE IF NOT EXISTS seating (
    seat_no INT PRIMARY KEY,
    student_roll_no INT NOT NULL,
    exam_id INT NOT NULL,
    shift_id INT NULL,
    hall_name VARCHAR(50) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seating_student
        FOREIGN KEY (student_roll_no) REFERENCES students(roll_no)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seating_exam
        FOREIGN KEY (exam_id) REFERENCES exams(exam_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seating_shift
        FOREIGN KEY (shift_id) REFERENCES shifts(shift_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Generic key-value store to mirror db.c behavior
CREATE TABLE IF NOT EXISTS db_records (
    record_key VARCHAR(50) PRIMARY KEY,
    record_value VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Useful indexes
CREATE INDEX idx_exams_date ON exams(exam_date);
CREATE INDEX idx_seating_exam ON seating(exam_id);
CREATE INDEX idx_seating_student ON seating(student_roll_no);
