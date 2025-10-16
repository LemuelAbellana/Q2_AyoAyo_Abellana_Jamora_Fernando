@echo off
echo ========================================
echo  Testing AyoAyo Fixes
echo ========================================
echo.

echo [1/5] Checking backend status...
curl -s http://localhost:8000/api/v1/health
if %errorlevel% neq 0 (
    echo ERROR: Backend not running!
    echo Please start it with: cd backend ^&^& php artisan serve
    pause
    exit /b 1
)
echo.
echo Backend: OK
echo.

echo [2/5] Checking database connection...
cd backend
php artisan tinker --execute="DB::connection()->getPdo(); echo 'Database: OK';" 2>&1 | findstr /C:"Database: OK"
if %errorlevel% neq 0 (
    echo ERROR: Database connection failed!
    pause
    exit /b 1
)
cd ..
echo.

echo [3/5] Checking users in database...
cd backend
php artisan tinker --execute="echo 'Total users: ' . DB::table('users')->count();"
echo.
echo Recent users:
php artisan tinker --execute="DB::table('users')->select('email', 'display_name')->latest()->limit(3)->get()->each(function($u) { echo $u->email . ' => ' . $u->display_name . PHP_EOL; });"
cd ..
echo.

echo [4/5] Checking Google OAuth configuration...
echo Client ID in web/index.html:
findstr "google-signin-client_id" web\index.html
echo.
echo Google Identity Services script:
findstr "gsi/client" web\index.html
echo.

echo [5/5] Checking API configuration...
echo Gemini API Key (first 20 chars):
findstr "geminiApiKey" lib\config\api_config.dart | findstr /V "//"
echo.
echo Backend API enabled:
findstr "useBackendApi" lib\config\api_config.dart | findstr /V "//"
echo.

echo ========================================
echo  Test Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get
echo 3. Run: flutter run -d chrome
echo 4. Try Google Sign-In and check console logs
echo.
pause
