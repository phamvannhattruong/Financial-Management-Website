document.addEventListener("DOMContentLoaded", () => {
  console.log("Login page loaded");

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

  // Xử lý submit đăng nhập
  const loginForm = document.getElementById("loginForm");
  if (loginForm) {
    loginForm.addEventListener("submit", (e) => {
      e.preventDefault();
      const email = loginForm.email.value.trim();
      const password = loginForm.password.value.trim();

      if (!email || !password) {
        alert("Please fill in all fields!");
        return;
      }

      console.log("Login:", email, password);
      alert("Login successful! (demo)");
      // window.location.href = "../index.html";
    });
  }
});
