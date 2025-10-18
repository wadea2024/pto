@echo off
REM ================================================
REM   PTO Server - OPTIMIZED VERSION
REM   Fast startup without debug mode
REM ================================================

echo.
echo ========================================
echo   Starting PTO Server (FAST MODE)
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Activate virtual environment if it exists
if exist ".venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call .venv\Scripts\activate.bat
) else (
    echo WARNING: Virtual environment not found
    echo Please run: python -m venv .venv
)

REM Start the server
echo.
echo Starting server...
echo Server will be available at: http://localhost:5000
echo.
echo PERFORMANCE MODE: Debug disabled for faster response
echo.

python run_windows.py

pause
