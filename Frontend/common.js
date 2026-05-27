const DEPT_COLORS = {
  CSE: "#0d9488",
  ECE: "#14b8a6",
  ME: "#0f766e",
  CE: "#2dd4bf",
  IT: "#115e59",
  DEFAULT: "#5eead4"
};

const Validators = {
  name(value, label = "Name") {
    const v = (value || "").trim();
    if (!/^[A-Za-z][A-Za-z\s.\-]{1,99}$/.test(v)) {
      return `${label}: use letters and spaces only (2-100 characters).`;
    }
    return null;
  },
  code(value, label = "Field") {
    const v = (value || "").trim();
    if (!/^[A-Za-z0-9][A-Za-z0-9\s\-]{1,49}$/.test(v)) {
      return `${label}: invalid symbols or empty value.`;
    }
    return null;
  },
  roll(value) {
    const n = Number(value);
    if (!Number.isInteger(n) || n < 1000 || n > 999999) {
      return "Roll number must be a valid number between 1000 and 999999.";
    }
    return null;
  },
  semester(value) {
    const n = Number(value);
    if (!Number.isInteger(n) || n < 1 || n > 8) {
      return "Semester must be between 1 and 8.";
    }
    return null;
  },
  examId(value) {
    const n = Number(value);
    if (!Number.isInteger(n) || n <= 0) {
      return "Exam ID must be a positive number.";
    }
    return null;
  },
  date(value) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value || "")) {
      return "Date must be in YYYY-MM-DD format.";
    }
    return null;
  },
  time(value) {
    if (!/^\d{2}:\d{2}$/.test(value || "")) {
      return "Time must be in HH:MM format.";
    }
    return null;
  }
};

function showStatus(message, isError = false) {
  if (!message) return;
  let box = document.getElementById("statusMessage");
  if (!box) {
    box = document.createElement("div");
    box.id = "statusMessage";
    const main = document.querySelector(".main-content");
    if (main) main.prepend(box);
  }
  box.className = "status-msg " + (isError ? "error" : "success");
  box.textContent = message;
  box.style.display = "block";
}

function clearFieldErrors(form) {
  form.querySelectorAll(".field-error").forEach((el) => el.remove());
  form.querySelectorAll(".invalid").forEach((el) => el.classList.remove("invalid"));
}

function showFieldError(input, message) {
  input.classList.add("invalid");
  const err = document.createElement("div");
  err.className = "field-error";
  err.textContent = message;
  input.parentElement.appendChild(err);
}

function validateForm(form, rules) {
  clearFieldErrors(form);
  let firstError = null;
  for (const rule of rules) {
    const input = form.querySelector(rule.selector);
    if (!input) continue;
    const msg = rule.check(input.value);
    if (msg) {
      showFieldError(input, msg);
      if (!firstError) firstError = msg;
    }
  }
  return firstError;
}

function deptColor(dept) {
  return DEPT_COLORS[dept] || DEPT_COLORS.DEFAULT;
}

function guardApp() {
  if (window.IS_LOGIN_PAGE) return Promise.resolve();
  if (!DataStore.isAuthenticated()) {
    window.location.href = "login.html";
    return Promise.reject(new Error("Not authenticated"));
  }
  const userEl = document.getElementById("sidebarUser");
  if (userEl) userEl.textContent = DataStore.getUsername();
  return Promise.resolve();
}

function setupLogout() {
  const btn = document.getElementById("logoutBtn");
  if (!btn) return;
  btn.addEventListener("click", () => {
    DataStore.logout();
    window.location.href = "login.html";
  });
}

function markActiveNav() {
  const page = document.body.dataset.page;
  document.querySelectorAll(".sidebar nav a").forEach((a) => {
    a.classList.toggle("active", a.dataset.page === page);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  markActiveNav();
  setupLogout();
});
