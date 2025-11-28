import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from routers import login, wallet, budget, ai_advice, stats, report

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
app.include_router(budget.router)
app.include_router(ai_advice.router)
app.include_router(stats.router)
app.include_router(report.router)
# --- XỬ LÝ GIAO DIỆN HTML ---

@app.get("/")
async def read_root():
    return FileResponse(os.path.join(frontend_dir, "page", "login.html"))

@app.get("/dashboard")
async def show_dashboard():
    return FileResponse(os.path.join(frontend_dir, "page", "dashboard.html"))

app.mount("/", StaticFiles(directory=frontend_dir), name="frontend")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)