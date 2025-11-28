# backend/routers/wallet.py
from fastapi import APIRouter, HTTPException
from connect_to_database import get_db_connection
from pydantic import BaseModel

class WalletItem(BaseModel):
    id: str
    name: str
    type: str
    balance: float


# Tạo một router riêng cho Ví
router = APIRouter(
    prefix="/api/wallets",
    tags=["Wallets"]
)

@router.get("/{user_id}")
def get_wallets(user_id: str):
    wallets = []
    try:
        conn = get_db_connection() # Gọi hàm từ file database.py
        cursor = conn.cursor()
        
        query = """
        SELECT MaNguonTien, TenNguonTien, LoaiNguonTien, SoDu 
        FROM NguonTien 
        WHERE MaNguoiDung = ?
        """
        cursor.execute(query, (user_id,))
        rows = cursor.fetchall()
        
        for row in rows:
            wallets.append(WalletItem(
                id=row.MaNguonTien,
                name=row.TenNguonTien,
                type=row.LoaiNguonTien,
                balance=float(row.SoDu)
            ))
            
        conn.close()
        return {"status": "success", "data": wallets}
        
    except Exception as e:
        return {"status": "error", "message": str(e)}