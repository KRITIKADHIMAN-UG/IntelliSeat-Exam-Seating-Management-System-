// Global Variables
let currentUser = null;
let students = [];
let exams = [];
let seatingArrangements = [];
let selectedExam = null;

// Initialize Application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Load sample data
    loadSampleData();
    
    // Setup event listeners
    setupEventListeners();
    
    // Check if user is logged in
    checkLoginStatus();
}

function loadSampleData() {
    // Sample students with authentic Indian names
    students = [
        {
            rollNumber: 'CS2024001',
            firstName: 'Rahul',
            lastName: 'Sharma',
            department: 'CS',
            year: 3,
            semester: 5,
            status: 'active',
            attendance: 85.5,
            subjects: ['Data Structures', 'Algorithms', 'Database Systems'],
            email: 'rahul.sharma@college.edu',
            phone: '9876543210',
            eligible: true
        },
        {
            rollNumber: 'EC2024002',
            firstName: 'Priya',
            lastName: 'Patel',
            department: 'EC',
            year: 3,
            semester: 5,
            status: 'active',
            attendance: 78.0,
            subjects: ['Digital Electronics', 'Circuits', 'Signals'],
            email: 'priya.patel@college.edu',
            phone: '9876543211',
            eligible: true
        },
        {
            rollNumber: 'ME2024003',
            firstName: 'Amit',
            lastName: 'Kumar',
            department: 'ME',
            year: 2,
            semester: 3,
            status: 'suspended',
            attendance: 45.0,
            subjects: ['Thermodynamics', 'Mechanics', 'Manufacturing'],
            email: 'amit.kumar@college.edu',
            phone: '9876543212',
            eligible: false
        },
        {
            rollNumber: 'CE2024004',
            firstName: 'Anjali',
            lastName: 'Gupta',
            department: 'CE',
            year: 2,
            semester: 3,
            status: 'active',
            attendance: 92.5,
            subjects: ['Structures', 'Materials', 'Surveying'],
            email: 'anjali.gupta@college.edu',
            phone: '9876543213',
            eligible: true
        },
        {
            rollNumber: 'EE2024005',
            firstName: 'Vikram',
            lastName: 'Singh',
            department: 'EE',
            year: 4,
            semester: 7,
            status: 'active',
            attendance: 88.0,
            subjects: ['Power Systems', 'Machines', 'Control Systems'],
            email: 'vikram.singh@college.edu',
            phone: '9876543214',
            eligible: true
        },
        {
            rollNumber: 'IT2024006',
            firstName: 'Neha',
            lastName: 'Verma',
            department: 'IT',
            year: 3,
            semester: 5,
            status: 'active',
            attendance: 76.5,
            subjects: ['Web Technologies', 'Cloud Computing', 'Cyber Security'],
            email: 'neha.verma@college.edu',
            phone: '9876543215',
            eligible: true
        },
        {
            rollNumber: 'AE2024007',
            firstName: 'Rohit',
            lastName: 'Jain',
            department: 'AE',
            year: 4,
            semester: 7,
            status: 'active',
            attendance: 81.0,
            subjects: ['Aerodynamics', 'Propulsion', 'Structures'],
            email: 'rohit.jain@college.edu',
            phone: '9876543216',
            eligible: true
        },
        {
            rollNumber: 'CH2024008',
            firstName: 'Kavita',
            lastName: 'Reddy',
            department: 'CH',
            year: 2,
            semester: 3,
            status: 'inactive',
            attendance: 65.0,
            subjects: ['Chemical Engineering', 'Thermodynamics', 'Process Design'],
            email: 'kavita.reddy@college.edu',
            phone: '9876543217',
            eligible: false
        },
        {
            rollNumber: 'BT2024009',
            firstName: 'Suresh',
            lastName: 'Iyer',
            department: 'BT',
            year: 3,
            semester: 5,
            status: 'active',
            attendance: 79.5,
            subjects: ['Biotechnology', 'Genetics', 'Molecular Biology'],
            email: 'suresh.iyer@college.edu',
            phone: '9876543218',
            eligible: true
        },
        {
            rollNumber: 'PH2024010',
            firstName: 'Deepika',
            lastName: 'Nair',
            department: 'PH',
            year: 1,
            semester: 1,
            status: 'active',
            attendance: 94.0,
            subjects: ['Physics', 'Mathematics', 'Chemistry'],
            email: 'deepika.nair@college.edu',
            phone: '9876543219',
            eligible: true
        },
        {
            rollNumber: 'MA2024011',
            firstName: 'Arjun',
            lastName: 'Menon',
            department: 'MA',
            year: 2,
            semester: 3,
            status: 'active',
            attendance: 87.5,
            subjects: ['Mathematics', 'Statistics', 'Computer Science'],
            email: 'arjun.menon@college.edu',
            phone: '9876543220',
            eligible: true
        }
    ];
    
    // Sample exams
    exams = [
        {
            id: 1,
            name: 'Midterm Data Structures',
            type: 'midterm',
            subject: 'Data Structures',
            date: '2024-03-15',
            time: '09:00',
            duration: 1.5,
            hallType: 'LT',
            status: 'scheduled'
        },
        {
            id: 2,
            name: 'Interim Algorithms',
            type: 'interim',
            subject: 'Algorithms',
            date: '2024-03-20',
            time: '14:00',
            duration: 3,
            hallType: 'CR',
            status: 'scheduled'
        }
    ];
    
    updateDashboardStats();
}

