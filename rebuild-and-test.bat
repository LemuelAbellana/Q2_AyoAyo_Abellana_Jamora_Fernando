@echo off
echo ========================================
echo  AyoAyo - Clean Rebuild and Test
echo ========================================
echo.

echo Step 1: Cleaning Flutter build cache...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo Done!
echo.

echo Step 2: Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)
echo Done!
echo.

echo Step 3: Checking backend...
curl -s http://localhost:8000/api/v1/health >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Backend not running!
    echo Starting backend in new window...
    start "AyoAyo Backend" cmd /k "cd backend && php artisan serve"
    echo Waiting 5 seconds for backend to start...
    timeout /t 5 /nobreak >nul
) else (
    echo Backend already running!
)
echo.

echo Step 4: Verifying backend connection...
curl -s http://localhost:8000/api/v1/health
if %errorlevel% neq 0 (
    echo ERROR: Backend still not responding!
    echo Please start backend manually: cd backend ^&^& php artisan serve
    pause
    exit /b 1
)
echo Done!
echo.

echo ========================================
echo  Ready to Run!
echo ========================================
echo.
echo Backend: Running on http://localhost:8000
echo.
echo To run Flutter app:
echo   flutter run -d chrome
echo.
echo IMPORTANT:
echo 1. Open browser console (F12) BEFORE signing in
echo 2. Watch for detailed logs during Google Sign-In
echo 3. Check FIXES_APPLIED.md for troubleshooting
echo.
echo Press any key to run Flutter app now, or Ctrl+C to exit
pause >nul

echo.
echo Starting Flutter app...
call flutter run -d chrome
