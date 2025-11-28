import sys
import os
from datetime import datetime

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

from fastapi import APIRouter
from fastapi.responses import Response # Dùng để trả về file
from connect_to_database import get_db_connection

router = APIRouter(
    prefix="/api/report",
    tags=["Report"]
)

@router.get("/export/{user_id}")
def export_report(user_id: str):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # 1. Lấy thông tin Ví
        cursor.execute("SELECT TenNguonTien, SoDu FROM NguonTien WHERE MaNguoiDung = ?", (user_id,))
        wallets = cursor.fetchall()

        # 2. Lấy thông tin Ngân sách
        cursor.execute("SELECT TenNganSach, SoTienGioiHan FROM NganSach WHERE MaNguoiDung = ?", (user_id,))
        budgets = cursor.fetchall()

        conn.close()

        # 3. Soạn nội dung file TXT
        time_now = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        content = f"=== BÁO CÁO TÀI CHÍNH ===\n"
        content += f"Người dùng: {user_id}\n"
        content += f"Thời gian xuất: {time_now}\n"
        content += "=========================\n\n"

        content += "[1] DANH SÁCH VÍ TIỀN:\n"
        total_balance = 0
        if wallets:
            for w in wallets:
                balance = float(w.SoDu)
                total_balance += balance
                content += f"- {w.TenNguonTien}: {balance:,.0f} VNĐ\n"
            content += f"---> TỔNG TÀI SẢN: {total_balance:,.0f} VNĐ\n"
        else:
            content += "(Chưa có dữ liệu ví)\n"

        content += "\n[2] NGÂN SÁCH THIẾT LẬP:\n"
        if budgets:
            for b in budgets:
                limit = float(b.SoTienGioiHan)
                content += f"- {b.TenNganSach}: Hạn mức {limit:,.0f} VNĐ\n"
        else:
            content += "(Chưa có ngân sách)\n"
            
        content += "\n=========================\n"
        content += "Cảm ơn bạn đã sử dụng AI Finance!"

        # 4. Trả về file để trình duyệt tải xuống
        return Response(
            content=content,
            media_type="text/plain", # Định dạng file text
            headers={
                "Content-Disposition": f"attachment; filename=report_{user_id}.txt"
            }
        )

    except Exception as e:
        return Response(content=f"Lỗi xuất báo cáo: {str(e)}", media_type="text/plain")