function setupEventListeners() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', handleNavigation);
    });
    
    // Logout
    document.getElementById('logoutBtn').addEventListener('click', handleLogout);
    
    // Student Management
    document.getElementById('addStudentBtn').addEventListener('click', showStudentForm);
    document.getElementById('bulkImportBtn').addEventListener('click', showBulkImport);
    document.getElementById('filterStudentsBtn').addEventListener('click', filterStudents);
    document.getElementById('addStudentForm').addEventListener('submit', handleAddStudent);
    document.getElementById('cancelStudentBtn').addEventListener('click', hideStudentForm);
    document.getElementById('processBulkBtn').addEventListener('click', processBulkStudents);
    document.getElementById('cancelBulkBtn').addEventListener('click', hideBulkImport);
    
    // Exam Management
    document.getElementById('addExamBtn').addEventListener('click', showExamForm);
    document.getElementById('addExamForm').addEventListener('submit', handleAddExam);
    document.getElementById('cancelExamBtn').addEventListener('click', hideExamForm);
    
    // Seating Arrangement
    document.getElementById('generateSeatingBtn').addEventListener('click', generateSeating);
    document.getElementById('printSeatingBtn').addEventListener('click', printSeating);
    document.getElementById('processSeatingDataBtn').addEventListener('click', processSeatingData);
    
    // Shift Management
    document.getElementById('checkConflictsBtn').addEventListener('click', checkConflicts);
    
    // Exam type change to update duration
    document.getElementById('examType').addEventListener('change', updateExamDuration);
}

// Login Functions
function handleLogin(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    // Simple authentication (in real app, this would be server-side)
    if (username === 'admin' && password === 'admin123') {
        currentUser = { username: username, name: 'System Administrator' };
        showDashboard();
        showNotification('Login successful!', 'success');
    } else {
        showNotification('Invalid credentials. Please try again.', 'error');
    }
}

function checkLoginStatus() {
    if (currentUser) {
        showDashboard();
    } else {
        showLoginPage();
    }
}

function showLoginPage() {
    document.getElementById('loginPage').style.display = 'flex';
    document.getElementById('dashboardPage').style.display = 'none';
}

function showDashboard() {
    document.getElementById('loginPage').style.display = 'none';
    document.getElementById('dashboardPage').style.display = 'flex';
    document.getElementById('adminName').textContent = currentUser.name;
    
    // Load initial data
    loadStudentsTable();
    loadExamsTable();
    loadExamSelectOptions();
}

function handleLogout() {
    currentUser = null;
    showLoginPage();
    showNotification('Logged out successfully!', 'success');
}

// Navigation Functions
function handleNavigation(e) {
    e.preventDefault();
    
    const targetModule = e.currentTarget.dataset.module;
    
    // Update active navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    e.currentTarget.classList.add('active');
    
    // Show corresponding module
    document.querySelectorAll('.module-content').forEach(module => {
        module.classList.remove('active');
    });
    document.getElementById(targetModule + 'Module').classList.add('active');
}

