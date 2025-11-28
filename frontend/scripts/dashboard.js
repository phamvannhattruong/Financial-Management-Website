document.addEventListener("DOMContentLoaded", () => {
    const userId = localStorage.getItem("user_id");
    const userName = localStorage.getItem("user_name");

    if (!userId) {
        // Sửa đường dẫn tuyệt đối để tránh lỗi 404
        window.location.href = "/page/login.html"; 
        return;
    }

    const nameElement = document.getElementById("user-display");
    if (nameElement && userName) {
        nameElement.innerText = userName;
    }

    const btnExport = document.getElementById("btn-export");
    if (btnExport) {
        btnExport.addEventListener("click", () => {
            const userId = localStorage.getItem("user_id");
            if(userId) {
                downloadReport(userId);
            }
        });
    }

    const btnLogout = document.getElementById("btn-logout");
    if (btnLogout) {
        btnLogout.addEventListener("click", (e) => {
            e.preventDefault();

            if (confirm("Bạn có chắc chắn muốn đăng xuất?")) {

                localStorage.removeItem("user_id");
                localStorage.removeItem("user_name");
                localStorage.removeItem("user_role");
                
                window.location.href = "/page/login.html"; 
            }
        });
    }

    loadWallets(userId);
    loadBudgets(userId);
    loadAIAdvice(userId);
    loadChart(userId);
});

// --- HÀM 1: Định dạng tiền (Dùng lại được) ---
function formatMoney(amount) {
    if (Math.abs(amount) >= 1000000) {
        return (amount / 1000000).toFixed(1) + "tr ₫";
    }
    return amount.toLocaleString('vi-VN') + " ₫";
}

// --- HÀM 2: Chọn giao diện theo loại ví (Dùng lại được) ---
function getWalletStyle(type) {
    const styles = {
        'TienMat':   { icon: 'fa-wallet',           color: '#2ecc71' },
        'NganHang':  { icon: 'fa-building-columns', color: '#3498db' },
        'Momo':      { icon: 'fa-mobile-screen',    color: '#e91e63' },
        'TinDung':   { icon: 'fa-credit-card',      color: '#f1c40f' }
    };
    return styles[type] || { icon: 'fa-sack-dollar', color: '#95a5a6' };
}

// --- HÀM 3: Load dữ liệu ---
async function loadWallets(userId) {
    const container = document.getElementById("wallet-list");
    if (!container) return;

    try {
        const response = await fetch(`/api/wallets/${userId}`);
        const result = await response.json();

        console.log("Dữ liệu ví:", result);

        // Xóa loading cũ
        container.innerHTML = "";

        if (result.status === "success" && result.data.length > 0) {
            
            result.data.forEach(wallet => {
                const style = getWalletStyle(wallet.type);
                const money = formatMoney(wallet.balance);

                const html = `
                    <div class="wallet-item">
                        <div class="wallet-icon" style="background-color: ${style.color}">
                            <i class="fa-solid ${style.icon}"></i>
                        </div>
                        <div class="wallet-name">${wallet.name}</div>
                        <div class="wallet-amount">${money}</div>
                    </div>
                `;
                container.insertAdjacentHTML("beforeend", html);
            });

        } else {
            // Style đẹp hơn cho thông báo rỗng
            container.innerHTML = '<p style="text-align:center; color:#999; grid-column: span 3; padding: 20px;">Bạn chưa có ví nào.</p>';
        }

    } catch (error) {
        console.error("Lỗi:", error);
        // Báo lỗi ra màn hình cho người dùng biết
        container.innerHTML = '<p style="color:red; text-align:center; grid-column: span 3;">Không tải được dữ liệu ví!</p>';
    }
}

