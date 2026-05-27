function clearTable(id) {
  const body = document.getElementById(id);
  if (body) body.innerHTML = "";
}

function addTableRow(id, cells) {
  const body = document.getElementById(id);
  if (!body) return;
  const tr = document.createElement("tr");
  cells.forEach((c) => {
    const td = document.createElement("td");
    td.textContent = c ?? "";
    tr.appendChild(td);
  });
  body.appendChild(tr);
}

function renderStudentTable() {
  const students = DataStore.getStudents();
  clearTable("studentTableBody");
  students.forEach((s) => {
    addTableRow("studentTableBody", [
      s.name,
      s.roll_no,
      s.subject,
      s.department,
      s.semester,
      s.shift_name || "-",
      s.default_hall || "-"
    ]);
  });
  const countEl = document.getElementById("studentCount");
  if (countEl) countEl.textContent = students.length;
  return students;
}

function initStudentsPage() {
  const form = document.getElementById("studentForm");
  if (!form) return;

  renderStudentTable();

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const err = validateForm(form, [
      { selector: "#studentName", check: (v) => Validators.name(v, "Name") },
      { selector: "#studentRoll", check: Validators.roll },
      { selector: "#studentDepartment", check: (v) => Validators.code(v, "Department") },
      { selector: "#studentSubject", check: (v) => Validators.code(v, "Subject") },
      { selector: "#studentSemester", check: Validators.semester }
    ]);
    if (err) {
      showStatus(err, true);
      return;
    }
    const shiftId = Number(document.getElementById("studentShift").value) || 1;
    const result = DataStore.addStudent({
      roll_no: Number(document.getElementById("studentRoll").value),
      name: document.getElementById("studentName").value.trim(),
      department: document.getElementById("studentDepartment").value.trim(),
      subject: document.getElementById("studentSubject").value.trim(),
      semester: Number(document.getElementById("studentSemester").value),
      shift_id: shiftId,
      shift_name: shiftId === 2 ? "Afternoon" : "Morning",
      default_hall: document.getElementById("studentHall").value.trim() || "Hall A"
    });
    if (!result.ok) {
      showStatus(result.error, true);
      return;
    }
    form.reset();
    showStatus("Student added successfully.");
    renderStudentTable();
  });
}

function initExamsPage() {
  const form = document.getElementById("examForm");
  if (!form) return;

  function load() {
    clearTable("examTableBody");
    DataStore.getExams().forEach((ex) => {
      addTableRow("examTableBody", [
        ex.exam_id,
        ex.subject,
        ex.department,
        ex.semester,
        ex.exam_date
      ]);
    });
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const err = validateForm(form, [
      { selector: "#examCode", check: Validators.examId },
      { selector: "#examSubject", check: (v) => Validators.code(v, "Subject") },
      { selector: "#examDepartment", check: (v) => Validators.code(v, "Department") },
      { selector: "#examSemester", check: Validators.semester },
      { selector: "#examDate", check: Validators.date }
    ]);
    if (err) {
      showStatus(err, true);
      return;
    }
    const result = DataStore.addExam({
      exam_id: Number(document.getElementById("examCode").value),
      subject: document.getElementById("examSubject").value.trim(),
      department: document.getElementById("examDepartment").value.trim(),
      semester: Number(document.getElementById("examSemester").value),
      exam_date: document.getElementById("examDate").value
    });
    if (!result.ok) {
      showStatus(result.error, true);
      return;
    }
    form.reset();
    showStatus("Exam added successfully.");
    load();
  });

  load();
}

