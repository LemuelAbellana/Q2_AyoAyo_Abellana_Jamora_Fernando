<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_recognition_history', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('device_model');
            $table->string('manufacturer');
            $table->integer('year_of_release')->nullable();
            $table->string('operating_system')->nullable();
            $table->decimal('confidence_score', 3, 2)->nullable();
            $table->text('analysis_details')->nullable();
            $table->json('image_paths')->nullable();
            $table->timestamp('recognition_timestamp')->useCurrent();
            $table->foreignId('device_passport_id')->nullable()->constrained('device_passports')->onDelete('set null');
            $table->boolean('is_saved')->default(false);

            $table->index('user_id');
            $table->index('recognition_timestamp');
            $table->index('manufacturer');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_recognition_history');
    }
};
