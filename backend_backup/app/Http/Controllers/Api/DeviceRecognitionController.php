<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Device;
use App\Models\DeviceImage;
use App\Models\DevicePassport;
use App\Models\Diagnosis;
use App\Models\ValueEstimation;
use App\Models\DeviceRecognitionHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class DeviceRecognitionController extends Controller
{
    /**
     * Save recognized device from camera scan
     * This endpoint matches the Flutter flow: camera_device_recognition_service.dart -> saveRecognizedDevice()
     */
    public function saveRecognizedDevice(Request $request)
    {
        try {
            $validated = $request->validate([
                'userId' => 'required|string',
                'deviceModel' => 'required|string',
                'manufacturer' => 'required|string',
                'yearOfRelease' => 'nullable|integer',
                'operatingSystem' => 'required|string',
                'confidence' => 'required|numeric|min:0|max:1',
                'analysisDetails' => 'required|string',
                'imageUrls' => 'array',
                'imageUrls.*' => 'string',
            ]);

            return DB::transaction(function () use ($validated) {
                // Find or create user
                $user = \App\Models\User::where('uid', $validated['userId'])->first();
                if (!$user) {
                    return response()->json([
                        'error' => 'User not found',
                        'message' => 'Please log in to save device information'
                    ], 404);
                }

                // Create or find device
                $device = Device::firstOrCreate(
                    [
                        'device_model' => $validated['deviceModel'],
                        'manufacturer' => $validated['manufacturer'],
                    ],
                    [
                        'year_of_release' => $validated['yearOfRelease'] ?? now()->year,
                        'operating_system' => $validated['operatingSystem'],
                    ]
                );

                // Create diagnosis UUID
                $diagnosisUuid = 'diag_' . time() . '_' . Str::random(8);

                // Create diagnosis
                $diagnosis = Diagnosis::create([
                    'user_id' => $user->id,
                    'device_id' => $device->id,
                    'diagnosis_uuid' => $diagnosisUuid,
                    'screen_condition' => 'unknown',
                    'hardware_condition' => 'unknown',
                    'identified_issues' => '',
                    'ai_analysis' => $validated['analysisDetails'],
                    'confidence_score' => $validated['confidence'],
                    'life_cycle_stage' => 'assessment_needed',
                    'remaining_useful_life' => 'unknown',
                    'environmental_impact' => 'unknown',
                ]);

                // Estimate base value
                $baseValue = $this->estimateBaseValue($validated['manufacturer'], $validated['deviceModel']);

                // Create value estimation
                ValueEstimation::create([
                    'diagnosis_id' => $diagnosis->id,
                    'current_value' => $baseValue,
                    'post_repair_value' => $baseValue * 1.2,
                    'parts_value' => $baseValue * 0.4,
                    'repair_cost' => 2000.0,
                    'recycling_value' => 500.0,
                    'currency' => '₱',
                    'market_positioning' => 'needs_assessment',
                    'depreciation_rate' => 'standard',
                ]);

                // Create passport UUID
                $passportUuid = time();

                // Create device passport
                $passport = DevicePassport::create([
                    'user_id' => $user->id,
                    'device_id' => $device->id,
                    'passport_uuid' => (string) $passportUuid,
                    'last_diagnosis_id' => $diagnosis->id,
                    'is_active' => true,
                ]);

                // Save device images if provided
                if (!empty($validated['imageUrls'])) {
                    foreach ($validated['imageUrls'] as $imageUrl) {
                        DeviceImage::create([
                            'device_id' => $device->id,
                            'image_path' => $imageUrl,
                            'image_type' => 'diagnostic',
                            'uploaded_by' => $user->id,
                        ]);
                    }
                }

                // Save recognition history
                DeviceRecognitionHistory::create([
                    'user_id' => $user->id,
                    'device_model' => $validated['deviceModel'],
                    'manufacturer' => $validated['manufacturer'],
                    'year_of_release' => $validated['yearOfRelease'],
                    'operating_system' => $validated['operatingSystem'],
                    'confidence_score' => $validated['confidence'],
                    'analysis_details' => $validated['analysisDetails'],
                    'image_paths' => $validated['imageUrls'] ?? [],
                    'device_passport_id' => $passport->id,
                    'is_saved' => true,
                ]);

                Log::info('Device saved successfully', [
                    'passport_id' => $passportUuid,
                    'device_model' => $validated['deviceModel'],
                    'user_id' => $validated['userId'],
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Device saved successfully',
                    'devicePassportId' => (string) $passportUuid,
                    'data' => [
                        'id' => $passportUuid,
                        'deviceModel' => $validated['deviceModel'],
                        'manufacturer' => $validated['manufacturer'],
                    ]
                ], 201);
            });
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'error' => 'Validation failed',
                'message' => $e->getMessage(),
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error saving recognized device', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'error' => 'Failed to save device',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get recognition history for a user
     */
    public function getRecognitionHistory(Request $request)
    {
        try {
            $userId = $request->input('userId');
            $limit = $request->input('limit', 10);

            $user = \App\Models\User::where('uid', $userId)->first();
            if (!$user) {
                return response()->json([
                    'error' => 'User not found'
                ], 404);
            }

            $history = DeviceRecognitionHistory::where('user_id', $user->id)
                ->orderBy('recognition_timestamp', 'desc')
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $history,
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching recognition history', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Failed to fetch recognition history',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Estimate base value based on manufacturer and model
     * This matches the logic in camera_device_recognition_service.dart
     */
    private function estimateBaseValue(string $manufacturer, string $deviceModel): float
    {
        $model = strtolower($deviceModel);

        if ($manufacturer === 'Apple') {
            if (str_contains($model, 'pro max')) return 65000.0;
            if (str_contains($model, 'pro')) return 55000.0;
            if (str_contains($model, 'plus')) return 45000.0;
            if (str_contains($model, '15')) return 40000.0;
            if (str_contains($model, '14')) return 35000.0;
            if (str_contains($model, '13')) return 30000.0;
            return 25000.0;
        }

        if ($manufacturer === 'Samsung') {
            if (str_contains($model, 'ultra')) return 50000.0;
            if (str_contains($model, 'plus')) return 35000.0;
            if (str_contains($model, 's24') || str_contains($model, 's23')) return 30000.0;
            if (str_contains($model, 'note')) return 35000.0;
            if (str_contains($model, 'a5') || str_contains($model, 'a7')) return 15000.0;
            return 20000.0;
        }

        if ($manufacturer === 'Xiaomi') {
            if (str_contains($model, 'pro')) return 25000.0;
            if (str_contains($model, 'ultra')) return 30000.0;
            return 18000.0;
        }

        return 15000.0;
    }
}
