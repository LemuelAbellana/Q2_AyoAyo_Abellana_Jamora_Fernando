<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DevicePassport extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'device_id',
        'passport_uuid',
        'last_diagnosis_id',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function device()
    {
        return $this->belongsTo(Device::class);
    }

    public function lastDiagnosis()
    {
        return $this->belongsTo(Diagnosis::class, 'last_diagnosis_id');
    }

    public function recognitionHistory()
    {
        return $this->hasMany(DeviceRecognitionHistory::class);
    }
}
