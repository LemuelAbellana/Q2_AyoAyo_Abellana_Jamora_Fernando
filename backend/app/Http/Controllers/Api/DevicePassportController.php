<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DevicePassport;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class DevicePassportController extends Controller
{
    /**
     * Get all device passports for a user
     * Matches Flutter: device_provider.dart -> loadDevices()
     */
    public function index(Request $request)
    {
        try {
            $userId = $request->input('userId');

            if (!$userId) {
                return response()->json([
                    'error' => 'userId is required',
                ], 400);
            }

            $user = User::where('uid', $userId)->first();

            if (!$user) {
                return response()->json([
                    'error' => 'User not found',
                ], 404);
            }

            // Get all active device passports with relationships
            $passports = DevicePassport::where('user_id', $user->id)
                ->where('is_active', true)
                ->with([
                    'device.images',
                    'lastDiagnosis.valueEstimation'
                ])
                ->orderBy('created_at', 'desc')
                ->get();

            // Format response to match Flutter's DevicePassport model
            $formattedPassports = $passports->map(function ($passport) {
                $diagnosis = $passport->lastDiagnosis;
                $device = $passport->device;
                $imageUrls = $device->images->pluck('image_path')->toArray();

                return [
                    'id' => $passport->passport_uuid,
                    'userId' => $passport->user->uid,
                    'deviceModel' => $device->device_model,
                    'manufacturer' => $device->manufacturer,
                    'yearOfRelease' => $device->year_of_release,
                    'operatingSystem' => $device->operating_system,
                    'imageUrls' => $imageUrls,
                    'lastDiagnosis' => [
                        'deviceModel' => $device->device_model,
                        'imageUrls' => $imageUrls,
                        'aiAnalysis' => $diagnosis->ai_analysis ?? 'No analysis available',
                        'confidenceScore' => (float) ($diagnosis->confidence_score ?? 0.8),
                        'deviceHealth' => [
                            'screenCondition' => $diagnosis->screen_condition ?? 'unknown',
                            'hardwareCondition' => $diagnosis->hardware_condition ?? 'unknown',
                            'identifiedIssues' => $diagnosis->identified_issues ? explode(',', $diagnosis->identified_issues) : [],
                            'lifeCycleStage' => $diagnosis->life_cycle_stage ?? 'Active',
                            'remainingUsefulLife' => $diagnosis->remaining_useful_life ?? '2-3 years',
                            'environmentalImpact' => $diagnosis->environmental_impact ?? 'Low carbon footprint',
                        ],
                        'valueEstimation' => [
                            'currentValue' => (float) ($diagnosis->valueEstimation->current_value ?? 5000.0),
                            'postRepairValue' => (float) ($diagnosis->valueEstimation->post_repair_value ?? 6000.0),
                            'partsValue' => (float) ($diagnosis->valueEstimation->parts_value ?? 2000.0),
                            'repairCost' => (float) ($diagnosis->valueEstimation->repair_cost ?? 1000.0),
                            'recyclingValue' => (float) ($diagnosis->valueEstimation->recycling_value ?? 500.0),
                            'currency' => $diagnosis->valueEstimation->currency ?? 'PHP',
                            'marketPositioning' => $diagnosis->valueEstimation->market_positioning ?? 'Mid-range',
                            'depreciationRate' => $diagnosis->valueEstimation->depreciation_rate ?? '15% per year',
                        ],
                        'recommendations' => [],
                    ],
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $formattedPassports,
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching device passports', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'error' => 'Failed to fetch device passports',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get a single device passport by ID
     */
    public function show(Request $request, string $passportUuid)
    {
        try {
            $passport = DevicePassport::where('passport_uuid', $passportUuid)
                ->with([
                    'device.images',
                    'lastDiagnosis.valueEstimation'
                ])
                ->first();

            if (!$passport) {
                return response()->json([
                    'error' => 'Device passport not found',
                ], 404);
            }

            $diagnosis = $passport->lastDiagnosis;
            $device = $passport->device;
            $imageUrls = $device->images->pluck('image_path')->toArray();

            $formattedPassport = [
                'id' => $passport->passport_uuid,
                'userId' => $passport->user->uid,
                'deviceModel' => $device->device_model,
                'manufacturer' => $device->manufacturer,
                'yearOfRelease' => $device->year_of_release,
                'operatingSystem' => $device->operating_system,
                'imageUrls' => $imageUrls,
                'lastDiagnosis' => [
                    'deviceModel' => $device->device_model,
                    'imageUrls' => $imageUrls,
                    'aiAnalysis' => $diagnosis->ai_analysis ?? 'No analysis available',
                    'confidenceScore' => (float) ($diagnosis->confidence_score ?? 0.8),
                    'deviceHealth' => [
                        'screenCondition' => $diagnosis->screen_condition ?? 'unknown',
                        'hardwareCondition' => $diagnosis->hardware_condition ?? 'unknown',
                        'identifiedIssues' => $diagnosis->identified_issues ? explode(',', $diagnosis->identified_issues) : [],
                        'lifeCycleStage' => $diagnosis->life_cycle_stage ?? 'Active',
                        'remainingUsefulLife' => $diagnosis->remaining_useful_life ?? '2-3 years',
                        'environmentalImpact' => $diagnosis->environmental_impact ?? 'Low carbon footprint',
                    ],
                    'valueEstimation' => [
                        'currentValue' => (float) ($diagnosis->valueEstimation->current_value ?? 5000.0),
                        'postRepairValue' => (float) ($diagnosis->valueEstimation->post_repair_value ?? 6000.0),
                        'partsValue' => (float) ($diagnosis->valueEstimation->parts_value ?? 2000.0),
                        'repairCost' => (float) ($diagnosis->valueEstimation->repair_cost ?? 1000.0),
                        'recyclingValue' => (float) ($diagnosis->valueEstimation->recycling_value ?? 500.0),
                        'currency' => $diagnosis->valueEstimation->currency ?? 'PHP',
                        'marketPositioning' => $diagnosis->valueEstimation->market_positioning ?? 'Mid-range',
                        'depreciationRate' => $diagnosis->valueEstimation->depreciation_rate ?? '15% per year',
                    ],
                    'recommendations' => [],
                ],
            ];

            return response()->json([
                'success' => true,
                'data' => $formattedPassport,
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching device passport', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Failed to fetch device passport',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete/deactivate a device passport
     * Matches Flutter: device_provider.dart -> removeDevice()
     */
    public function destroy(Request $request, string $passportUuid)
    {
        try {
            $passport = DevicePassport::where('passport_uuid', $passportUuid)->first();

            if (!$passport) {
                return response()->json([
                    'error' => 'Device passport not found',
                ], 404);
            }

            // Soft delete by setting is_active to false
            $passport->update(['is_active' => false]);

            Log::info('Device passport deactivated', [
                'passport_uuid' => $passportUuid,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Device passport removed successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('Error removing device passport', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Failed to remove device passport',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
