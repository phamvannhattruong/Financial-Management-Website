import sys
import os
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

from fastapi import APIRouter
from connect_to_database import get_db_connection

router = APIRouter(
    prefix="/api/stats",
    tags=["Statistics"]
)

@router.get("/chart/{user_id}")
def get_chart_data(user_id: str):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Query: Gom nhóm theo Tháng và Loại Giao Dịch
        # Lưu ý: Hàm MONTH() và YEAR() hoạt động tốt trên SQL Server
        query = """
        SELECT MONTH(NgayGiaoDich) as Thang, LoaiGiaoDich, SUM(SoTien) as TongTien
        FROM GiaoDich
        WHERE MaNguoiDung = ? AND NgayGiaoDich >= DATEADD(month, -5, GETDATE()) 
        GROUP BY MONTH(NgayGiaoDich), LoaiGiaoDich
        ORDER BY Thang
        """
        
        cursor.execute(query, (user_id,))
        rows = cursor.fetchall()
        
        # Xử lý dữ liệu để trả về format cho ChartJS
        # Cấu trúc mong muốn: { "labels": [T10, T11, T12], "thu": [..], "chi": [..] }
        
        data_map = {} # Dùng để gom data: { 10: {thu: 0, chi: 0}, 11: ... }

        for row in rows:
            thang = row.Thang
            loai = row.LoaiGiaoDich # 'Thu' hoặc 'Chi'
            tien = float(row.TongTien)

            if thang not in data_map:
                data_map[thang] = {"thu": 0, "chi": 0}
            
            if loai == 'Thu':
                data_map[thang]["thu"] = tien
            elif loai == 'Chi':
                data_map[thang]["chi"] = tien

        # Chuyển đổi sang List để trả về
        labels = []
        income_data = []
        expense_data = []

        for thang in sorted(data_map.keys()):
            labels.append(f"Tháng {thang}")
            income_data.append(data_map[thang]["thu"])
            expense_data.append(data_map[thang]["chi"])

        conn.close()
        return {
            "status": "success", 
            "data": {
                "labels": labels,
                "income": income_data,
                "expense": expense_data
            }
        }

    except Exception as e:
        print(e)
        return {"status": "error", "message": str(e)}