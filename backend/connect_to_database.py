# backend/database.py
import pyodbc

# Cấu hình chuỗi kết nối
SERVER = 'MSI\\SQLEXPRESS'
DATABASE = 'AIFinance'
CONN_STR = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={SERVER};"
    f"Database={DATABASE};"
    "Trusted_Connection=yes;"
)

def get_db_connection():
    """Hàm tạo kết nối đến SQL Server"""
    conn = pyodbc.connect(CONN_STR)
    return conn