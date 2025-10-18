@echo off
chcp 65001 >nul
echo ================================================
echo Starting PTO Server on Windows...
echo ================================================
echo.

REM Activate virtual environment if exists
if exist .venv\Scripts\activate.bat (
    call .venv\Scripts\activate.bat
    echo Virtual environment activated.
) else (
    echo No virtual environment found. Using system Python.
)

echo.
echo Starting server...
python run_windows.py

pause
