(function () {
  const FIRST = [
    "Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan", "Krishna", "Ishaan",
    "Ananya", "Diya", "Priya", "Isha", "Kavya", "Saanvi", "Aadhya", "Kiara", "Myra", "Pari",
    "Rohan", "Kabir", "Atharv", "Dhruv", "Yash", "Dev", "Rudra", "Aryan", "Advik", "Pranav",
    "Neha", "Pooja", "Sneha", "Riya", "Shreya", "Tanvi", "Nisha", "Meera", "Anjali", "Kritika",
    "Raj", "Amit", "Suresh", "Vikram", "Manoj", "Ravi", "Deepak", "Nitin", "Sanjay", "Ashok",
    "Lakshmi", "Sunita", "Geeta", "Rekha", "Pallavi", "Swati", "Divya", "Bhavna", "Jyoti", "Kiran",
    "Harish", "Gaurav", "Naveen", "Karthik", "Siddharth", "Harsh", "Varun", "Akash", "Rahul", "Mohit"
  ];
  const LAST = [
    "Sharma", "Verma", "Patel", "Kumar", "Singh", "Gupta", "Reddy", "Nair", "Iyer", "Menon",
    "Joshi", "Rao", "Mehta", "Shah", "Agarwal", "Malhotra", "Chopra", "Bansal", "Kapoor", "Das",
    "Mishra", "Pandey", "Yadav", "Thakur", "Kulkarni", "Desai", "Saxena", "Tiwari", "Dubey", "Bhat"
  ];
  const SUBJECTS = [
    "Data Structures", "DBMS", "Operating Systems", "Computer Networks", "Design and Analysis of Algorithms",
    "Digital Electronics", "Thermodynamics", "Structural Analysis", "Web Technology", "Discrete Mathematics"
  ];
  const DEPARTMENTS = ["CSE", "ECE", "ME", "CE", "IT"];
  const HALLS = ["Hall A", "Hall B", "Hall C"];

  function buildStudents() {
    const list = [];
    for (let i = 1; i <= 100; i++) {
      const fname = FIRST[(i - 1) % FIRST.length];
      const lname = LAST[Math.floor((i - 1) / FIRST.length) % LAST.length];
      const shiftId = i % 2 === 0 ? 2 : 1;
      list.push({
        roll_no: 240122100 + i,
        name: fname + " " + lname,
        subject: SUBJECTS[i % SUBJECTS.length],
        department: DEPARTMENTS[i % DEPARTMENTS.length],
        semester: (i % 6) + 3,
        shift_id: shiftId,
        shift_name: shiftId === 1 ? "Morning" : "Afternoon",
        default_hall: HALLS[Math.floor((i - 1) / 34) % HALLS.length]
      });
    }
    return list;
  }

  const EMBEDDED_STUDENTS = buildStudents();

  const DEFAULT_EXAMS = [
    { exam_id: 1, subject: "Data Structures", department: "CSE", semester: 5, exam_date: "2026-06-10" },
    { exam_id: 2, subject: "Database Management Systems", department: "CSE", semester: 5, exam_date: "2026-06-12" },
    { exam_id: 3, subject: "Operating Systems", department: "ECE", semester: 6, exam_date: "2026-06-15" }
  ];

  const DEFAULT_SHIFTS = [
    { shift_id: 1, shift_name: "Morning", start_time: "09:00", end_time: "12:00" },
    { shift_id: 2, shift_name: "Afternoon", start_time: "14:00", end_time: "17:00" }
  ];

  const DEFAULT_HALLS = [
    { hall_name: "Hall A", capacity: 40 },
    { hall_name: "Hall B", capacity: 40 },
    { hall_name: "Hall C", capacity: 20 }
  ];

  const KEYS = {
    extraStudents: "exam_extra_students",
    exams: "exam_exams",
    shifts: "exam_shifts",
    seating: "exam_seating",
    session: "exam_session"
  };

  function readJson(key, fallback) {
    try {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw) : fallback;
    } catch {
      return fallback;
    }
  }

  function writeJson(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  function initDefaults() {
    if (!localStorage.getItem(KEYS.exams)) writeJson(KEYS.exams, DEFAULT_EXAMS);
    if (!localStorage.getItem(KEYS.shifts)) writeJson(KEYS.shifts, DEFAULT_SHIFTS);
    if (!localStorage.getItem(KEYS.seating)) writeJson(KEYS.seating, []);
  }

  initDefaults();

  window.DataStore = {
    getStudents() {
      const extra = readJson(KEYS.extraStudents, []);
      const map = new Map();
      EMBEDDED_STUDENTS.forEach((s) => map.set(s.roll_no, { ...s }));
      extra.forEach((s) => map.set(s.roll_no, { ...s }));
      return Array.from(map.values()).sort((a, b) => a.roll_no - b.roll_no);
    },

    addStudent(student) {
      if (EMBEDDED_STUDENTS.some((s) => s.roll_no === student.roll_no)) {
        return { ok: false, error: "Roll number already exists." };
      }
      const extra = readJson(KEYS.extraStudents, []);
      if (extra.some((s) => s.roll_no === student.roll_no)) {
        return { ok: false, error: "Roll number already exists." };
      }
      extra.push(student);
      writeJson(KEYS.extraStudents, extra);
      return { ok: true };
    },

    getExams() {
      return readJson(KEYS.exams, DEFAULT_EXAMS);
    },

    addExam(exam) {
      const exams = this.getExams();
      if (exams.some((e) => e.exam_id === exam.exam_id)) {
        return { ok: false, error: "Exam ID already exists." };
      }
      exams.push(exam);
      writeJson(KEYS.exams, exams);
      return { ok: true };
    },

    getShifts() {
      return readJson(KEYS.shifts, DEFAULT_SHIFTS);
    },

    addShift(shift) {
      const shifts = this.getShifts();
      if (shifts.some((s) => s.shift_id === shift.shift_id)) {
        return { ok: false, error: "Shift ID already exists." };
      }
      shifts.push(shift);
      writeJson(KEYS.shifts, shifts);
      return { ok: true };
    },

    getHalls() {
      return DEFAULT_HALLS;
    },

    getSeating(examId) {
      let all = readJson(KEYS.seating, []);
      if (examId) all = all.filter((s) => String(s.exam_id) === String(examId));
      return all;
    },

    generateSeating(examId, shiftId) {
      const students = this.getStudents();
      const halls = this.getHalls();
      let all = readJson(KEYS.seating, []).filter((s) => s.exam_id !== examId);
      const seating = [];
      let idx = 0;

      for (const hall of halls) {
        for (let seat = 1; seat <= hall.capacity; seat++) {
          if (idx >= students.length) break;
          const st = students[idx++];
          seating.push({
            exam_id: examId,
            hall_name: hall.hall_name,
            seat_no: seat,
            student_roll_no: st.roll_no,
            name: st.name,
            department: st.department,
            subject: st.subject,
            shift_id: shiftId || st.shift_id,
            shift_name: shiftId === 2 ? "Afternoon" : shiftId === 1 ? "Morning" : st.shift_name
          });
        }
        if (idx >= students.length) break;
      }

      writeJson(KEYS.seating, all.concat(seating));
      return {
        ok: true,
        message: "Seating plan generated for " + seating.length + " students.",
        seating
      };
    },

    getReport(examId) {
      return this.getSeating(examId).map((s) => ({
        hall_name: s.hall_name,
        seat_no: s.seat_no,
        student_roll_no: s.student_roll_no,
        name: s.name,
        department: s.department,
        subject: s.subject,
        shift_name: s.shift_name || "-"
      }));
    },

    login(username, password) {
      if (username === "admin" && password === "admin123") {
        writeJson(KEYS.session, { username, at: Date.now() });
        return { ok: true };
      }
      return { ok: false, error: "Invalid username or password." };
    },

    logout() {
      localStorage.removeItem(KEYS.session);
    },

    isAuthenticated() {
      return !!readJson(KEYS.session, null);
    },

    getUsername() {
      const s = readJson(KEYS.session, null);
      return s ? s.username : "";
    }
  };
})();
