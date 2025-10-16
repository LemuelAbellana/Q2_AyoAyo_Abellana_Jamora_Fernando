# Backend Setup - Fixed Installation Guide

## The Problem

You're seeing the error: `Could not open input file: artisan`

This happens because we created the backend files structure, but Laravel itself isn't installed yet.

## The Solution (Two Options)

### Option 1: Automated Script (Recommended)

Run the installation script I created:

```bash
cd "f:\Downloads\MobileDev_AyoAyo"
install-backend.bat
```

This will:
1. Backup current backend files
2. Install fresh Laravel
3. Guide you through copying custom files

### Option 2: Manual Installation (More Control)

Follow these steps carefully:

#### Step 1: Backup Current Backend Files

```bash
cd "f:\Downloads\MobileDev_AyoAyo"
move backend backend_backup
```

#### Step 2: Install Fresh Laravel

```bash
composer create-project laravel/laravel backend "10.*"
```

**Wait for this to complete (2-3 minutes)**

#### Step 3: Navigate to Backend

```bash
cd backend
```

#### Step 4: Install Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

#### Step 5: Copy Custom Files

Now copy your custom files from `backend_backup` to `backend`:

**Migrations:** (Delete default migrations first)
```bash
del database\migrations\*.php
copy ..\backend_backup\database\migrations\* database\migrations\
```

**Models:**
```bash
copy ..\backend_backup\app\Models\* app\Models\
```

**Controllers:**
```bash
mkdir app\Http\Controllers\Api
copy ..\backend_backup\app\Http\Controllers\Api\* app\Http\Controllers\Api\
```

**Routes:**
```bash
copy ..\backend_backup\routes\api.php routes\api.php
```

**Config:**
```bash
copy ..\backend_backup\config\cors.php config\cors.php
copy ..\backend_backup\app\Http\Kernel.php app\Http\Kernel.php
```

**Environment:**
```bash
copy ..\backend_backup\.env.example .env.example
```

#### Step 6: Configure Environment

```bash
copy .env.example .env
php artisan key:generate
```

Edit `.env` file and set:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=ayoayo_db
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
```

#### Step 7: Create Database

```bash
mysql -u root -p -e "CREATE DATABASE ayoayo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

#### Step 8: Run Migrations

```bash
php artisan migrate
```

#### Step 9: Start Server

```bash
php artisan serve
```

#### Step 10: Test

In a new terminal:
```bash
curl http://localhost:8000/api/v1/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "AyoAyo API is running",
  "version": "1.0.0"
}
```

## ✅ Success!

Your backend is now running on `http://localhost:8000`

---

## Quick Reference Commands

### Check Prerequisites
```bash
php -v           # Should be 8.1+
composer -v      # Should be installed
mysql --version  # Should be 5.7+
```

### Start Backend
```bash
cd backend
php artisan serve
```

### View Logs
```bash
tail -f storage\logs\laravel.log
```

### Reset Database
```bash
php artisan migrate:fresh
```

### Check Migration Status
```bash
php artisan migrate:status
```

---

## Troubleshooting

### "composer command not found"
Install Composer from https://getcomposer.org/download/

### "php command not found"
Install PHP 8.1+ from https://windows.php.net/download/

### "mysql command not found"
Install MySQL or use XAMPP (includes MySQL)

### "Access denied for user 'root'"
Check MySQL password in `.env` file

### Port 8000 already in use
```bash
php artisan serve --port=8001
```

---

## What's Different Now?

**Before:** We created the file structure but without Laravel core
**After:** Fresh Laravel installation + our custom files = Working backend

The custom files are designed to work with Laravel, but Laravel itself needs to be installed first.

---

## Next Steps After Installation

1. ✅ Backend running
2. Test API with curl/Postman
3. Follow [LARAVEL_INTEGRATION_GUIDE.md](./LARAVEL_INTEGRATION_GUIDE.md) for Flutter integration
4. Test end-to-end flow

Good luck! 🚀
