document.addEventListener("DOMContentLoaded", () => {
  console.log("Login page loaded");

  // 1. Toggle password hiển thị (Giữ nguyên code của bạn)
  const toggleBtn = document.querySelector(".toggle-pw");
  const pwField = document.querySelector("#password");

  if (toggleBtn && pwField) {
    toggleBtn.addEventListener("click", () => {
      const isHidden = pwField.type === "password";
      pwField.type = isHidden ? "text" : "password";
      toggleBtn.textContent = isHidden ? "🙈" : "👁";
    });
  }

  // 2. Xử lý submit đăng nhập (Đã cập nhật logic gọi API)
  const loginForm = document.getElementById("loginForm");
  
  if (loginForm) {
    // Chú ý: Thêm 'async' ở đây để xử lý bất đồng bộ
    loginForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      
      const email = loginForm.querySelector("#email").value.trim(); // Lấy theo ID cho chắc chắn
      const password = loginForm.querySelector("#password").value.trim();
      const errorMsg = document.getElementById("error-message"); // Thẻ <p> hiển thị lỗi (nếu có)
      const submitBtn = loginForm.querySelector("button[type='submit']");

      // Validate cơ bản
      if (!email || !password) {
        alert("Vui lòng điền đầy đủ thông tin!");
        return;
      }

      try {
        // Hiệu ứng nút bấm khi đang tải
        if(submitBtn) {
            submitBtn.innerText = "Đang xử lý...";
            submitBtn.disabled = true;
        }

        // --- GỌI API BACKEND ---
        // Nếu bạn đã có file config.js thì dùng: fetch(API_ENDPOINTS.LOGIN, ...)
        // Nếu chưa, dùng link cứng như dưới đây:
        const response = await fetch("http://127.0.0.1:8000/api/auth/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ email: email, password: password })
        });

        // Đọc kết quả JSON trả về
        const result = await response.json();

        if (response.ok) {
            // --- TRƯỜNG HỢP THÀNH CÔNG ---
            console.log("Login success:", result);
            
            // 1. Lưu thông tin user vào bộ nhớ trình duyệt
            localStorage.setItem("user_id", result.data.user_id);
            localStorage.setItem("user_name", result.data.name);
            localStorage.setItem("user_role", result.data.role);

            // 2. Chuyển hướng sang trang Dashboard
            // Đảm bảo file dashboard.html nằm cùng thư mục hoặc chỉnh đường dẫn cho đúng
            window.location.href = "/dashboard"; 
        } else {
            // --- TRƯỜNG HỢP THẤT BẠI ---
            // Nếu có thẻ error-message thì hiện lên, không thì alert
            const message = result.detail || "Đăng nhập thất bại!";
            if (errorMsg) {
                errorMsg.style.display = "block";
                errorMsg.innerText = message;
            } else {
                alert(message);
            }
        }

      } catch (error) {
        console.error("Lỗi hệ thống:", error);
        alert("Không thể kết nối đến Server Backend!");
      } finally {
        // Trả lại trạng thái nút bấm
        if(submitBtn) {
            submitBtn.innerText = "Đăng nhập";
            submitBtn.disabled = false;
        }
      }
    });
  }
});