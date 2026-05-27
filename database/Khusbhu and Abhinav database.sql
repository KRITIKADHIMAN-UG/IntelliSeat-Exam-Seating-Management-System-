-- =========================================================
-- INTELLISEAT DATABASE
-- =========================================================

CREATE DATABASE IF NOT EXISTS intelliseat;

USE intelliseat;

-- =========================================================
-- STUDENTS TABLE
-- =========================================================

CREATE TABLE students (

    roll_no INT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    branch VARCHAR(50) NOT NULL,

    semester INT DEFAULT 1,

    email VARCHAR(100),

    phone VARCHAR(15),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- EXAMS TABLE
-- =========================================================

CREATE TABLE exams (

    exam_id INT PRIMARY KEY,

    subject VARCHAR(100) NOT NULL,

    exam_date DATE NOT NULL,

    duration INT DEFAULT 180,

    total_marks INT DEFAULT 100
);

-- =========================================================
-- SHIFTS TABLE
-- =========================================================

CREATE TABLE shifts (

    shift_id INT PRIMARY KEY,

    shift_name VARCHAR(50) NOT NULL,

    start_time TIME NOT NULL,

    end_time TIME NOT NULL,

    exam_id INT,

    FOREIGN KEY (exam_id)
    REFERENCES exams(exam_id)
    ON DELETE CASCADE
);

-- =========================================================
-- SEATING TABLE
-- =========================================================

CREATE TABLE seating (

    seat_no INT PRIMARY KEY,

    roll_no INT,

    exam_id INT,

    hall_name VARCHAR(50),

    branch VARCHAR(50),

    allocation_status VARCHAR(20) DEFAULT 'ALLOCATED',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (roll_no)
    REFERENCES students(roll_no)
    ON DELETE CASCADE,

    FOREIGN KEY (exam_id)
    REFERENCES exams(exam_id)
    ON DELETE CASCADE
);

-- =========================================================
-- BACKLOG STUDENTS TABLE
-- =========================================================

CREATE TABLE backlog_students (

    backlog_id INT AUTO_INCREMENT PRIMARY KEY,

    roll_no INT,

    subject VARCHAR(100),

    attempts INT DEFAULT 1,

    status VARCHAR(20) DEFAULT 'PENDING',

    FOREIGN KEY (roll_no)
    REFERENCES students(roll_no)
    ON DELETE CASCADE
);

-- =========================================================
-- INTERNSHIP STUDENTS TABLE
-- =========================================================

CREATE TABLE internship_students (

    internship_id INT AUTO_INCREMENT PRIMARY KEY,

    roll_no INT,

    company VARCHAR(100),

    role_name VARCHAR(100),

    start_date DATE,

    end_date DATE,

    status VARCHAR(20),

    FOREIGN KEY (roll_no)
    REFERENCES students(roll_no)
    ON DELETE CASCADE
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_student_branch
ON students(branch);

CREATE INDEX idx_student_name
ON students(name);

CREATE INDEX idx_exam_date
ON exams(exam_date);

CREATE INDEX idx_seating_exam
ON seating(exam_id);

CREATE INDEX idx_seating_roll
ON seating(roll_no);

-- =========================================================
-- VIEW : STUDENT SEATING VIEW
-- =========================================================

CREATE VIEW student_seating_view AS

SELECT

    s.roll_no,
    s.name,
    s.branch,
    se.seat_no,
    se.hall_name,
    se.exam_id

FROM students s

JOIN seating se
ON s.roll_no = se.roll_no;

-- =========================================================
-- VIEW : EXAM SCHEDULE VIEW
-- =========================================================

CREATE VIEW exam_schedule_view AS

SELECT

    e.exam_id,
    e.subject,
    e.exam_date,
    sh.shift_name,
    sh.start_time,
    sh.end_time

FROM exams e

JOIN shifts sh
ON e.exam_id = sh.exam_id;

-- =========================================================
-- TRIGGER : PREVENT DUPLICATE SEAT
-- =========================================================

DELIMITER //

CREATE TRIGGER prevent_duplicate_seat

BEFORE INSERT ON seating

FOR EACH ROW

BEGIN

    IF EXISTS (

        SELECT 1
        FROM seating
        WHERE seat_no = NEW.seat_no

    )

    THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat already assigned';

    END IF;

END //

DELIMITER ;

-- =========================================================
-- TRIGGER : AUTO BRANCH FETCH
-- =========================================================

DELIMITER //

CREATE TRIGGER auto_fill_branch

BEFORE INSERT ON seating

FOR EACH ROW

BEGIN

    DECLARE student_branch VARCHAR(50);

    SELECT branch
    INTO student_branch
    FROM students
    WHERE roll_no = NEW.roll_no;

    SET NEW.branch = student_branch;

END //

DELIMITER ;

-- =========================================================
-- STORED PROCEDURE : ASSIGN SEAT
-- =========================================================

DELIMITER //

CREATE PROCEDURE assign_seat(

    IN p_roll INT,
    IN p_exam INT,
    IN p_hall VARCHAR(50),
    IN p_seat INT

)

BEGIN

    DECLARE student_branch VARCHAR(50);

    SELECT branch
    INTO student_branch
    FROM students
    WHERE roll_no = p_roll;

    INSERT INTO seating(

        seat_no,
        roll_no,
        exam_id,
        hall_name,
        branch

    )

    VALUES(

        p_seat,
        p_roll,
        p_exam,
        p_hall,
        student_branch
    );

END //

DELIMITER ;

-- =========================================================
-- STORED PROCEDURE : GET STUDENT EXAMS
-- =========================================================

DELIMITER //

CREATE PROCEDURE get_student_exams(

    IN p_roll INT

)

BEGIN

    SELECT

        s.name,
        e.subject,
        e.exam_date,
        st.hall_name,
        st.seat_no

    FROM students s

    JOIN seating st
    ON s.roll_no = st.roll_no

    JOIN exams e
    ON st.exam_id = e.exam_id

    WHERE s.roll_no = p_roll;

END //

DELIMITER ;

-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT INTO students(

    roll_no,
    name,
    branch,
    semester,
    email,
    phone

)

VALUES

(101, 'Aman', 'CSE', 3, 'aman@gmail.com', '9999999999'),

(102, 'Rahul', 'IT', 3, 'rahul@gmail.com', '8888888888'),

(103, 'Priya', 'ECE', 5, 'priya@gmail.com', '7777777777');

-- =========================================================

INSERT INTO exams(

    exam_id,
    subject,
    exam_date,
    duration,
    total_marks

)

VALUES

(1, 'DBMS', '2026-05-20', 180, 100),

(2, 'Operating Systems', '2026-05-22', 180, 100),

(3, 'Computer Networks', '2026-05-25', 180, 100);

-- =========================================================

INSERT INTO shifts(

    shift_id,
    shift_name,
    start_time,
    end_time,
    exam_id

)

VALUES

(1, 'Morning', '09:00:00', '12:00:00', 1),

(2, 'Afternoon', '01:00:00', '04:00:00', 2),

(3, 'Evening', '05:00:00', '08:00:00', 3);

-- =========================================================

INSERT INTO seating(

    seat_no,
    roll_no,
    exam_id,
    hall_name,
    branch

)

VALUES

(1, 101, 1, 'Hall-A', 'CSE'),

(2, 102, 2, 'Hall-B', 'IT'),

(3, 103, 3, 'Hall-C', 'ECE');