<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeviceRecognitionHistory extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $table = 'device_recognition_history';

    protected $fillable = [
        'user_id',
        'device_model',
        'manufacturer',
        'year_of_release',
        'operating_system',
        'confidence_score',
        'analysis_details',
        'image_paths',
        'recognition_timestamp',
        'device_passport_id',
        'is_saved',
    ];

    protected $casts = [
        'year_of_release' => 'integer',
        'confidence_score' => 'decimal:2',
        'image_paths' => 'array',
        'recognition_timestamp' => 'datetime',
        'is_saved' => 'boolean',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function devicePassport()
    {
        return $this->belongsTo(DevicePassport::class);
    }
}
