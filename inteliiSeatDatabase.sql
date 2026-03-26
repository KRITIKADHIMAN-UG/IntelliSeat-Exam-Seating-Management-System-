-- IntelliSeat Exam Seating Management System Database Schema
-- SQL Server Compatible Schema

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'IntelliSeatDB')
BEGIN
    CREATE DATABASE IntelliSeatDB;
END
GO

USE IntelliSeatDB;
GO

-- Drop existing tables if they exist (for fresh start)
IF OBJECT_ID('dbo.SeatingArrangements', 'U') IS NOT NULL DROP TABLE dbo.SeatingArrangements;
IF OBJECT_ID('dbo.ExamHalls', 'U') IS NOT NULL DROP TABLE dbo.ExamHalls;
IF OBJECT_ID('dbo.Exams', 'U') IS NOT NULL DROP TABLE dbo.Exams;
IF OBJECT_ID('dbo.Students', 'U') IS NOT NULL DROP TABLE dbo.Students;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
IF OBJECT_ID('dbo.Subjects', 'U') IS NOT NULL DROP TABLE dbo.Subjects;
GO

-- Create Departments Table
CREATE TABLE Departments (
    DeptID VARCHAR(10) PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Subjects Table
CREATE TABLE Subjects (
    SubjectID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectCode VARCHAR(20) UNIQUE NOT NULL,
    SubjectName VARCHAR(100) NOT NULL,
    DeptID VARCHAR(10) FOREIGN KEY REFERENCES Departments(DeptID),
    Credits INT DEFAULT 3,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Users Table (for login/authentication)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL, -- In production, this should be hashed
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Role VARCHAR(20) DEFAULT 'Administrator',
    IsActive BIT DEFAULT 1,
    LastLogin DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Students Table
CREATE TABLE Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    RollNumber VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DeptID VARCHAR(10) FOREIGN KEY REFERENCES Departments(DeptID),
    CurrentYear INT NOT NULL CHECK (CurrentYear BETWEEN 1 AND 4),
    CurrentSemester INT NOT NULL CHECK (CurrentSemester BETWEEN 1 AND 8),
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('active', 'suspended', 'inactive')),
    AttendancePercentage DECIMAL(5,2) DEFAULT 0.00 CHECK (AttendancePercentage BETWEEN 0 AND 100),
    EligibilityStatus BIT DEFAULT 0, -- Calculated based on attendance and status
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255),
    AdmissionDate DATE,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Student-Subjects Mapping Table
CREATE TABLE StudentSubjects (
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
    Semester INT NOT NULL,
    Year INT NOT NULL,
    Grade VARCHAR(5),
    PRIMARY KEY (StudentID, SubjectID, Semester, Year)
);
GO

