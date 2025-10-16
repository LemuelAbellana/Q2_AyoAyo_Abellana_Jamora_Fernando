@echo off
echo ============================================
echo AyoAyo Backend Installation Script
echo ============================================
echo.

REM Check if we're in the correct directory
if not exist "lib" (
    echo ERROR: Please run this script from the MobileDev_AyoAyo root directory
    pause
    exit /b 1
)

echo Step 1: Backing up current backend files...
if exist "backend_custom" (
    rmdir /s /q backend_custom
)
if exist "backend" (
    move backend backend_custom
)

echo.
echo Step 2: Installing fresh Laravel...
echo This will take a few minutes...
composer create-project laravel/laravel backend "10.*"

if errorlevel 1 (
    echo ERROR: Failed to install Laravel
    echo Please ensure Composer is installed and in your PATH
    pause
    exit /b 1
)

cd backend

echo.
echo Step 3: Installing Laravel Sanctum...
composer require laravel/sanctum

echo.
echo Step 4: Publishing Sanctum configuration...
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

echo.
echo Step 5: Copying custom files...

REM Delete default migrations
del /q database\migrations\*.php 2>nul

REM Create Api directory
mkdir app\Http\Controllers\Api 2>nul

echo.
echo ============================================
echo IMPORTANT: Manual File Copy Required
echo ============================================
echo.
echo Please copy these files from backend_custom to backend:
echo.
echo 1. All files from backend_custom\database\migrations\
echo    TO: backend\database\migrations\
echo.
echo 2. All files from backend_custom\app\Models\
echo    TO: backend\app\Models\
echo.
echo 3. All files from backend_custom\app\Http\Controllers\Api\
echo    TO: backend\app\Http\Controllers\Api\
echo.
echo 4. backend_custom\routes\api.php
echo    TO: backend\routes\api.php
echo.
echo 5. backend_custom\config\cors.php
echo    TO: backend\config\cors.php
echo.
echo 6. backend_custom\app\Http\Kernel.php
echo    TO: backend\app\Http\Kernel.php
echo.
echo 7. backend_custom\.env.example
echo    TO: backend\.env.example
echo.

pause

echo.
echo Step 6: Setting up environment...
copy .env.example .env
php artisan key:generate

echo.
echo ============================================
echo Next Steps:
echo ============================================
echo.
echo 1. Edit backend\.env file with your database credentials
echo 2. Create database: mysql -u root -p -e "CREATE DATABASE ayoayo_db"
echo 3. Run migrations: cd backend && php artisan migrate
echo 4. Start server: php artisan serve
echo 5. Test: curl http://localhost:8000/api/v1/health
echo.
echo ============================================

cd ..
pause
