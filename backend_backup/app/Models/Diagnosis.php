<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Diagnosis extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'device_id',
        'diagnosis_uuid',
        'battery_health',
        'screen_condition',
        'hardware_condition',
        'identified_issues',
        'ai_analysis',
        'confidence_score',
        'life_cycle_stage',
        'remaining_useful_life',
        'environmental_impact',
    ];

    protected $casts = [
        'battery_health' => 'decimal:2',
        'confidence_score' => 'decimal:2',
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

    public function valueEstimation()
    {
        return $this->hasOne(ValueEstimation::class);
    }

    public function passports()
    {
        return $this->hasMany(DevicePassport::class, 'last_diagnosis_id');
    }
}
