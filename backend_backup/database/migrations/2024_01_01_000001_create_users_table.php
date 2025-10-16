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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('uid')->unique();
            $table->string('email')->unique();
            $table->string('display_name')->nullable();
            $table->text('photo_url')->nullable();
            $table->string('auth_provider')->default('email');
            $table->string('provider_id')->nullable();
            $table->string('password_hash')->nullable();
            $table->boolean('email_verified')->default(false);
            $table->timestamp('last_login_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->json('preferences')->nullable();
            $table->timestamps();

            $table->index('email');
            $table->index('uid');
            $table->index('auth_provider');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
