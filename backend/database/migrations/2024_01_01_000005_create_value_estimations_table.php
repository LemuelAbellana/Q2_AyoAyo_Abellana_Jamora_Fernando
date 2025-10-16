<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('value_estimations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('diagnosis_id')->constrained()->onDelete('cascade');
            $table->decimal('current_value', 10, 2)->nullable();
            $table->decimal('post_repair_value', 10, 2)->nullable();
            $table->decimal('parts_value', 10, 2)->nullable();
            $table->decimal('repair_cost', 10, 2)->nullable();
            $table->decimal('recycling_value', 10, 2)->nullable();
            $table->string('currency')->default('PHP');
            $table->string('market_positioning')->nullable();
            $table->string('depreciation_rate')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('value_estimations');
    }
};
