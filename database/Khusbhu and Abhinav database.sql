-- =========================================================
-- INTELLISEAT DATABASE
-- UPDATED ACCORDING TO PROVIDED STUDENT DATA
-- =========================================================

CREATE DATABASE IF NOT EXISTS intelliseat;

USE intelliseat;

-- =========================================================
-- STUDENTS TABLE
-- =========================================================

CREATE TABLE students (

    roll_no BIGINT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    branch VARCHAR(50) NOT NULL,

    semester INT NOT NULL,

    subject VARCHAR(100),

    shift_name VARCHAR(20),

    hall_name VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- EXAMS TABLE
-- =========================================================

CREATE TABLE exams (

    exam_id INT AUTO_INCREMENT PRIMARY KEY,

    subject VARCHAR(100) NOT NULL,

    exam_date DATE NOT NULL,

    duration INT DEFAULT 180,

    total_marks INT DEFAULT 100
);

-- =========================================================
-- SHIFTS TABLE
-- =========================================================

CREATE TABLE shifts (

    shift_id INT AUTO_INCREMENT PRIMARY KEY,

    shift_name VARCHAR(20) NOT NULL,

    start_time TIME NOT NULL,

    end_time TIME NOT NULL
);

-- =========================================================
-- SEATING TABLE
-- =========================================================

CREATE TABLE seating (

    seat_no INT AUTO_INCREMENT PRIMARY KEY,

    roll_no BIGINT,

    exam_id INT,

    hall_name VARCHAR(20),

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

    roll_no BIGINT,

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

    roll_no BIGINT,

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

CREATE INDEX idx_exam_subject
ON exams(subject);

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
    s.subject,
    s.semester,
    s.shift_name,
    se.seat_no,
    se.hall_name

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
ON e.subject IS NOT NULL;

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

    IN p_roll BIGINT,
    IN p_exam INT,
    IN p_hall VARCHAR(20)

)

BEGIN

    DECLARE student_branch VARCHAR(50);

    SELECT branch
    INTO student_branch
    FROM students
    WHERE roll_no = p_roll;

    INSERT INTO seating(

        roll_no,
        exam_id,
        hall_name,
        branch

    )

    VALUES(

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

    IN p_roll BIGINT

)

BEGIN

    SELECT

        s.name,
        s.subject,
        s.semester,
        s.shift_name,
        st.hall_name,
        st.seat_no

    FROM students s

    JOIN seating st
    ON s.roll_no = st.roll_no

    WHERE s.roll_no = p_roll;

END //

DELIMITER ;

-- =========================================================
-- INSERT EXAM DATA
-- =========================================================

INSERT INTO exams(subject, exam_date, duration, total_marks)
VALUES

('DBMS', '2026-06-01', 180, 100),
('Operating Systems', '2026-06-02', 180, 100),
('Computer Networks', '2026-06-03', 180, 100),
('Design and Analysis of Algorithms', '2026-06-04', 180, 100),
('Digital Electronics', '2026-06-05', 180, 100),
('Thermodynamics', '2026-06-06', 180, 100),
('Structural Analysis', '2026-06-07', 180, 100),
('Web Technology', '2026-06-08', 180, 100),
('Discrete Mathematics', '2026-06-09', 180, 100),
('Data Structures', '2026-06-10', 180, 100);

-- =========================================================
-- INSERT SHIFT DATA
-- =========================================================

INSERT INTO shifts(shift_name, start_time, end_time)
VALUES

('Morning', '09:00:00', '12:00:00'),
('Afternoon', '01:00:00', '04:00:00');

-- =========================================================
-- INSERT STUDENT DATA
-- =========================================================

INSERT INTO students
(roll_no, name, branch, semester, subject, shift_name, hall_name)

VALUES

(10002, 'Kritika Dhiman', 'CSE', 3, 'DBMS', 'Afternoon', 'HALL A'),
(240122101, 'Aarav Sharma', 'ECE', 4, 'DBMS', 'Morning', 'Hall A'),
(240122102, 'Vivaan Sharma', 'ME', 5, 'Operating Systems', 'Afternoon', 'Hall A'),
(240122103, 'Aditya Sharma', 'CE', 6, 'Computer Networks', 'Morning', 'Hall A'),
(240122104, 'Vihaan Sharma', 'IT', 7, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall A'),
(240122105, 'Arjun Sharma', 'CSE', 8, 'Digital Electronics', 'Morning', 'Hall A'),
(240122106, 'Sai Sharma', 'ECE', 3, 'Thermodynamics', 'Afternoon', 'Hall A'),
(240122107, 'Reyansh Sharma', 'ME', 4, 'Structural Analysis', 'Morning', 'Hall A'),
(240122108, 'Ayaan Sharma', 'CE', 5, 'Web Technology', 'Afternoon', 'Hall A'),
(240122109, 'Krishna Sharma', 'IT', 6, 'Discrete Mathematics', 'Morning', 'Hall A'),
(240122110, 'Ishaan Sharma', 'CSE', 7, 'Data Structures', 'Afternoon', 'Hall A'),
(240122111, 'Ananya Sharma', 'ECE', 8, 'DBMS', 'Morning', 'Hall A'),
(240122112, 'Diya Sharma', 'ME', 3, 'Operating Systems', 'Afternoon', 'Hall A'),
(240122113, 'Priya Sharma', 'CE', 4, 'Computer Networks', 'Morning', 'Hall A'),
(240122114, 'Isha Sharma', 'IT', 5, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall A'),
(240122115, 'Kavya Sharma', 'CSE', 6, 'Digital Electronics', 'Morning', 'Hall A'),
(240122116, 'Saanvi Sharma', 'ECE', 7, 'Thermodynamics', 'Afternoon', 'Hall A'),
(240122117, 'Aadhya Sharma', 'ME', 8, 'Structural Analysis', 'Morning', 'Hall A'),
(240122118, 'Kiara Sharma', 'CE', 3, 'Web Technology', 'Afternoon', 'Hall A'),
(240122119, 'Myra Sharma', 'IT', 4, 'Discrete Mathematics', 'Morning', 'Hall A'),
(240122120, 'Pari Sharma', 'CSE', 5, 'Data Structures', 'Afternoon', 'Hall A'),
(240122121, 'Rohan Sharma', 'ECE', 6, 'DBMS', 'Morning', 'Hall A'),
(240122122, 'Kabir Sharma', 'ME', 7, 'Operating Systems', 'Afternoon', 'Hall A'),
(240122123, 'Atharv Sharma', 'CE', 8, 'Computer Networks', 'Morning', 'Hall A'),
(240122124, 'Dhruv Sharma', 'IT', 3, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall A'),
(240122125, 'Yash Sharma', 'CSE', 4, 'Digital Electronics', 'Morning', 'Hall A'),
(240122126, 'Dev Sharma', 'ECE', 5, 'Thermodynamics', 'Afternoon', 'Hall A'),
(240122127, 'Rudra Sharma', 'ME', 6, 'Structural Analysis', 'Morning', 'Hall A'),
(240122128, 'Aryan Sharma', 'CE', 7, 'Web Technology', 'Afternoon', 'Hall A'),
(240122129, 'Advik Sharma', 'IT', 8, 'Discrete Mathematics', 'Morning', 'Hall A'),
(240122130, 'Pranav Sharma', 'CSE', 3, 'Data Structures', 'Afternoon', 'Hall A'),
(240122131, 'Neha Sharma', 'ECE', 4, 'DBMS', 'Morning', 'Hall A'),
(240122132, 'Pooja Sharma', 'ME', 5, 'Operating Systems', 'Afternoon', 'Hall A'),
(240122133, 'Sneha Sharma', 'CE', 6, 'Computer Networks', 'Morning', 'Hall A'),
(240122134, 'Riya Sharma', 'IT', 7, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall A'),
(240122135, 'Shreya Sharma', 'CSE', 8, 'Digital Electronics', 'Morning', 'Hall B'),
(240122136, 'Tanvi Sharma', 'ECE', 3, 'Thermodynamics', 'Afternoon', 'Hall B'),
(240122137, 'Nisha Sharma', 'ME', 4, 'Structural Analysis', 'Morning', 'Hall B'),
(240122138, 'Meera Sharma', 'CE', 5, 'Web Technology', 'Afternoon', 'Hall B'),
(240122139, 'Anjali Sharma', 'IT', 6, 'Discrete Mathematics', 'Morning', 'Hall B'),
(240122140, 'Kritika Sharma', 'CSE', 7, 'Data Structures', 'Afternoon', 'Hall B'),
(240122141, 'Raj Sharma', 'ECE', 8, 'DBMS', 'Morning', 'Hall B'),
(240122142, 'Amit Sharma', 'ME', 3, 'Operating Systems', 'Afternoon', 'Hall B'),
(240122143, 'Suresh Sharma', 'CE', 4, 'Computer Networks', 'Morning', 'Hall B'),
(240122144, 'Vikram Sharma', 'IT', 5, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall B'),
(240122145, 'Manoj Sharma', 'CSE', 6, 'Digital Electronics', 'Morning', 'Hall B'),
(240122146, 'Ravi Sharma', 'ECE', 7, 'Thermodynamics', 'Afternoon', 'Hall B'),
(240122147, 'Deepak Sharma', 'ME', 8, 'Structural Analysis', 'Morning', 'Hall B'),
(240122148, 'Nitin Sharma', 'CE', 3, 'Web Technology', 'Afternoon', 'Hall B'),
(240122149, 'Sanjay Sharma', 'IT', 4, 'Discrete Mathematics', 'Morning', 'Hall B'),
(240122150, 'Ashok Sharma', 'CSE', 5, 'Data Structures', 'Afternoon', 'Hall B'),
(240122151, 'Lakshmi Sharma', 'ECE', 6, 'DBMS', 'Morning', 'Hall B'),
(240122152, 'Sunita Sharma', 'ME', 7, 'Operating Systems', 'Afternoon', 'Hall B'),
(240122153, 'Geeta Sharma', 'CE', 8, 'Computer Networks', 'Morning', 'Hall B'),
(240122154, 'Rekha Sharma', 'IT', 3, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall B'),
(240122155, 'Pallavi Sharma', 'CSE', 4, 'Digital Electronics', 'Morning', 'Hall B'),
(240122156, 'Swati Sharma', 'ECE', 5, 'Thermodynamics', 'Afternoon', 'Hall B'),
(240122157, 'Divya Sharma', 'ME', 6, 'Structural Analysis', 'Morning', 'Hall B'),
(240122158, 'Bhavna Sharma', 'CE', 7, 'Web Technology', 'Afternoon', 'Hall B'),
(240122159, 'Jyoti Sharma', 'IT', 8, 'Discrete Mathematics', 'Morning', 'Hall B'),
(240122160, 'Kiran Sharma', 'CSE', 3, 'Data Structures', 'Afternoon', 'Hall B'),
(240122161, 'Harish Sharma', 'ECE', 4, 'DBMS', 'Morning', 'Hall B'),
(240122162, 'Gaurav Sharma', 'ME', 5, 'Operating Systems', 'Afternoon', 'Hall B'),
(240122163, 'Naveen Sharma', 'CE', 6, 'Computer Networks', 'Morning', 'Hall B'),
(240122164, 'Karthik Sharma', 'IT', 7, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall B'),
(240122165, 'Siddharth Sharma', 'CSE', 8, 'Digital Electronics', 'Morning', 'Hall B'),
(240122166, 'Harsh Sharma', 'ECE', 3, 'Thermodynamics', 'Afternoon', 'Hall B'),
(240122167, 'Varun Sharma', 'ME', 4, 'Structural Analysis', 'Morning', 'Hall B'),
(240122168, 'Akash Sharma', 'CE', 5, 'Web Technology', 'Afternoon', 'Hall B'),
(240122169, 'Rahul Sharma', 'IT', 6, 'Discrete Mathematics', 'Morning', 'Hall C'),
(240122170, 'Mohit Sharma', 'CSE', 7, 'Data Structures', 'Afternoon', 'Hall C'),
(240122171, 'Aarav Verma', 'ECE', 8, 'DBMS', 'Morning', 'Hall C'),
(240122172, 'Vivaan Verma', 'ME', 3, 'Operating Systems', 'Afternoon', 'Hall C'),
(240122173, 'Aditya Verma', 'CE', 4, 'Computer Networks', 'Morning', 'Hall C'),
(240122174, 'Vihaan Verma', 'IT', 5, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall C'),
(240122175, 'Arjun Verma', 'CSE', 6, 'Digital Electronics', 'Morning', 'Hall C'),
(240122176, 'Sai Verma', 'ECE', 7, 'Thermodynamics', 'Afternoon', 'Hall C'),
(240122177, 'Reyansh Verma', 'ME', 8, 'Structural Analysis', 'Morning', 'Hall C'),
(240122178, 'Ayaan Verma', 'CE', 3, 'Web Technology', 'Afternoon', 'Hall C'),
(240122179, 'Krishna Verma', 'IT', 4, 'Discrete Mathematics', 'Morning', 'Hall C'),
(240122180, 'Ishaan Verma', 'CSE', 5, 'Data Structures', 'Afternoon', 'Hall C'),
(240122181, 'Ananya Verma', 'ECE', 6, 'DBMS', 'Morning', 'Hall C'),
(240122182, 'Diya Verma', 'ME', 7, 'Operating Systems', 'Afternoon', 'Hall C'),
(240122183, 'Priya Verma', 'CE', 8, 'Computer Networks', 'Morning', 'Hall C'),
(240122184, 'Isha Verma', 'IT', 3, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall C'),
(240122185, 'Kavya Verma', 'CSE', 4, 'Digital Electronics', 'Morning', 'Hall C'),
(240122186, 'Saanvi Verma', 'ECE', 5, 'Thermodynamics', 'Afternoon', 'Hall C'),
(240122187, 'Aadhya Verma', 'ME', 6, 'Structural Analysis', 'Morning', 'Hall C'),
(240122188, 'Kiara Verma', 'CE', 7, 'Web Technology', 'Afternoon', 'Hall C'),
(240122189, 'Myra Verma', 'IT', 8, 'Discrete Mathematics', 'Morning', 'Hall C'),
(240122190, 'Pari Verma', 'CSE', 3, 'Data Structures', 'Afternoon', 'Hall C'),
(240122191, 'Rohan Verma', 'ECE', 4, 'DBMS', 'Morning', 'Hall C'),
(240122192, 'Kabir Verma', 'ME', 5, 'Operating Systems', 'Afternoon', 'Hall C'),
(240122193, 'Atharv Verma', 'CE', 6, 'Computer Networks', 'Morning', 'Hall C'),
(240122194, 'Dhruv Verma', 'IT', 7, 'Design and Analysis of Algorithms', 'Afternoon', 'Hall C'),
(240122195, 'Yash Verma', 'CSE', 8, 'Digital Electronics', 'Morning', 'Hall C'),
(240122196, 'Dev Verma', 'ECE', 3, 'Thermodynamics', 'Afternoon', 'Hall C'),
(240122197, 'Rudra Verma', 'ME', 4, 'Structural Analysis', 'Morning', 'Hall C'),
(240122198, 'Aryan Verma', 'CE', 5, 'Web Technology', 'Afternoon', 'Hall C'),
(240122199, 'Advik Verma', 'IT', 6, 'Discrete Mathematics', 'Morning', 'Hall C'),
(240122200, 'Pranav Verma', 'CSE', 7, 'Data Structures', 'Afternoon', 'Hall C');
-- =========================================================
-- SAMPLE SEATING DATA
-- =========================================================

INSERT INTO seating
(roll_no, exam_id, hall_name, branch)

VALUES

(10002, 1, 'HALL A', 'CSE'),

(240122101, 1, 'Hall A', 'ECE'),

(240122102, 2, 'Hall A', 'ME'),

(240122103, 3, 'Hall A', 'CE'),

(240122104, 4, 'Hall A', 'IT');

-- =========================================================
-- DATABASE READY
-- =========================================================
