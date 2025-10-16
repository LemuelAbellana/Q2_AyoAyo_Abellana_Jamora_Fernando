<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ValueEstimation extends Model
{
    use HasFactory;

    protected $fillable = [
        'diagnosis_id',
        'current_value',
        'post_repair_value',
        'parts_value',
        'repair_cost',
        'recycling_value',
        'currency',
        'market_positioning',
        'depreciation_rate',
    ];

    protected $casts = [
        'current_value' => 'decimal:2',
        'post_repair_value' => 'decimal:2',
        'parts_value' => 'decimal:2',
        'repair_cost' => 'decimal:2',
        'recycling_value' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function diagnosis()
    {
        return $this->belongsTo(Diagnosis::class);
    }
}
