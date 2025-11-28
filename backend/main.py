import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from routers import login, wallet

app = FastAPI()

# --- CẤU HÌNH ĐƯỜNG DẪN (QUAN TRỌNG) ---
current_dir = os.path.dirname(os.path.abspath(__file__))

# SỬA: Trỏ vào thư mục gốc "frontend" (chứ không phải "frontend/page")
# Để Server nhìn thấy cả thư mục "css", "scripts" và "page"
frontend_dir = os.path.join(current_dir, "../frontend")
# ---------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(login.router)
app.include_router(wallet.router)

# --- XỬ LÝ GIAO DIỆN HTML ---

@app.get("/")
async def read_root():
    # SỬA: Phải thêm "/page/" vào đây vì login.html nằm trong đó
    return FileResponse(os.path.join(frontend_dir, "page", "login.html"))

@app.get("/dashboard")
async def show_dashboard():
    # SỬA: Tương tự, thêm "/page/" vào đây
    return FileResponse(os.path.join(frontend_dir, "page", "dashboard.html"))

# --- MOUNT STATIC FILES ---
# Khi trỏ vào frontend_dir (thư mục cha), URL sẽ khớp như sau:
# /css/style.css  --> frontend/css/style.css
# /scripts/main.js --> frontend/scripts/main.js
app.mount("/", StaticFiles(directory=frontend_dir), name="frontend")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)