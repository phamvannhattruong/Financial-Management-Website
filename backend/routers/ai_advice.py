import sys
import os
import google.generativeai as genai
import json
from dotenv import load_dotenv
load_dotenv()


# Fix đường dẫn import
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

from fastapi import APIRouter
from connect_to_database import get_db_connection
import random

router = APIRouter(
    prefix="/api/ai",
    tags=["AI Advisor"]
)

# --- CẤU HÌNH GEMINI ---
# Bạn hãy thay dòng dưới bằng API Key thật của bạn
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel('gemini-2.5-pro')

@router.get("/advice/{user_id}")
async def get_financial_advice(user_id: str):
    try:
        # 1. Lấy dữ liệu Ngân sách & Chi tiêu từ DB
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = "SELECT TenNganSach, SoTienGioiHan FROM NganSach WHERE MaNguoiDung = ?"
        cursor.execute(query, (user_id,))
        rows = cursor.fetchall()
        conn.close()

        if not rows:
            return {"status": "success", "data": ["Bạn chưa thiết lập ngân sách nào nên AI chưa thể tư vấn."]}

        # 2. Xây dựng ngữ cảnh (Context) để gửi cho Gemini
        # Tạo chuỗi mô tả: "Ăn uống: Giới hạn 5tr, Đã chi 4tr..."
        budget_context = ""
        for row in rows:
            limit = float(row.SoTienGioiHan)
            # Giả lập số đã chi (Vì ta chưa query bảng GiaoDich thật)
            # Trong thực tế: Bạn query SUM(SoTien) from GiaoDich...
            spent = limit * random.uniform(0.5, 1.3) 
            
            percent = int((spent/limit)*100)
            budget_context += f"- Danh mục {row.TenNganSach}: Đã tiêu {percent}% ngân sách.\n"

        # 3. Tạo Prompt (Câu lệnh nhắc)
        prompt = f"""
        Bạn là một trợ lý tài chính cá nhân thông minh. Dựa vào tình hình chi tiêu sau của người dùng:
        {budget_context}

        Hãy đưa ra đúng 3 lời khuyên ngắn gọn, súc tích (mỗi câu dưới 20 từ), hài hước một chút cũng được.
        Định dạng trả về: Chỉ trả về một JSON Array chứa 3 chuỗi text (String). 
        Ví dụ: ["Cảnh báo: Bạn sắp hết tiền ăn rồi!", "Tuyệt vời, quỹ tiết kiệm vẫn ổn.", "Bớt trà sữa lại đi nhé."]
        Không trả về Markdown, chỉ trả về JSON thuần.
        """

        # 4. Gọi Gemini
        response = model.generate_content(prompt)
        
        # 5. Xử lý kết quả (Clean JSON string)
        text_response = response.text.strip()
        # Đôi khi Gemini trả về ```json ... ```, cần xóa đi để parse
        if text_response.startswith("```"):
            text_response = text_response.replace("```json", "").replace("```", "")
        
        advice_list = json.loads(text_response)

        return {"status": "success", "data": advice_list}

    except Exception as e:
        print(f"Lỗi AI: {e}")
        # Trả về câu mặc định nếu lỗi (để UI không bị trống)
        return {"status": "error", "data": [
            "Hệ thống AI đang bận, hãy thử lại sau.",
            "Hãy kiểm tra lại kết nối mạng.",
            "Tiết kiệm là quốc sách!"
        ]}