// Student Management Functions
function showStudentForm() {
    document.getElementById('studentForm').style.display = 'block';
    document.getElementById('bulkImport').style.display = 'none';
}

function hideStudentForm() {
    document.getElementById('studentForm').style.display = 'none';
    document.getElementById('addStudentForm').reset();
}

function showBulkImport() {
    document.getElementById('bulkImport').style.display = 'block';
    document.getElementById('studentForm').style.display = 'none';
}

function hideBulkImport() {
    document.getElementById('bulkImport').style.display = 'none';
    document.getElementById('bulkStudentData').value = '';
}

function handleAddStudent(e) {
    e.preventDefault();
    
    // Validate form data
    if (!validateStudentForm()) {
        return;
    }
    
    // Get selected subjects
    const subjectSelect = document.getElementById('studentSubjects');
    const selectedSubjects = Array.from(subjectSelect.selectedOptions).map(option => option.value);
    
    const student = {
        rollNumber: document.getElementById('studentRoll').value.toUpperCase(),
        firstName: document.getElementById('studentFirstName').value,
        lastName: document.getElementById('studentLastName').value,
        department: document.getElementById('studentDept').value,
        year: parseInt(document.getElementById('studentYear').value),
        semester: parseInt(document.getElementById('studentSemester').value),
        status: document.getElementById('studentStatus').value,
        attendance: parseFloat(document.getElementById('studentAttendance').value),
        subjects: selectedSubjects,
        email: document.getElementById('studentEmail').value,
        phone: document.getElementById('studentPhone').value,
        eligible: false
    };
    
    // Check eligibility
    student.eligible = student.attendance >= 75 && student.status === 'active';
    
    students.push(student);
    loadStudentsTable();
    updateDashboardStats();
    hideStudentForm();
    showNotification('Student added successfully!', 'success');
}

function processBulkStudents() {
    const bulkData = document.getElementById('bulkStudentData').value.trim();
    if (!bulkData) {
        showNotification('Please enter student data', 'error');
        return;
    }
    
    const lines = bulkData.split('\n');
    let addedCount = 0;
    let errorCount = 0;
    let errorMessages = [];
    
    lines.forEach((line, index) => {
        const parts = line.split(',').map(p => p.trim());
        if (parts.length >= 10) {
            try {
                // Validate each field
                const rollNumber = validateRollNumber(parts[0]);
                const firstName = validateName(parts[1], 'First Name');
                const lastName = validateName(parts[2], 'Last Name');
                const department = validateDepartment(parts[3]);
                const year = validateYear(parts[4]);
                const semester = validateSemester(parts[5]);
                const status = validateStatus(parts[6]);
                const attendance = validateAttendance(parts[7]);
                const email = validateEmail(parts[8]);
                const phone = validatePhone(parts[9]);
                const subjects = parts[10] ? parts[10].split(';').map(s => s.trim()) : [];
                
                const student = {
                    rollNumber: rollNumber,
                    firstName: firstName,
                    lastName: lastName,
                    department: department,
                    year: year,
                    semester: semester,
                    status: status,
                    attendance: attendance,
                    subjects: subjects,
                    email: email,
                    phone: phone,
                    eligible: attendance >= 75 && status === 'active'
                };
                
                students.push(student);
                addedCount++;
            } catch (error) {
                errorCount++;
                errorMessages.push(`Line ${index + 1}: ${error.message}`);
            }
        } else {
            errorCount++;
            errorMessages.push(`Line ${index + 1}: Insufficient data columns`);
        }
    });
    
    loadStudentsTable();
    updateDashboardStats();
    hideBulkImport();
    
    let message = `${addedCount} students added successfully!`;
    if (errorCount > 0) {
        message += ` ${errorCount} errors found.`;
        console.error('Bulk import errors:', errorMessages);
    }
    showNotification(message, errorCount > 0 ? 'warning' : 'success');
}

