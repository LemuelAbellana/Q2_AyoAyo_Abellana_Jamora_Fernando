# Laravel Backend Installation Guide

## 🚨 IMPORTANT: Follow These Steps in Order

The backend files have been prepared, but Laravel needs to be installed first. Follow these steps carefully.

## Step 1: Clean Installation

```bash
# Navigate to the parent directory
cd "f:\Downloads\MobileDev_AyoAyo"

# Remove the backend directory if it exists
rmdir /s /q backend

# Create a fresh Laravel installation
composer create-project laravel/laravel backend "10.*"
```

This will take a few minutes and install a fresh Laravel 10 project.

## Step 2: Navigate to Backend Directory

```bash
cd backend
```

## Step 3: Install Laravel Sanctum

```bash
composer require laravel/sanctum
```

## Step 4: Publish Sanctum Configuration

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

## Step 5: Copy Custom Files

Now we need to copy our custom backend files. I'll create a PowerShell script to do this.

Create a file called `install-backend.ps1` in the `backend` directory with this content:

```powershell
# Delete default files
Remove-Item -Path ".\database\migrations\*" -Force
Remove-Item -Path ".\app\Models\User.php" -Force

# Copy migration files (you'll need to create these)
Write-Host "Ready to copy migration files..."
Write-Host "Please copy the 7 migration files from the original backend/database/migrations folder"
Pause

# Copy model files
Write-Host "Ready to copy model files..."
Write-Host "Please copy the 7 model files from the original backend/app/Models folder"
Pause

# Copy controller files
Write-Host "Ready to copy controller files..."
Write-Host "Please create the Api directory and copy controller files"
Pause

Write-Host "Installation complete!"
```

## Step 6: Manual File Copy (Easier Approach)

Since we need to copy several files, let's do it manually:

### 6.1 Copy Migrations

Copy these files from your backup to `backend/database/migrations/`:
- `2024_01_01_000001_create_users_table.php`
- `2024_01_01_000002_create_devices_table.php`
- `2024_01_01_000003_create_device_images_table.php`
- `2024_01_01_000004_create_diagnoses_table.php`
- `2024_01_01_000005_create_value_estimations_table.php`
- `2024_01_01_000006_create_device_passports_table.php`
- `2024_01_01_000007_create_device_recognition_history_table.php`

First, delete existing migrations:
```bash
del database\migrations\*.php
```

### 6.2 Copy Models

Replace `app/Models/User.php` and add other models:
- `app/Models/User.php`
- `app/Models/Device.php`
- `app/Models/DeviceImage.php`
- `app/Models/Diagnosis.php`
- `app/Models/ValueEstimation.php`
- `app/Models/DevicePassport.php`
- `app/Models/DeviceRecognitionHistory.php`

### 6.3 Create API Controllers

Create directory:
```bash
mkdir app\Http\Controllers\Api
```

Copy controllers:
- `app/Http/Controllers/Api/AuthController.php`
- `app/Http/Controllers/Api/DeviceRecognitionController.php`
- `app/Http/Controllers/Api/DevicePassportController.php`

### 6.4 Copy Routes

Replace `routes/api.php` with the custom version.

### 6.5 Copy Config

Replace `config/cors.php` with the custom version.

Replace `app/Http/Kernel.php` with the custom version.

### 6.6 Copy Environment

Copy `.env.example` (custom version).

## Step 7: Configure Environment

```bash
# Copy .env.example to .env
copy .env.example .env

# Generate application key
php artisan key:generate
```

Edit `.env` file and set your database credentials:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=ayoayo_db
DB_USERNAME=root
DB_PASSWORD=your_password

GEMINI_API_KEY=AIzaSyCk6Ybk9etcuUz7n9VFWPrfPuZ4zNil9kQ
```

## Step 8: Create Database

```bash
mysql -u root -p -e "CREATE DATABASE ayoayo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

Or use phpMyAdmin to create the database.

## Step 9: Run Migrations

```bash
php artisan migrate
```

## Step 10: Start Server

```bash
php artisan serve
```

## Step 11: Test API

```bash
curl http://localhost:8000/api/v1/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "AyoAyo API is running"
}
```

## ✅ Success!

If you see the health check response, your backend is ready!

---

## 🔧 Alternative: Use the Installation Script (Recommended)

I'll create an automated installation script for you.
