import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

from fastapi import APIRouter
from connect_to_database import get_db_connection
import random # Dùng để giả lập số tiền đã chi

router = APIRouter(
    prefix="/api/budgets",
    tags=["Budgets"]
)

@router.get("/{user_id}")
def get_budgets(user_id: str):
    data = []
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Lấy danh sách ngân sách
        query = "SELECT TenNganSach, SoTienGioiHan FROM NganSach WHERE MaNguoiDung = ?"
        cursor.execute(query, (user_id,))
        rows = cursor.fetchall()

        for row in rows:
            limit = float(row.SoTienGioiHan)
            
            # --- GIẢ LẬP SỐ TIỀN ĐÃ CHI (Demo) ---
            # Trong thực tế, bạn phải Query bảng GiaoDich để SUM lại
            # Ở đây mình random từ 50% đến 120% hạn mức để bạn thấy thanh màu chạy
            spent = limit * random.uniform(0.5, 1.2) 
            # -------------------------------------

            data.append({
                "name": row.TenNganSach,
                "limit": limit,
                "spent": spent
            })
            
        conn.close()
        return {"status": "success", "data": data}

    except Exception as e:
        return {"status": "error", "message": str(e)}