function initShiftsPage() {
  const form = document.getElementById("shiftForm");
  if (!form) return;

  function load() {
    clearTable("shiftTableBody");
    DataStore.getShifts().forEach((s) => {
      addTableRow("shiftTableBody", [s.shift_id, s.shift_name, s.start_time, s.end_time]);
    });
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const err = validateForm(form, [
      { selector: "#shiftId", check: Validators.examId },
      { selector: "#shiftName", check: (v) => Validators.name(v, "Shift name") },
      { selector: "#shiftStartTime", check: Validators.time },
      { selector: "#shiftEndTime", check: Validators.time }
    ]);
    if (err) {
      showStatus(err, true);
      return;
    }
    const result = DataStore.addShift({
      shift_id: Number(document.getElementById("shiftId").value),
      shift_name: document.getElementById("shiftName").value.trim(),
      start_time: document.getElementById("shiftStartTime").value,
      end_time: document.getElementById("shiftEndTime").value
    });
    if (!result.ok) {
      showStatus(result.error, true);
      return;
    }
    form.reset();
    showStatus("Shift added successfully.");
    load();
  });

  load();
}

function renderSeatingVisualization(seating) {
  const container = document.getElementById("seatingVisualization");
  if (!container) return;
  if (!seating.length) {
    container.innerHTML = "<p class=\"muted-text\">Select an exam and generate a seating plan.</p>";
    return;
  }

  const departments = [...new Set(seating.map((s) => s.department))];
  let legendHtml = '<div class="legend">';
  departments.forEach((d) => {
    legendHtml += `<span class="legend-item"><span class="legend-swatch" style="background:${deptColor(d)}"></span>${d}</span>`;
  });
  legendHtml += "</div>";

  const byHall = {};
  seating.forEach((s) => {
    if (!byHall[s.hall_name]) byHall[s.hall_name] = [];
    byHall[s.hall_name].push(s);
  });

  let html = legendHtml;
  Object.keys(byHall).forEach((hall) => {
    html += `<div class="hall-block"><h3>${hall}</h3><div class="seat-grid">`;
    byHall[hall].forEach((seat) => {
      const bg = deptColor(seat.department);
      html += `<div class="seat-cell" style="background:${bg}">
        <strong>Seat ${seat.seat_no}</strong>
        Roll: ${seat.student_roll_no}<br>
        ${seat.name}<br>
        ${seat.subject}
      </div>`;
    });
    html += "</div></div>";
  });
  container.innerHTML = html;
}

function initSeatingPage() {
  const form = document.getElementById("seatingForm");
  if (!form) return;

  const list = document.getElementById("hallsList");
  if (list) {
    list.innerHTML = DataStore.getHalls()
      .map((h) => `<li>${h.hall_name} — capacity ${h.capacity}</li>`)
      .join("");
  }

  const select = document.getElementById("seatingExamId");
  if (select) {
    select.innerHTML = "";
    DataStore.getExams().forEach((e) => {
      const opt = document.createElement("option");
      opt.value = e.exam_id;
      opt.textContent = e.exam_id + " — " + e.subject;
      select.appendChild(opt);
    });
  }

  function loadSeating() {
    const examId = select ? Number(select.value) : 0;
    const seating = DataStore.getSeating(examId);
    renderSeatingVisualization(seating);
    window.lastSeatingReport = seating;
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const examId = select ? Number(select.value) : 0;
    if (!examId) {
      showStatus("Please select an exam.", true);
      return;
    }
    const shiftVal = document.getElementById("seatingShiftId").value;
    const result = DataStore.generateSeating(examId, shiftVal ? Number(shiftVal) : null);
    showStatus(result.message);
    loadSeating();
  });

  document.getElementById("refreshSeatingBtn")?.addEventListener("click", loadSeating);
  select?.addEventListener("change", loadSeating);
  loadSeating();
}

