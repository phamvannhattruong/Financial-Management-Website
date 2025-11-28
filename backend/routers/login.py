from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from connect_to_database import get_db_connection

router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)

# 1. Định nghĩa dữ liệu gửi lên từ Frontend
class LoginRequest(BaseModel):
    email: str
    password: str

# 2. API Đăng nhập
@router.post("/login")
def login(req: LoginRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Tìm user theo Email
        query = "SELECT MaNguoiDung, HoTen, MatKhau, VaiTro FROM NguoiDung WHERE Email = ?"
        cursor.execute(query, (req.email,))
        user = cursor.fetchone()
        
        conn.close()

        # Kiểm tra:
        # 1. User có tồn tại không?
        # 2. Mật khẩu có khớp không? (Ở đây đang so sánh text thường, thực tế nên dùng Hash)
        if user and user.MatKhau == req.password:
            return {
                "status": "success",
                "message": "Đăng nhập thành công",
                "data": {
                    "user_id": user.MaNguoiDung,
                    "name": user.HoTen,
                    "role": user.VaiTro
                }
            }
        else:
            # Trả về lỗi 401 (Unauthorized) nếu sai thông tin
            raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không đúng!")

    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail="Lỗi server")