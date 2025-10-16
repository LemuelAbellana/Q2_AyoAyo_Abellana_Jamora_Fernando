<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Device extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_model',
        'manufacturer',
        'year_of_release',
        'operating_system',
        'category',
        'base_value',
    ];

    protected $casts = [
        'year_of_release' => 'integer',
        'base_value' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function images()
    {
        return $this->hasMany(DeviceImage::class);
    }

    public function diagnoses()
    {
        return $this->hasMany(Diagnosis::class);
    }

    public function passports()
    {
        return $this->hasMany(DevicePassport::class);
    }
}
