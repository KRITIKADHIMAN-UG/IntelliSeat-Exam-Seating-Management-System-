function appendRow(tableBodyId, values) {
  const body = document.getElementById(tableBodyId);
  if (!body) return;

  const row = document.createElement("tr");
  values.forEach((value) => {
    const td = document.createElement("td");
    td.textContent = value;
    row.appendChild(td);
  });
  body.appendChild(row);
}

const studentForm = document.getElementById("studentForm");
if (studentForm) {
  studentForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const name = document.getElementById("studentName").value.trim();
    const roll = document.getElementById("studentRoll").value.trim();
    const branch = document.getElementById("studentBranch").value.trim();

    if (!name || !roll || !branch) return;
    appendRow("studentTableBody", [name, roll, branch]);
    studentForm.reset();
  });
}

const examForm = document.getElementById("examForm");
if (examForm) {
  examForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const code = document.getElementById("examCode").value.trim();
    const subject = document.getElementById("examSubject").value.trim();
    const date = document.getElementById("examDate").value;

    if (!code || !subject || !date) return;
    appendRow("examTableBody", [code, subject, date]);
    examForm.reset();
  });
}

const shiftForm = document.getElementById("shiftForm");
if (shiftForm) {
  shiftForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const name = document.getElementById("shiftName").value.trim();
    const start = document.getElementById("shiftStartTime").value;
    const end = document.getElementById("shiftEndTime").value;

    if (!name || !start || !end) return;
    appendRow("shiftTableBody", [name, start, end]);
    shiftForm.reset();
  });
}

const seatingForm = document.getElementById("seatingForm");
if (seatingForm) {
  seatingForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const hallName = document.getElementById("hallName").value.trim();
    const capacity = document.getElementById("hallCapacity").value;
    const output = document.getElementById("seatingOutput");

    if (!hallName || !capacity || !output) return;
    output.textContent = "Seating generated for " + hallName + " with capacity " + capacity + ".";
    seatingForm.reset();
  });
}
