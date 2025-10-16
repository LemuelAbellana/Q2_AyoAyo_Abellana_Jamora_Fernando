<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('devices', function (Blueprint $table) {
            $table->id();
            $table->string('device_model');
            $table->string('manufacturer');
            $table->integer('year_of_release')->nullable();
            $table->string('operating_system')->nullable();
            $table->string('category')->nullable();
            $table->decimal('base_value', 10, 2)->nullable();
            $table->timestamps();

            $table->index('device_model');
            $table->index('manufacturer');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('devices');
    }
};