-- Create Exam Halls Table
CREATE TABLE ExamHalls (
    HallID INT IDENTITY(1,1) PRIMARY KEY,
    HallName VARCHAR(50) NOT NULL,
    HallType VARCHAR(10) NOT NULL CHECK (HallType IN ('LT', 'CR')), -- LT = Lecture Theatre, CR = Classroom
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Location VARCHAR(100),
    HasProjector BIT DEFAULT 1,
    HasAC BIT DEFAULT 1,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Exams Table
CREATE TABLE Exams (
    ExamID INT IDENTITY(1,1) PRIMARY KEY,
    ExamName VARCHAR(100) NOT NULL,
    ExamType VARCHAR(20) NOT NULL CHECK (ExamType IN ('midterm', 'interim', 'term', 'final')),
    SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
    ExamDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Duration DECIMAL(4,2) NOT NULL, -- Duration in hours
    HallID INT FOREIGN KEY REFERENCES ExamHalls(HallID),
    Status VARCHAR(20) DEFAULT 'scheduled' CHECK (Status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    Instructions TEXT,
    CreatedBy INT FOREIGN KEY REFERENCES Users(UserID),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Seating Arrangements Table
CREATE TABLE SeatingArrangements (
    ArrangementID INT IDENTITY(1,1) PRIMARY KEY,
    ExamID INT FOREIGN KEY REFERENCES Exams(ExamID),
    HallID INT FOREIGN KEY REFERENCES ExamHalls(HallID),
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    SeatNumber INT NOT NULL,
    RowNumber INT NOT NULL,
    ColumnNumber INT NOT NULL,
    AlgorithmUsed VARCHAR(20) NOT NULL, -- sequential, alternate, random, department
    ArrangementDate DATETIME DEFAULT GETDATE(),
    UNIQUE (ExamID, HallID, SeatNumber),
    UNIQUE (ExamID, StudentID)
);
GO

-- Create Exam Conflicts View
CREATE VIEW ExamConflicts AS
SELECT 
    e1.ExamID as Exam1_ID,
    e1.ExamName as Exam1_Name,
    e2.ExamID as Exam2_ID,
    e2.ExamName as Exam2_Name,
    e1.ExamDate,
    e1.StartTime as Exam1_Start,
    e1.EndTime as Exam1_End,
    e2.StartTime as Exam2_Start,
    e2.EndTime as Exam2_End,
    h1.HallName as Hall1_Name,
    h2.HallName as Hall2_Name,
    CASE 
        WHEN e1.HallID = e2.HallID THEN 'Same Hall Conflict'
        WHEN (e1.StartTime < e2.EndTime AND e1.EndTime > e2.StartTime) THEN 'Time Overlap'
        ELSE 'No Conflict'
    END as ConflictType
FROM Exams e1
JOIN Exams e2 ON e1.ExamID < e2.ExamID AND e1.ExamDate = e2.ExamDate
JOIN ExamHalls h1 ON e1.HallID = h1.HallID
JOIN ExamHalls h2 ON e2.HallID = h2.HallID
WHERE (e1.StartTime < e2.EndTime AND e1.EndTime > e2.StartTime) OR e1.HallID = e2.HallID;
GO

-- Create Student Eligibility View
CREATE VIEW StudentEligibility AS
SELECT 
    s.StudentID,
    s.RollNumber,
    s.FirstName + ' ' + s.LastName as FullName,
    d.DeptName,
    s.CurrentYear,
    s.CurrentSemester,
    s.Status,
    s.AttendancePercentage,
    CASE 
        WHEN s.AttendancePercentage >= 75 AND s.Status = 'active' THEN 1
        ELSE 0
    END as IsEligible,
    COUNT(ss.SubjectID) as EnrolledSubjects
FROM Students s
LEFT JOIN Departments d ON s.DeptID = d.DeptID
LEFT JOIN StudentSubjects ss ON s.StudentID = ss.StudentID
GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName, d.DeptName, 
         s.CurrentYear, s.CurrentSemester, s.Status, s.AttendancePercentage;
GO

-- Create Hall Utilization View
CREATE VIEW HallUtilization AS
SELECT 
    h.HallID,
    h.HallName,
    h.HallType,
    h.Capacity,
    COUNT(DISTINCT e.ExamID) as TotalExams,
    COUNT(DISTINCT sa.ArrangementID) as TotalStudentsSeated,
    CASE 
        WHEN h.Capacity > 0 THEN CAST(COUNT(DISTINCT sa.ArrangementID) * 100.0 / h.Capacity AS DECIMAL(5,2))
        ELSE 0
    END as UtilizationPercentage
FROM ExamHalls h
LEFT JOIN Exams e ON h.HallID = e.HallID
LEFT JOIN SeatingArrangements sa ON h.HallID = sa.HallID
GROUP BY h.HallID, h.HallName, h.HallType, h.Capacity;
GO

-- Insert sample departments with Indian context
INSERT INTO Departments (DeptID, DeptName, Description) VALUES
('CS', 'Computer Science', 'Department of Computer Science and Engineering'),
('EC', 'Electronics & Communication', 'Department of Electronics and Communication Engineering'),
('ME', 'Mechanical Engineering', 'Department of Mechanical Engineering'),
('CE', 'Civil Engineering', 'Department of Civil Engineering'),
('EE', 'Electrical Engineering', 'Department of Electrical Engineering'),
('IT', 'Information Technology', 'Department of Information Technology'),
('AE', 'Aerospace Engineering', 'Department of Aerospace Engineering'),
('CH', 'Chemical Engineering', 'Department of Chemical Engineering'),
('BT', 'Biotechnology', 'Department of Biotechnology'),
('PH', 'Physics', 'Department of Physics'),
('MA', 'Mathematics', 'Department of Mathematics');
GO

-- Insert sample data into Subjects
INSERT INTO Subjects (SubjectCode, SubjectName, DeptID, Credits) VALUES
('CS101', 'Data Structures', 'CS', 4),
('CS102', 'Algorithms', 'CS', 4),
('CS103', 'Database Systems', 'CS', 3),
('CS104', 'Operating Systems', 'CS', 4),
('EC101', 'Digital Electronics', 'EC', 3),
('EC102', 'Circuits', 'EC', 3),
('EC103', 'Signals', 'EC', 3),
('ME101', 'Thermodynamics', 'ME', 3),
('ME102', 'Mechanics', 'ME', 4),
('ME103', 'Manufacturing', 'ME', 3),
('CE101', 'Structures', 'CE', 4),
('CE102', 'Materials', 'CE', 3),
('CE103', 'Surveying', 'CE', 3),
('EE101', 'Power Systems', 'EE', 4),
('EE102', 'Machines', 'EE', 3),
('EE103', 'Control Systems', 'EE', 3);
GO

-- Insert sample user (administrator)
INSERT INTO Users (Username, Password, FullName, Email, Role) VALUES
('admin', 'admin123', 'System Administrator', 'admin@intelliSeat.edu', 'Administrator');
GO

-- Insert sample students with authentic Indian names
INSERT INTO Students (RollNumber, FirstName, LastName, DeptID, CurrentYear, CurrentSemester, Status, AttendancePercentage, Email, Phone, AdmissionDate) VALUES
('CS2024001', 'Rahul', 'Sharma', 'CS', 3, 5, 'active', 85.50, 'rahul.sharma@college.edu', '9876543210', '2021-08-01'),
('EC2024002', 'Priya', 'Patel', 'EC', 3, 5, 'active', 78.00, 'priya.patel@college.edu', '9876543211', '2021-08-01'),
('ME2024003', 'Amit', 'Kumar', 'ME', 2, 3, 'suspended', 45.00, 'amit.kumar@college.edu', '9876543212', '2021-08-01'),
('CE2024004', 'Anjali', 'Gupta', 'CE', 2, 3, 'active', 92.50, 'anjali.gupta@college.edu', '9876543213', '2021-08-01'),
('EE2024005', 'Vikram', 'Singh', 'EE', 4, 7, 'active', 88.00, 'vikram.singh@college.edu', '9876543214', '2021-08-01'),
('IT2024006', 'Neha', 'Verma', 'IT', 3, 5, 'active', 76.50, 'neha.verma@college.edu', '9876543215', '2021-08-01'),
('AE2024007', 'Rohit', 'Jain', 'AE', 4, 7, 'active', 81.00, 'rohit.jain@college.edu', '9876543216', '2021-08-01'),
('CH2024008', 'Kavita', 'Reddy', 'CH', 2, 3, 'inactive', 65.00, 'kavita.reddy@college.edu', '9876543217', '2021-08-01'),
('BT2024009', 'Suresh', 'Iyer', 'BT', 3, 5, 'active', 79.50, 'suresh.iyer@college.edu', '9876543218', '2021-08-01'),
('PH2024010', 'Deepika', 'Nair', 'PH', 1, 1, 'active', 94.00, 'deepika.nair@college.edu', '9876543219', '2021-08-01'),
('MA2024011', 'Arjun', 'Menon', 'MA', 2, 3, 'active', 87.50, 'arjun.menon@college.edu', '9876543220', '2021-08-01');
GO

-- Insert student-subject relationships for Indian students
INSERT INTO StudentSubjects (StudentID, SubjectID, Semester, Year) VALUES
-- Rahul Sharma (CS)
(1, 1, 5, 3), (1, 2, 5, 3), (1, 3, 5, 3),
-- Priya Patel (EC)
(2, 12, 5, 3), (2, 13, 5, 3), (2, 14, 5, 3),
-- Amit Kumar (ME)
(3, 15, 3, 2), (3, 16, 3, 2), (3, 17, 3, 2),
-- Anjali Gupta (CE)
(4, 18, 3, 2), (4, 19, 3, 2), (4, 20, 3, 2),
-- Vikram Singh (EE)
(5, 21, 7, 4), (5, 22, 7, 4), (5, 23, 7, 4),
-- Neha Verma (IT)
(6, 6, 5, 3), (6, 7, 5, 3), (6, 8, 5, 3),
-- Rohit Jain (AE)
(7, 9, 7, 4), (7, 10, 7, 4), (7, 11, 7, 4),
-- Kavita Reddy (CH)
(8, 12, 3, 2), (8, 15, 3, 2), (8, 24, 3, 2),
-- Suresh Iyer (BT)
(9, 25, 5, 3), (9, 26, 5, 3), (9, 27, 5, 3),
-- Deepika Nair (PH)
(10, 28, 1, 1), (10, 29, 1, 1), (10, 30, 1, 1),
-- Arjun Menon (MA)
(11, 29, 3, 2), (11, 31, 3, 2), (11, 1, 3, 2);
GO

-- Insert sample exam halls
INSERT INTO ExamHalls (HallName, HallType, Capacity, Location) VALUES
('LT-01', 'LT', 120, 'Main Building - Floor 1'),
('LT-02', 'LT', 120, 'Main Building - Floor 2'),
('CR-01', 'CR', 60, 'Science Block - Room 101'),
('CR-02', 'CR', 60, 'Science Block - Room 102'),
('CR-03', 'CR', 60, 'Science Block - Room 103');
GO

-- Insert sample exams
INSERT INTO Exams (ExamName, ExamType, SubjectID, ExamDate, StartTime, EndTime, Duration, HallID, Status, CreatedBy) VALUES
('Midterm Data Structures', 'midterm', 1, '2024-03-15', '09:00:00', '10:30:00', 1.5, 1, 'scheduled', 1),
('Interim Algorithms', 'interim', 2, '2024-03-20', '14:00:00', '17:00:00', 3.0, 3, 'scheduled', 1),
('Term Exam Digital Electronics', 'term', 5, '2024-03-25', '10:00:00', '12:00:00', 2.0, 1, 'scheduled', 1);
GO

-- Create Stored Procedures

-- Procedure to add new student with validation
CREATE PROCEDURE sp_AddStudent
    @RollNumber VARCHAR(20),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DeptID VARCHAR(10),
    @CurrentYear INT,
    @CurrentSemester INT,
    @Status VARCHAR(20),
    @AttendancePercentage DECIMAL(5,2),
    @Email VARCHAR(100) = NULL,
    @Phone VARCHAR(20) = NULL,
    @Address VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EligibilityStatus BIT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        -- Validate roll number format
        IF @RollNumber NOT LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            RAISERROR('Roll number must be in format DEPTYYYYNNN (e.g., CS2024001)', 16, 1);
        
        -- Validate names
        IF @FirstName LIKE '%[^A-Z ]%' OR LEN(@FirstName) < 2 OR LEN(@FirstName) > 50
            RAISERROR('First name must contain only alphabetic characters (2-50 characters)', 16, 1);
            
        IF @LastName LIKE '%[^A-Z ]%' OR LEN(@LastName) < 2 OR LEN(@LastName) > 50
            RAISERROR('Last name must contain only alphabetic characters (2-50 characters)', 16, 1);
        
        -- Validate department
        IF NOT EXISTS (SELECT 1 FROM Departments WHERE DeptID = @DeptID)
            RAISERROR('Invalid department', 16, 1);
        
        -- Validate year and semester
        IF @CurrentYear < 1 OR @CurrentYear > 4
            RAISERROR('Year must be between 1 and 4', 16, 1);
            
        IF @CurrentSemester < 1 OR @CurrentSemester > 8
            RAISERROR('Semester must be between 1 and 8', 16, 1);
        
        -- Validate status
        IF @Status NOT IN ('active', 'suspended', 'inactive')
            RAISERROR('Status must be active, suspended, or inactive', 16, 1);
        
        -- Validate attendance
        IF @AttendancePercentage < 0 OR @AttendancePercentage > 100
            RAISERROR('Attendance must be between 0 and 100', 16, 1);
        
        -- Validate email if provided
        IF @Email IS NOT NULL AND @Email NOT LIKE '%@%.%'
            RAISERROR('Invalid email format', 16, 1);
        
        -- Validate phone if provided
        IF @Phone IS NOT NULL AND (@Phone NOT LIKE '[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR LEN(@Phone) != 10)
            RAISERROR('Phone must be 10 digits starting with 6, 7, 8, or 9', 16, 1);
        
        -- Check for duplicate roll number
        IF EXISTS (SELECT 1 FROM Students WHERE RollNumber = @RollNumber)
            RAISERROR('Roll number already exists', 16, 1);
        
        -- Calculate eligibility
        IF @AttendancePercentage >= 75 AND @Status = 'active'
            SET @EligibilityStatus = 1;
        ELSE
            SET @EligibilityStatus = 0;
        
        INSERT INTO Students (RollNumber, FirstName, LastName, DeptID, CurrentYear, CurrentSemester, 
                             Status, AttendancePercentage, EligibilityStatus, Email, Phone, Address)
        VALUES (@RollNumber, @FirstName, @LastName, @DeptID, @CurrentYear, @CurrentSemester,
                @Status, @AttendancePercentage, @EligibilityStatus, @Email, @Phone, @Address);
        
        SELECT SCOPE_IDENTITY() as StudentID, 'Student added successfully' as Message;
    
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        SELECT -1 as StudentID, @ErrorMessage as Message;
    END CATCH
END
GO

-- Procedure to update student eligibility
CREATE PROCEDURE sp_UpdateStudentEligibility
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Students
    SET EligibilityStatus = CASE 
        WHEN AttendancePercentage >= 75 AND Status = 'active' THEN 1
        ELSE 0
    END,
    UpdatedAt = GETDATE()
    WHERE StudentID = @StudentID;
END
GO

-- Procedure to create exam
CREATE PROCEDURE sp_CreateExam
    @ExamName VARCHAR(100),
    @ExamType VARCHAR(20),
    @SubjectID INT,
    @ExamDate DATE,
    @StartTime TIME,
    @Duration DECIMAL(4,2),
    @HallID INT,
    @Instructions TEXT = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EndTime TIME;
    
    -- Calculate end time based on duration
    SET @EndTime = DATEADD(minute, CAST(@Duration * 60 AS INT), @StartTime);
    
    INSERT INTO Exams (ExamName, ExamType, SubjectID, ExamDate, StartTime, EndTime, 
                      Duration, HallID, Instructions, CreatedBy)
    VALUES (@ExamName, @ExamType, @SubjectID, @ExamDate, @StartTime, @EndTime,
            @Duration, @HallID, @Instructions, @CreatedBy);
    
    SELECT SCOPE_IDENTITY() as ExamID;
END
GO

-- Procedure to generate seating arrangement
CREATE PROCEDURE sp_GenerateSeatingArrangement
    @ExamID INT,
    @Algorithm VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @HallID INT, @Capacity INT;
    DECLARE @SeatNumber INT = 1, @RowNumber INT = 1, @ColumnNumber INT = 1;
    
    -- Get hall details
    SELECT @HallID = HallID, @Capacity = Capacity
    FROM Exams e
    JOIN ExamHalls h ON e.HallID = h.HallID
    WHERE e.ExamID = @ExamID;
    
    -- Clear existing arrangements for this exam
    DELETE FROM SeatingArrangements WHERE ExamID = @ExamID;
    
    -- Generate seating based on algorithm
    IF @Algorithm = 'sequential'
    BEGIN
        INSERT INTO SeatingArrangements (ExamID, HallID, StudentID, SeatNumber, RowNumber, ColumnNumber, AlgorithmUsed)
        SELECT 
            @ExamID, @HallID, s.StudentID, 
            ROW_NUMBER() OVER (ORDER BY s.RollNumber) as SeatNumber,
            ((ROW_NUMBER() OVER (ORDER BY s.RollNumber) - 1) / 10) + 1 as RowNumber,
            ((ROW_NUMBER() OVER (ORDER BY s.RollNumber) - 1) % 10) + 1 as ColumnNumber,
            @Algorithm
        FROM Students s
        JOIN StudentSubjects ss ON s.StudentID = ss.StudentID
        JOIN Exams e ON ss.SubjectID = e.SubjectID
        WHERE e.ExamID = @ExamID AND s.EligibilityStatus = 1
        ORDER BY s.RollNumber;
    END
    ELSE IF @Algorithm = 'alternate'
    BEGIN
        -- Alternate arrangement logic
        WITH StudentCTE AS (
            SELECT 
                s.StudentID,
                ROW_NUMBER() OVER (ORDER BY s.RollNumber) as RowNum,
                COUNT(*) OVER () as TotalCount
            FROM Students s
            JOIN StudentSubjects ss ON s.StudentID = ss.StudentID
            JOIN Exams e ON ss.SubjectID = e.SubjectID
            WHERE e.ExamID = @ExamID AND s.EligibilityStatus = 1
        )
        INSERT INTO SeatingArrangements (ExamID, HallID, StudentID, SeatNumber, RowNumber, ColumnNumber, AlgorithmUsed)
        SELECT 
            @ExamID, @HallID, 
            CASE 
                WHEN RowNum <= TotalCount / 2 THEN 
                    (SELECT StudentID FROM StudentCTE WHERE RowNum = RowNum * 2 - 1)
                ELSE 
                    (SELECT StudentID FROM StudentCTE WHERE RowNum = (RowNum - TotalCount / 2) * 2)
            END as StudentID,
            RowNum as SeatNumber,
            ((RowNum - 1) / 10) + 1 as RowNumber,
            ((RowNum - 1) % 10) + 1 as ColumnNumber,
            @Algorithm
        FROM StudentCTE;
    END
    ELSE IF @Algorithm = 'random'
    BEGIN
        -- Random arrangement logic
        INSERT INTO SeatingArrangements (ExamID, HallID, StudentID, SeatNumber, RowNumber, ColumnNumber, AlgorithmUsed)
        SELECT 
            @ExamID, @HallID, s.StudentID,
            ROW_NUMBER() OVER (ORDER BY NEWID()) as SeatNumber,
            ((ROW_NUMBER() OVER (ORDER BY NEWID()) - 1) / 10) + 1 as RowNumber,
            ((ROW_NUMBER() OVER (ORDER BY NEWID()) - 1) % 10) + 1 as ColumnNumber,
            @Algorithm
        FROM Students s
        JOIN StudentSubjects ss ON s.StudentID = ss.StudentID
        JOIN Exams e ON ss.SubjectID = e.SubjectID
        WHERE e.ExamID = @ExamID AND s.EligibilityStatus = 1;
    END
    
    SELECT @@ROWCOUNT as StudentsArranged;
END
GO

-- Procedure to check exam conflicts
CREATE PROCEDURE sp_CheckExamConflicts
    @ExamDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ExamDate IS NULL
        SET @ExamDate = GETDATE();
    
    SELECT 
        e1.ExamID as Exam1_ID,
        e1.ExamName as Exam1_Name,
        e2.ExamID as Exam2_ID,
        e2.ExamName as Exam2_Name,
        e1.ExamDate,
        e1.StartTime as Exam1_Start,
        e1.EndTime as Exam1_End,
        e2.StartTime as Exam2_Start,
        e2.EndTime as Exam2_End,
        h1.HallName as Hall1_Name,
        h2.HallName as Hall2_Name,
        CASE 
            WHEN e1.HallID = e2.HallID THEN 'Same Hall Conflict'
            WHEN (e1.StartTime < e2.EndTime AND e1.EndTime > e2.StartTime) THEN 'Time Overlap'
            ELSE 'No Conflict'
        END as ConflictType
    FROM Exams e1
    JOIN Exams e2 ON e1.ExamID < e2.ExamID AND e1.ExamDate = e2.ExamDate
    JOIN ExamHalls h1 ON e1.HallID = h1.HallID
    JOIN ExamHalls h2 ON e2.HallID = h2.HallID
    WHERE e1.ExamDate = @ExamDate 
    AND ((e1.StartTime < e2.EndTime AND e1.EndTime > e2.StartTime) OR e1.HallID = e2.HallID)
    ORDER BY e1.StartTime;
END
GO

-- Procedure to get student statistics
CREATE PROCEDURE sp_GetStudentStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) as TotalStudents,
        SUM(CASE WHEN EligibilityStatus = 1 THEN 1 ELSE 0 END) as EligibleStudents,
        SUM(CASE WHEN Status = 'active' THEN 1 ELSE 0 END) as ActiveStudents,
        SUM(CASE WHEN Status = 'suspended' THEN 1 ELSE 0 END) as SuspendedStudents,
        SUM(CASE WHEN Status = 'inactive' THEN 1 ELSE 0 END) as InactiveStudents,
        AVG(AttendancePercentage) as AverageAttendance,
        MAX(AttendancePercentage) as HighestAttendance,
        MIN(AttendancePercentage) as LowestAttendance
    FROM Students;
END
GO

-- Procedure to get exam statistics
CREATE PROCEDURE sp_GetExamStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) as TotalExams,
        SUM(CASE WHEN Status = 'scheduled' THEN 1 ELSE 0 END) as ScheduledExams,
        SUM(CASE WHEN Status = 'in_progress' THEN 1 ELSE 0 END) as InProgressExams,
        SUM(CASE WHEN Status = 'completed' THEN 1 ELSE 0 END) as CompletedExams,
        SUM(CASE WHEN Status = 'cancelled' THEN 1 ELSE 0 END) as CancelledExams,
        COUNT(DISTINCT HallID) as HallsUsed,
        SUM(CASE WHEN ExamDate >= CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) as UpcomingExams
    FROM Exams;
END
GO

-- Create Triggers

-- Trigger to update eligibility when attendance or status changes
CREATE TRIGGER tr_UpdateStudentEligibility
ON Students
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(AttendancePercentage) OR UPDATE(Status)
    BEGIN
        UPDATE s
        SET EligibilityStatus = CASE 
            WHEN i.AttendancePercentage >= 75 AND i.Status = 'active' THEN 1
            ELSE 0
        END,
        UpdatedAt = GETDATE()
        FROM Students s
        JOIN inserted i ON s.StudentID = i.StudentID;
    END
END
GO

-- Trigger to prevent double booking of halls
CREATE TRIGGER tr_PreventHallDoubleBooking
ON Exams
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(HallID) OR UPDATE(ExamDate) OR UPDATE(StartTime) OR UPDATE(EndTime)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            JOIN Exams e ON i.HallID = e.HallID 
            WHERE i.ExamID <> e.ExamID 
            AND i.ExamDate = e.ExamDate
            AND (i.StartTime < e.EndTime AND i.EndTime > e.StartTime)
        )
        BEGIN
            RAISERROR('Hall is already booked for this time slot', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END
GO

-- Trigger to log exam status changes
CREATE TRIGGER tr_ExamStatusLog
ON Exams
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(Status)
    BEGIN
        -- In a real system, this would insert into an audit log table
        PRINT 'Exam status changed for ExamID: ' + CAST((SELECT ExamID FROM inserted) AS VARCHAR);
    END
END
GO

-- Add validation constraints for roll numbers
ALTER TABLE Students ADD CONSTRAINT CK_RollNumber_Format CHECK (RollNumber LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

-- Add validation constraints for phone numbers
ALTER TABLE Students ADD CONSTRAINT CK_Phone_Format CHECK (Phone LIKE '[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR Phone IS NULL);

-- Add validation constraints for email
ALTER TABLE Students ADD CONSTRAINT CK_Email_Format CHECK (Email LIKE '%@%.%' OR Email IS NULL);

-- Add validation constraints for names
ALTER TABLE Students ADD CONSTRAINT CK_FirstName_Format CHECK (FirstName NOT LIKE '%[^A-Z ]%' AND LEN(FirstName) >= 2 AND LEN(FirstName) <= 50);
ALTER TABLE Students ADD CONSTRAINT CK_LastName_Format CHECK (LastName NOT LIKE '%[^A-Z ]%' AND LEN(LastName) >= 2 AND LEN(LastName) <= 50);

-- Add validation constraints for attendance
ALTER TABLE Students ADD CONSTRAINT CK_Attendance_Range CHECK (AttendancePercentage >= 0 AND AttendancePercentage <= 100);
GO

-- Create Functions

-- Function to get exam duration based on type
CREATE FUNCTION fn_GetExamDuration (@ExamType VARCHAR(20))
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @Duration DECIMAL(4,2);
    
    IF @ExamType = 'midterm'
        SET @Duration = 1.5;
    ELSE IF @ExamType = 'interim'
        SET @Duration = 3.0;
    ELSE IF @ExamType = 'term'
        SET @Duration = 2.0;
    ELSE IF @ExamType = 'final'
        SET @Duration = 3.0;
    ELSE
        SET @Duration = 2.0;
    
    RETURN @Duration;
END
GO

-- Function to check if student is eligible for exam
CREATE FUNCTION fn_IsStudentEligible (@StudentID INT, @SubjectID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @IsEligible BIT;
    
    SELECT @IsEligible = CASE 
        WHEN s.AttendancePercentage >= 75 
        AND s.Status = 'active'
        AND EXISTS (SELECT 1 FROM StudentSubjects ss WHERE ss.StudentID = @StudentID AND ss.SubjectID = @SubjectID)
        THEN 1
        ELSE 0
    END
    FROM Students s
    WHERE s.StudentID = @StudentID;
    
    RETURN @IsEligible;
END
GO

-- Create Indexes for better performance
CREATE INDEX IX_Students_RollNumber ON Students(RollNumber);
CREATE INDEX IX_Students_DeptID ON Students(DeptID);
CREATE INDEX IX_Students_Status ON Students(Status);
CREATE INDEX IX_Students_Eligibility ON Students(EligibilityStatus);
CREATE INDEX IX_Exams_Date ON Exams(ExamDate);
CREATE INDEX IX_Exams_Status ON Exams(Status);
CREATE INDEX IX_Exams_Subject ON Exams(SubjectID);
CREATE INDEX IX_ExamHalls_Type ON ExamHalls(HallType);
CREATE INDEX IX_SeatingArrangements_Exam ON SeatingArrangements(ExamID);
CREATE INDEX IX_SeatingArrangements_Student ON SeatingArrangements(StudentID);
GO
PRINT 'IntelliSeat Database Schema created successfully!';
PRINT 'Sample data inserted successfully!';
PRINT 'Stored procedures, triggers, indexes, and functions created successfully!';
GO

-- Test the database with sample queries
/*
-- Test login
SELECT * FROM Users WHERE Username = 'admin' AND Password = 'admin123';

-- Get all eligible students
SELECT * FROM StudentEligibility WHERE IsEligible = 1;

-- Check for exam conflicts
EXEC sp_CheckExamConflicts '2024-03-15';

-- Generate seating arrangement for exam 1
EXEC sp_GenerateSeatingArrangement 1, 'sequential';

-- Get statistics
EXEC sp_GetStudentStatistics;
EXEC sp_GetExamStatistics;

-- View hall utilization
SELECT * FROM HallUtilization;
*/
