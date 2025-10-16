<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('diagnoses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('device_id')->constrained()->onDelete('cascade');
            $table->string('diagnosis_uuid')->unique();
            $table->decimal('battery_health', 5, 2)->nullable();
            $table->string('screen_condition')->nullable();
            $table->string('hardware_condition')->nullable();
            $table->text('identified_issues')->nullable();
            $table->text('ai_analysis')->nullable();
            $table->decimal('confidence_score', 3, 2)->nullable();
            $table->string('life_cycle_stage')->nullable();
            $table->string('remaining_useful_life')->nullable();
            $table->text('environmental_impact')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('device_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('diagnoses');
    }
};
