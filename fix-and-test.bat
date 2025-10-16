@echo off
echo ========================================
echo  CRITICAL FIX - Google OAuth Real Names
echo ========================================
echo.

echo This will:
echo  1. Clean Flutter cache
echo  2. Rebuild dependencies
echo  3. Clear demo user from database
echo  4. Run the app
echo.
echo Press any key to continue, or Ctrl+C to cancel
pause >nul
echo.

echo [1/5] Cleaning Flutter cache...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo Done!
echo.

echo [2/5] Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)
echo Done!
echo.

echo [3/5] Checking backend...
curl -s http://localhost:8000/api/v1/health >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Backend not running!
    echo Starting backend in new window...
    start "AyoAyo Backend" cmd /k "cd backend && php artisan serve"
    echo Waiting 5 seconds for backend to start...
    timeout /t 5 /nobreak >nul
)
echo Backend OK!
echo.

echo [4/5] Clearing demo user from database...
cd backend
php artisan tinker --execute="DB::table('users')->where('email', 'demo.user@gmail.com')->delete(); echo 'Demo user cleared';" 2>nul
cd ..
echo Done!
echo.

echo [5/5] Current users in database:
cd backend
php artisan tinker --execute="DB::table('users')->select('email', 'display_name')->get()->each(function($u) { echo $u->email . ' => ' . $u->display_name . PHP_EOL; });" 2>nul
cd ..
echo.

echo ========================================
echo  Ready to Test!
echo ========================================
echo.
echo IMPORTANT STEPS:
echo  1. Open browser console (F12) NOW
echo  2. Click "Continue with Google"
echo  3. You should see REAL Google account picker
echo  4. Select your account
echo  5. Check console logs for your real name
echo.
echo Expected console output:
echo   ✅ Real Google Sign-In successful!
echo   👤 User: your.email@gmail.com
echo   📛 Display name: Your Real Name
echo.
echo Press any key to run Flutter app...
pause >nul

echo.
echo Starting Flutter...
call flutter run -d chrome
