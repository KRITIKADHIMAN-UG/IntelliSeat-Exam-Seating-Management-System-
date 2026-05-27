<?php

function exam_seating_seed_students(mysqli $mysqli): int
{
    $firstNames = [
        'Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh', 'Ayaan', 'Krishna', 'Ishaan',
        'Ananya', 'Diya', 'Priya', 'Isha', 'Kavya', 'Saanvi', 'Aadhya', 'Kiara', 'Myra', 'Pari',
        'Rohan', 'Kabir', 'Atharv', 'Dhruv', 'Yash', 'Dev', 'Rudra', 'Aryan', 'Advik', 'Pranav',
        'Neha', 'Pooja', 'Sneha', 'Riya', 'Shreya', 'Tanvi', 'Nisha', 'Meera', 'Anjali', 'Kritika',
        'Raj', 'Amit', 'Suresh', 'Vikram', 'Manoj', 'Ravi', 'Deepak', 'Nitin', 'Sanjay', 'Ashok',
        'Lakshmi', 'Sunita', 'Geeta', 'Rekha', 'Pallavi', 'Swati', 'Divya', 'Bhavna', 'Jyoti', 'Kiran'
    ];
    $lastNames = [
        'Sharma', 'Verma', 'Patel', 'Kumar', 'Singh', 'Gupta', 'Reddy', 'Nair', 'Iyer', 'Menon',
        'Joshi', 'Rao', 'Mehta', 'Shah', 'Agarwal', 'Malhotra', 'Chopra', 'Bansal', 'Kapoor', 'Das',
        'Mishra', 'Pandey', 'Yadav', 'Thakur', 'Kulkarni', 'Desai', 'Saxena', 'Tiwari', 'Dubey', 'Bhat'
    ];
    $departments = ['CSE', 'ECE', 'ME', 'CE', 'IT'];
    $subjects = [
        'Data Structures', 'DBMS', 'Operating Systems', 'Computer Networks', 'DAA',
        'Digital Electronics', 'Thermodynamics', 'Structural Analysis', 'Web Technology', 'Discrete Math'
    ];
    $halls = ['Hall A', 'Hall B', 'Hall C'];
    $semesters = [3, 4, 5, 6, 7, 8];

    $stmt = $mysqli->prepare(
        'INSERT IGNORE INTO students (roll_no, name, department, subject, semester, shift_id, default_hall)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );

    $inserted = 0;
    for ($i = 1; $i <= 100; $i++) {
        $roll = 240122100 + $i;
        $fname = $firstNames[($i - 1) % count($firstNames)];
        $lname = $lastNames[intdiv($i - 1, count($firstNames)) % count($lastNames)];
        $name = $fname . ' ' . $lname;
        $dept = $departments[$i % count($departments)];
        $subject = $subjects[$i % count($subjects)];
        $sem = $semesters[$i % count($semesters)];
        $shift = ($i % 2 === 0) ? 2 : 1;
        $hall = $halls[intdiv($i - 1, 34) % count($halls)];

        $stmt->bind_param('isssiis', $roll, $name, $dept, $subject, $sem, $shift, $hall);
        if ($stmt->execute() && $stmt->affected_rows > 0) {
            $inserted++;
        }
    }
    return $inserted;
}