function filterStudents() {
    const minAttendance = parseInt(document.getElementById('attendanceFilter').value) || 0;
    const statusFilter = document.getElementById('statusFilter').value;
    
    const filteredStudents = students.filter(student => {
        const attendanceMatch = student.attendance >= minAttendance;
        const statusMatch = !statusFilter || student.status === statusFilter;
        return attendanceMatch && statusMatch;
    });
    
    loadStudentsTable(filteredStudents);
}

function loadStudentsTable(studentsToLoad = students) {
    const tbody = document.getElementById('studentsTableBody');
    tbody.innerHTML = '';
    
    studentsToLoad.forEach(student => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${student.rollNumber}</td>
            <td>${student.firstName}</td>
            <td>${student.lastName}</td>
            <td>${student.department}</td>
            <td>${student.year}</td>
            <td>${student.semester}</td>
            <td><span class="status-badge status-${student.status}">${student.status}</span></td>
            <td>${student.attendance}%</td>
            <td>${student.subjects.join(', ')}</td>
            <td>${student.email || '-'}</td>
            <td>${student.phone || '-'}</td>
            <td><span class="eligible-${student.eligible ? 'yes' : 'no'}">${student.eligible ? 'Yes' : 'No'}</span></td>
            <td>
                <button class="action-btn edit-btn" onclick="editStudent('${student.rollNumber}')">Edit</button>
                <button class="action-btn delete-btn" onclick="deleteStudent('${student.rollNumber}')">Delete</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function editStudent(rollNumber) {
    const student = students.find(s => s.rollNumber === rollNumber);
    if (student) {
        // Populate form with student data
        document.getElementById('studentRoll').value = student.rollNumber;
        document.getElementById('studentFirstName').value = student.firstName;
        document.getElementById('studentLastName').value = student.lastName;
        document.getElementById('studentDept').value = student.department;
        document.getElementById('studentYear').value = student.year;
        document.getElementById('studentSemester').value = student.semester;
        document.getElementById('studentStatus').value = student.status;
        document.getElementById('studentAttendance').value = student.attendance;
        document.getElementById('studentEmail').value = student.email || '';
        document.getElementById('studentPhone').value = student.phone || '';
        
        // Set selected subjects
        const subjectSelect = document.getElementById('studentSubjects');
        Array.from(subjectSelect.options).forEach(option => {
            option.selected = student.subjects.includes(option.value);
        });
        
        showStudentForm();
    }
}

function deleteStudent(rollNumber) {
    if (confirm('Are you sure you want to delete this student?')) {
        students = students.filter(s => s.rollNumber !== rollNumber);
        loadStudentsTable();
        updateDashboardStats();
        showNotification('Student deleted successfully!', 'success');
    }
}

// Exam Management Functions
function showExamForm() {
    document.getElementById('examForm').style.display = 'block';
}

function hideExamForm() {
    document.getElementById('examForm').style.display = 'none';
    document.getElementById('addExamForm').reset();
}

function updateExamDuration() {
    const examType = document.getElementById('examType').value;
    const durationField = document.getElementById('examTime');
    
    if (examType === 'midterm') {
        // Duration will be 1.5 hours
        durationField.min = '01:30';
        durationField.max = '10:30';
    } else if (examType === 'interim') {
        // Duration will be 3 hours
        durationField.min = '03:00';
        durationField.max = '12:00';
    }
}

function handleAddExam(e) {
    e.preventDefault();
    
    const examType = document.getElementById('examType').value;
    const duration = examType === 'midterm' ? 1.5 : (examType === 'interim' ? 3 : 2);
    
    const exam = {
        id: exams.length + 1,
        name: document.getElementById('examName').value,
        type: examType,
        subject: document.getElementById('examSubject').value,
        date: document.getElementById('examDate').value,
        time: document.getElementById('examTime').value,
        duration: duration,
        hallType: document.getElementById('examHallType').value,
        status: 'scheduled'
    };
    
    exams.push(exam);
    loadExamsTable();
    loadExamSelectOptions();
    updateDashboardStats();
    hideExamForm();
    showNotification('Exam created successfully!', 'success');
}

function loadExamsTable() {
    const tbody = document.getElementById('examsTableBody');
    tbody.innerHTML = '';
    
    exams.forEach(exam => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${exam.name}</td>
            <td>${exam.type.charAt(0).toUpperCase() + exam.type.slice(1)}</td>
            <td>${exam.subject}</td>
            <td>${exam.date}</td>
            <td>${exam.time}</td>
            <td>${exam.duration} hours</td>
            <td>${exam.hallType}</td>
            <td><span class="status-badge status-active">${exam.status}</span></td>
            <td>
                <button class="action-btn edit-btn" onclick="editExam(${exam.id})">Edit</button>
                <button class="action-btn delete-btn" onclick="deleteExam(${exam.id})">Delete</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function editExam(examId) {
    const exam = exams.find(e => e.id === examId);
    if (exam) {
        document.getElementById('examName').value = exam.name;
        document.getElementById('examType').value = exam.type;
        document.getElementById('examSubject').value = exam.subject;
        document.getElementById('examDate').value = exam.date;
        document.getElementById('examTime').value = exam.time;
        document.getElementById('examHallType').value = exam.hallType;
        
        showExamForm();
    }
}

function deleteExam(examId) {
    if (confirm('Are you sure you want to delete this exam?')) {
        exams = exams.filter(e => e.id !== examId);
        loadExamsTable();
        loadExamSelectOptions();
        updateDashboardStats();
        showNotification('Exam deleted successfully!', 'success');
    }
}

// Seating Arrangement Functions
function loadExamSelectOptions() {
    const select = document.getElementById('seatingExam');
    select.innerHTML = '<option value="">Select Exam</option>';
    
    exams.forEach(exam => {
        const option = document.createElement('option');
        option.value = exam.id;
        option.textContent = `${exam.name} - ${exam.date}`;
        select.appendChild(option);
    });
}

function generateSeating() {
    const examId = document.getElementById('seatingExam').value;
    const algorithm = document.getElementById('seatingAlgorithm').value;
    
    if (!examId) {
        showNotification('Please select an exam', 'error');
        return;
    }
    
    selectedExam = exams.find(e => e.id == examId);
    const eligibleStudents = students.filter(s => s.eligible);
    
    // Generate seating arrangement using backend algorithm
    const arrangement = generateSeatingArrangement(eligibleStudents, selectedExam, algorithm);
    
    displaySeatingArrangement(arrangement);
    showNotification('Seating arrangement generated!', 'success');
}

function generateSeatingArrangement(students, exam, algorithm) {
    // This would typically call the C++ backend
    // For now, we'll implement a simple algorithm in JavaScript
    
    const hallCapacity = exam.hallType === 'LT' ? 120 : 60;
    const numberOfHalls = Math.ceil(students.length / hallCapacity);
    
    let arrangedStudents = [...students];
    
    // Apply algorithm
    switch (algorithm) {
        case 'sequential':
            // Already in sequential order
            break;
        case 'alternate':
            arrangedStudents = alternateStudents(students);
            break;
        case 'random':
            arrangedStudents = shuffleArray([...students]);
            break;
    }
    
    // Create halls
    const halls = [];
    for (let i = 0; i < numberOfHalls; i++) {
        const startIndex = i * hallCapacity;
        const endIndex = Math.min(startIndex + hallCapacity, arrangedStudents.length);
        const hallStudents = arrangedStudents.slice(startIndex, endIndex);
        
        halls.push({
            name: `${exam.hallType}-${i + 1}`,
            capacity: hallCapacity,
            students: hallStudents
        });
    }
    
    return halls;
}

function alternateStudents(students) {
    const alternated = [];
    const mid = Math.floor(students.length / 2);
    
    for (let i = 0; i < mid; i++) {
        alternated.push(students[i]);
        alternated.push(students[mid + i]);
    }
    
    if (students.length % 2 !== 0) {
        alternated.push(students[students.length - 1]);
    }
    
    return alternated;
}

function shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

function displaySeatingArrangement(arrangement) {
    const grid = document.getElementById('seatingGrid');
    grid.innerHTML = '';
    
    arrangement.forEach(hall => {
        const hallDiv = document.createElement('div');
        hallDiv.className = 'hall-seating';
        
        const title = document.createElement('div');
        title.className = 'hall-title';
        title.textContent = `${hall.name} (${hall.students.length}/${hall.capacity})`;
        hallDiv.appendChild(title);
        
        // Create seating layout (simplified grid)
        const rows = Math.ceil(hall.capacity / 10);
        for (let row = 0; row < rows; row++) {
            const seatRow = document.createElement('div');
            seatRow.className = 'seat-row';
            
            for (let col = 0; col < 10; col++) {
                const seatIndex = row * 10 + col;
                const seat = document.createElement('div');
                seat.className = 'seat';
                
                if (seatIndex < hall.students.length) {
                    seat.className += ' occupied';
                    seat.textContent = hall.students[seatIndex].rollNumber;
                    seat.title = hall.students[seatIndex].name;
                } else {
                    seat.className += ' empty';
                }
                
                seatRow.appendChild(seat);
            }
            
            hallDiv.appendChild(seatRow);
        }
        
        grid.appendChild(hallDiv);
    });
}

function processSeatingData() {
    const bulkData = document.getElementById('bulkSeatingData').value.trim();
    if (!bulkData) {
        showNotification('Please enter student data', 'error');
        return;
    }
    
    // Process bulk data and generate seating
    showNotification('Student data processed. Click "Generate Seating" to create arrangement.', 'success');
}

function printSeating() {
    if (!selectedExam) {
        showNotification('Please generate seating arrangement first', 'error');
        return;
    }
    
    window.print();
    showNotification('Print dialog opened', 'success');
}

// Shift Management Functions
function checkConflicts() {
    const conflicts = [];
    
    // Check for scheduling conflicts
    for (let i = 0; i < exams.length; i++) {
        for (let j = i + 1; j < exams.length; j++) {
            if (exams[i].date === exams[j].date) {
                const conflict = checkTimeConflict(exams[i], exams[j]);
                if (conflict) {
                    conflicts.push(conflict);
                }
            }
        }
    }
    
    displayConflicts(conflicts);
    loadShiftsTable();
}

function checkTimeConflict(exam1, exam2) {
    const start1 = parseTime(exam1.time);
    const end1 = addHours(start1, exam1.duration);
    const start2 = parseTime(exam2.time);
    const end2 = addHours(start2, exam2.duration);
    
    if ((start1 < end2 && end1 > start2)) {
        return {
            exam1: exam1.name,
            exam2: exam2.name,
            date: exam1.date,
            time: `${exam1.time} - ${formatTime(end1)}`,
            issue: 'Time overlap'
        };
    }
    
    return null;
}

function parseTime(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return new Date(2000, 0, 1, hours, minutes);
}

function addHours(date, hours) {
    const result = new Date(date);
    result.setHours(result.getHours() + hours);
    return result;
}

function formatTime(date) {
    return date.toTimeString().slice(0, 5);
}

function displayConflicts(conflicts) {
    const conflictsList = document.getElementById('conflictsList');
    conflictsList.innerHTML = '';
    
    if (conflicts.length === 0) {
        conflictsList.innerHTML = '<p style="color: #4caf50; text-align: center;">No scheduling conflicts found!</p>';
    } else {
        conflicts.forEach(conflict => {
            const conflictDiv = document.createElement('div');
            conflictDiv.className = 'conflict-item';
            conflictDiv.innerHTML = `
                <strong>Conflict:</strong> ${conflict.exam1} and ${conflict.exam2}<br>
                <strong>Date:</strong> ${conflict.date}<br>
                <strong>Time:</strong> ${conflict.time}<br>
                <strong>Issue:</strong> ${conflict.issue}
            `;
            conflictsList.appendChild(conflictDiv);
        });
    }
}

function loadShiftsTable() {
    const tbody = document.getElementById('shiftsTableBody');
    tbody.innerHTML = '';
    
    exams.forEach(exam => {
        const startTime = parseTime(exam.time);
        const endTime = addHours(startTime, exam.duration);
        
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${exam.name}</td>
            <td>${exam.date}</td>
            <td>${exam.time}</td>
            <td>${formatTime(endTime)}</td>
            <td>${exam.hallType}-1</td>
            <td>${exam.hallType}</td>
            <td><span class="status-badge status-active">${exam.status}</span></td>
            <td>None</td>
        `;
        tbody.appendChild(row);
    });
}

// Dashboard Functions
function updateDashboardStats() {
    document.getElementById('totalStudents').textContent = students.length;
    document.getElementById('totalExams').textContent = exams.length;
    document.getElementById('totalHalls').textContent = '5'; // Fixed number of halls
    
    const upcomingExams = exams.filter(exam => {
        const examDate = new Date(exam.date);
        const today = new Date();
        return examDate >= today;
    }).length;
    
    document.getElementById('upcomingExams').textContent = upcomingExams;
}

// Notification Functions
function showNotification(message, type = 'success') {
    const container = document.getElementById('notificationContainer');
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    container.appendChild(notification);
    
    // Auto-remove after 3 seconds
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Validation Functions
function validateStudentForm() {
    const rollNumber = document.getElementById('studentRoll').value;
    const firstName = document.getElementById('studentFirstName').value;
    const lastName = document.getElementById('studentLastName').value;
    const department = document.getElementById('studentDept').value;
    const year = document.getElementById('studentYear').value;
    const semester = document.getElementById('studentSemester').value;
    const status = document.getElementById('studentStatus').value;
    const attendance = document.getElementById('studentAttendance').value;
    const email = document.getElementById('studentEmail').value;
    const phone = document.getElementById('studentPhone').value;
    const subjects = Array.from(document.getElementById('studentSubjects').selectedOptions);
    
    try {
        validateRollNumber(rollNumber);
        validateName(firstName, 'First Name');
        validateName(lastName, 'Last Name');
        validateDepartment(department);
        validateYear(year);
        validateSemester(semester);
        validateStatus(status);
        validateAttendance(attendance);
        if (email) validateEmail(email);
        if (phone) validatePhone(phone);
        if (subjects.length === 0) throw new Error('Please select at least one subject');
        return true;
    } catch (error) {
        showNotification(error.message, 'error');
        return false;
    }
}

function validateRollNumber(rollNumber) {
    const pattern = /^[A-Z]{2}[0-9]{7}$/;
    if (!pattern.test(rollNumber.toUpperCase())) {
        throw new Error('Roll number must be in format: DEPTYYYYNNN (e.g., CS2024001)');
    }
    return rollNumber.toUpperCase();
}

function validateName(name, fieldName) {
    const pattern = /^[A-Za-z\s]{2,50}$/;
    if (!pattern.test(name.trim())) {
        throw new Error(`${fieldName} must contain only alphabetic characters (2-50 characters)`);
    }
    return name.trim();
}

function validateDepartment(department) {
    const validDepts = ['CS', 'EC', 'ME', 'CE', 'EE', 'IT', 'AE', 'CH', 'BT', 'PH', 'MA'];
    if (!validDepts.includes(department)) {
        throw new Error('Please select a valid department');
    }
    return department;
}

function validateYear(year) {
    const yearNum = parseInt(year);
    if (isNaN(yearNum) || yearNum < 1 || yearNum > 4) {
        throw new Error('Year must be between 1 and 4');
    }
    return yearNum;
}

function validateSemester(semester) {
    const semNum = parseInt(semester);
    if (isNaN(semNum) || semNum < 1 || semNum > 8) {
        throw new Error('Semester must be between 1 and 8');
    }
    return semNum;
}

function validateStatus(status) {
    const validStatuses = ['active', 'suspended', 'inactive'];
    if (!validStatuses.includes(status)) {
        throw new Error('Please select a valid status');
    }
    return status;
}

function validateAttendance(attendance) {
    const att = parseFloat(attendance);
    if (isNaN(att) || att < 0 || att > 100) {
        throw new Error('Attendance must be between 0 and 100');
    }
    return att;
}

function validateEmail(email) {
    const pattern = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i;
    if (!pattern.test(email)) {
        throw new Error('Please enter a valid email address');
    }
    return email;
}

function validatePhone(phone) {
    const pattern = /^[6-9][0-9]{9}$/;
    if (!pattern.test(phone)) {
        throw new Error('Phone number must be 10 digits starting with 6, 7, 8, or 9');
    }
    return phone;
}

// Utility Functions
function formatDate(date) {
    return new Date(date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatDuration(hours) {
    return hours === 1.5 ? '1.5 hours' : `${hours} hours`;
}