async function loadBudgets(userId) {
    const container = document.getElementById("budget-list");
    if (!container) return;

    try {
        const response = await fetch(`/api/budgets/${userId}`);
        const result = await response.json();

        if (result.status === "success" && result.data.length > 0) {
            container.innerHTML = ""; // Xóa loading

            result.data.forEach(item => {
                // 1. Tính phần trăm
                let percent = (item.spent / item.limit) * 100;
                
                // 2. Chọn màu sắc
                let colorClass = "fill-blue"; // Mặc định màu xanh
                let textStyle = ""; 

                if (percent > 100) {
                    percent = 100; // Không để tràn ra ngoài
                    colorClass = "fill-red"; // Quá lố -> Màu đỏ
                    textStyle = "color: #e74c3c; font-weight: bold;";
                } else if (percent > 80) {
                    colorClass = "fill-sky"; // Gần hết -> Màu xanh nhạt
                }

                // 3. Định dạng tiền gọn (VD: 1.2tr)
                const spentStr = (item.spent / 1000000).toFixed(1) + "tr";
                const limitStr = (item.limit / 1000000).toFixed(1) + "tr";

                // 4. Tạo HTML
                const html = `
                    <div class="budget-item">
                        <div class="budget-header">
                            <span>${item.name}</span>
                            <span style="${textStyle}">${spentStr} / ${limitStr} ₫</span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill ${colorClass}" style="width: ${percent}%"></div>
                        </div>
                    </div>
                `;
                container.insertAdjacentHTML("beforeend", html);
            });
        } else {
            container.innerHTML = "<p style='text-align:center'>Chưa thiết lập ngân sách.</p>";
        }
    } catch (error) {
        console.error("Lỗi budget:", error);
    }
}
async function loadAIAdvice(userId) {
    const container = document.querySelector(".suggestion-list");
    if (!container) return;

    // Hiển thị trạng thái đang suy nghĩ
    container.innerHTML = `
        <li style="color:#666; font-style:italic;">
            <i class="fa-solid fa-spinner fa-spin"></i> AI đang phân tích dữ liệu của bạn...
        </li>
    `;

    try {
        const response = await fetch(`/api/ai/advice/${userId}`);
        const result = await response.json();

        if (result.status === "success" && result.data.length > 0) {
            container.innerHTML = ""; // Xóa loading

            result.data.forEach(tip => {
                const html = `
                    <li>
                        <i class="fa-solid fa-lightbulb bulb-icon"></i>
                        <span>${tip}</span>
                    </li>
                `;
                container.insertAdjacentHTML("beforeend", html);
            });
        }
    } catch (error) {
        console.error("Lỗi AI:", error);
        container.innerHTML = `<li>AI đang ngủ quên rồi (Lỗi kết nối).</li>`;
    }
}
async function loadChart(userId) {
    const ctx = document.getElementById('financeChart');
    if (!ctx) return;

    try {
        const response = await fetch(`/api/stats/chart/${userId}`);
        const result = await response.json();

        if (result.status === 'success') {
            const data = result.data;

            // Cấu hình Chart.js
            new Chart(ctx, {
                type: 'bar', // Loại biểu đồ cột
                data: {
                    labels: data.labels, // ["Tháng 10", "Tháng 11"...]
                    datasets: [
                        {
                            label: 'Thu Nhập',
                            data: data.income,
                            backgroundColor: '#2ecc71', // Màu xanh lá
                            borderRadius: 5,
                        },
                        {
                            label: 'Chi Tiêu',
                            data: data.expense,
                            backgroundColor: '#e74c3c', // Màu đỏ
                            borderRadius: 5,
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top' }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: '#f0f0f0' }
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });
        }
    } catch (error) {
        console.error("Lỗi biểu đồ:", error);
    }
}

async function downloadReport(userId) {
    const btn = document.getElementById("btn-export");
    btn.innerText = "Đang tạo file...";
    btn.disabled = true;

    try {
        // 1. Gọi API
        const response = await fetch(`/api/report/export/${userId}`);
        
        if (response.ok) {
            // 2. Chuyển đổi dữ liệu nhận được thành Blob (File ảo)
            const blob = await response.blob();
            
            // 3. Tạo một đường link ảo để bấm vào
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = `BaoCao_TaiChinh_${userId}.txt`; // Tên file khi tải về
            document.body.appendChild(a);
            
            // 4. Tự động click để tải
            a.click();
            
            // 5. Dọn dẹp
            a.remove();
            window.URL.revokeObjectURL(url);
        } else {
            alert("Lỗi khi tạo báo cáo!");
        }
    } catch (error) {
        console.error("Lỗi export:", error);
        alert("Không kết nối được server.");
    } finally {
        btn.innerText = "XUẤT BÁO CÁO";
        btn.disabled = false;
    }
}