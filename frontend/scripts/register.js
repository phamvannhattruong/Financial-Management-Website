document.addEventListener("DOMContentLoaded", () => {
  console.log("Register page loaded");
// Toggle password hiển thị
  const toggleBtn = document.querySelector(".toggle-pw");
  const pwField = document.querySelector("#password");

  if (toggleBtn && pwField) {
    toggleBtn.addEventListener("click", () => {
      const isHidden = pwField.type === "password";
      pwField.type = isHidden ? "text" : "password";
      toggleBtn.textContent = isHidden ? "🙈" : "👁";
    });
  }
  // Xử lý submit form đăng ký
  const registerForm = document.getElementById("registerForm");
  if (registerForm) {
    registerForm.addEventListener("submit", (e) => {
      e.preventDefault();
      const name = registerForm.fullname.value.trim();
      const email = registerForm.email.value.trim();
      const password = registerForm.password.value.trim();

      if (!name || !email || !password) {
        alert("Please fill in all fields!");
        return;
      }

      console.log("Register:", name, email, password);
      alert("Registration successful! (demo)");
      window.location.href = "login.html";
    });
  }

  // Chuyển sang trang đăng nhập
  const signinBtn = document.getElementById("signinBtn");
  if (signinBtn) {
    signinBtn.addEventListener("click", () => {
      window.location.href = "login.html";
    });
  }
});
