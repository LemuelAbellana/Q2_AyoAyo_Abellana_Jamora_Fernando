<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'uid',
        'email',
        'display_name',
        'photo_url',
        'auth_provider',
        'provider_id',
        'password_hash',
        'email_verified',
        'last_login_at',
        'is_active',
        'preferences',
    ];

    protected $hidden = [
        'password_hash',
    ];

    protected $casts = [
        'email_verified' => 'boolean',
        'is_active' => 'boolean',
        'preferences' => 'array',
        'last_login_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function devicePassports()
    {
        return $this->hasMany(DevicePassport::class);
    }

    public function diagnoses()
    {
        return $this->hasMany(Diagnosis::class);
    }

    public function recognitionHistory()
    {
        return $this->hasMany(DeviceRecognitionHistory::class);
    }

    public function uploadedImages()
    {
        return $this->hasMany(DeviceImage::class, 'uploaded_by');
    }
}