function downloadCSV(rows, filename) {
  if (!rows.length) {
    showStatus("No seating data to export.", true);
    return;
  }
  const headers = ["hall_name", "seat_no", "student_roll_no", "name", "department", "subject", "shift_name"];
  const lines = [headers.join(",")];
  rows.forEach((row) => {
    lines.push(headers.map((h) => `"${String(row[h] ?? "").replace(/"/g, '""')}"`).join(","));
  });
  const blob = new Blob([lines.join("\n")], { type: "text/csv" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  a.click();
}

function downloadPDF() {
  const area = document.getElementById("reportPrintArea");
  if (!area || !area.innerHTML.trim()) {
    showStatus("Generate a seating plan first.", true);
    return;
  }
  const w = window.open("", "_blank");
  w.document.write(`<html><head><title>Seating Report</title>
    <style>body{font-family:Arial;padding:20px}table{width:100%;border-collapse:collapse}
    th,td{border:1px solid #ccc;padding:8px}h2{color:#0f766e}</style></head><body>`);
  w.document.write(area.innerHTML);
  w.document.write("</body></html>");
  w.document.close();
  w.print();
}

function initReportsPage() {
  const examSelect = document.getElementById("reportExamId");
  if (examSelect) {
    examSelect.innerHTML = '<option value="">All exams</option>';
    DataStore.getExams().forEach((e) => {
      const opt = document.createElement("option");
      opt.value = e.exam_id;
      opt.textContent = `${e.exam_id} - ${e.subject}`;
      examSelect.appendChild(opt);
    });
  }

  function loadReport() {
    const examId = examSelect?.value || "";
    const report = DataStore.getReport(examId ? Number(examId) : null);
    window.reportData = report;

    const body = document.getElementById("reportTableBody");
    const printArea = document.getElementById("reportPrintArea");
    if (!body || !printArea) return;

    clearTable("reportTableBody");
    if (!report.length) {
      body.innerHTML = '<tr><td colspan="7" class="table-empty">No seating records for this selection.</td></tr>';
      printArea.innerHTML = "";
      return;
    }

    let printHtml =
      "<h2>Seating Arrangement Report</h2><p>Generated: " +
      new Date().toLocaleString() +
      "</p><table><thead><tr><th>Hall</th><th>Seat</th><th>Roll</th><th>Name</th><th>Department</th><th>Subject</th><th>Shift</th></tr></thead><tbody>";

    report.forEach((r) => {
      addTableRow("reportTableBody", [
        r.hall_name,
        r.seat_no,
        r.student_roll_no,
        r.name,
        r.department,
        r.subject,
        r.shift_name
      ]);
      printHtml += `<tr><td>${r.hall_name}</td><td>${r.seat_no}</td><td>${r.student_roll_no}</td><td>${r.name}</td><td>${r.department}</td><td>${r.subject}</td><td>${r.shift_name}</td></tr>`;
    });
    printHtml += "</tbody></table>";
    printArea.innerHTML = printHtml;
  }

  document.getElementById("loadReportBtn")?.addEventListener("click", loadReport);
  document.getElementById("downloadCsvBtn")?.addEventListener("click", () => {
    if (!window.reportData?.length) {
      showStatus("Load the report before downloading.", true);
      return;
    }
    downloadCSV(window.reportData, "seating_report.csv");
    showStatus("Report downloaded.");
  });
  document.getElementById("downloadPdfBtn")?.addEventListener("click", downloadPDF);
  examSelect?.addEventListener("change", loadReport);
  loadReport();
}

function initDashboard() {
  const elS = document.getElementById("statStudents");
  const elE = document.getElementById("statExams");
  const elSh = document.getElementById("statShifts");
  const elSe = document.getElementById("statSeating");
  if (elS) elS.textContent = DataStore.getStudents().length;
  if (elE) elE.textContent = DataStore.getExams().length;
  if (elSh) elSh.textContent = DataStore.getShifts().length;
  if (elSe) elSe.textContent = DataStore.getSeating().length;
}

const PAGE_INIT = {
  dashboard: initDashboard,
  students: initStudentsPage,
  exams: initExamsPage,
  shifts: initShiftsPage,
  seating: initSeatingPage,
  reports: initReportsPage
};

document.addEventListener("DOMContentLoaded", () => {
  if (window.IS_LOGIN_PAGE) return;
  const page = document.body.dataset.page;
  const initFn = PAGE_INIT[page];
  if (!initFn) return;
  guardApp().then(initFn).catch(() => {});
});
