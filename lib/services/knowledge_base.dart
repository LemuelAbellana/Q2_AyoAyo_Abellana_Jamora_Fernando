class KnowledgeBase {
  // Enhanced RAG Knowledge Base with structured data
  static const Map<String, dynamic> deviceDatabase = {
    'iphone': {
      'models': {
        'iphone_15': {
          'baseValue': 55000,
          'releaseYear': 2023,
          'commonIssues': [
            'battery optimization',
            'thermal management',
            'ios bugs',
          ],
          'repairCosts': {'screen': 12000, 'battery': 2500, 'camera': 8000},
          'marketDemand': 'very_high',
          'depreciationRate': 0.85,
        },
        'iphone_14': {
          'baseValue': 45000,
          'releaseYear': 2022,
          'commonIssues': [
            'green line display',
            'camera focus',
            'battery life',
          ],
          'repairCosts': {'screen': 10000, 'battery': 2300, 'camera': 7000},
          'marketDemand': 'high',
          'depreciationRate': 0.8,
        },
        'iphone_13': {
          'baseValue': 32000,
          'releaseYear': 2021,
          'commonIssues': [
            'pink screen',
            'battery degradation',
            'speaker crackling',
          ],
          'repairCosts': {'screen': 8000, 'battery': 2000, 'camera': 6000},
          'marketDemand': 'high',
          'depreciationRate': 0.75,
        },
        'iphone_12': {
          'baseValue': 28000,
          'releaseYear': 2020,
          'commonIssues': [
            'purple flare',
            'wireless charging',
            'ceramic shield damage',
          ],
          'repairCosts': {'screen': 7000, 'battery': 1800, 'camera': 5500},
          'marketDemand': 'moderate',
          'depreciationRate': 0.7,
        },
        'iphone_11': {
          'baseValue': 18000,
          'releaseYear': 2019,
          'commonIssues': [
            'lcd discoloration',
            'battery swelling',
            'logic board',
          ],
          'repairCosts': {'screen': 4500, 'battery': 1500, 'camera': 4000},
          'marketDemand': 'moderate',
          'depreciationRate': 0.65,
        },
      },
    },
    'samsung': {
      'models': {
        'galaxy_s24': {
          'baseValue': 45000,
          'releaseYear': 2024,
          'commonIssues': ['one ui bugs', 'heating', 'camera app crashes'],
          'repairCosts': {'screen': 15000, 'battery': 2000, 'camera': 8000},
          'marketDemand': 'high',
          'depreciationRate': 0.8,
        },
        'galaxy_s23': {
          'baseValue': 35000,
          'releaseYear': 2023,
          'commonIssues': [
            'green line',
            'battery optimization',
            'fingerprint sensor',
          ],
          'repairCosts': {'screen': 12000, 'battery': 1800, 'camera': 7000},
          'marketDemand': 'moderate',
          'depreciationRate': 0.75,
        },
        'galaxy_a54': {
          'baseValue': 15000,
          'releaseYear': 2023,
          'commonIssues': ['slow charging', 'camera lag', 'storage management'],
          'repairCosts': {'screen': 6000, 'battery': 1200, 'camera': 3500},
          'marketDemand': 'high',
          'depreciationRate': 0.7,
        },
      },
    },
    'xiaomi': {
      'models': {
        'mi_13': {
          'baseValue': 25000,
          'releaseYear': 2023,
          'commonIssues': [
            'miui optimization',
            'camera processing',
            'thermal throttling',
          ],
          'repairCosts': {'screen': 8000, 'battery': 1500, 'camera': 5000},
          'marketDemand': 'moderate',
          'depreciationRate': 0.75,
        },
        'redmi_note_12': {
          'baseValue': 12000,
          'releaseYear': 2023,
          'commonIssues': ['ghost touch', 'charging port', 'software bugs'],
          'repairCosts': {'screen': 4000, 'battery': 1000, 'camera': 2500},
          'marketDemand': 'high',
          'depreciationRate': 0.7,
        },
      },
    },
  };

  static const Map<String, dynamic> marketIntelligence = {
    'local_market': {
      'marketMultiplier': 0.95, // Slightly lower than major city prices
      'popularBrands': ['iphone', 'samsung', 'xiaomi', 'oppo', 'vivo'],
      'repairShops': 150,
      'averageRepairTime': '3-7 days',
      'preferredConditions': ['excellent', 'good'],
      'seasonalDemand': {
        'high': [
          'december',
          'january',
          'june',
        ], // Holiday and graduation seasons
        'moderate': ['february', 'march', 'july', 'august'],
        'low': ['april', 'may', 'september', 'october', 'november'],
      },
    },
  };

  static const String ragData = ''';
  ENHANCED DEVICE DIAGNOSTIC KNOWLEDGE BASE (Local Market Focus):

  **1. Common Device Issues & Symptoms:**
  - **Battery Degradation:** Rapid discharge (<80% health), overheating during charging, unexpected shutdowns. Common after 2-3 years.
  - **Screen Damage:**
    - *LCD/OLED Failure:* Black spots, green lines, unresponsive touch, "ghost touch."
    - *Physical Damage:* Visible cracks, deep scratches.
  - **Water Damage:** Discolored moisture indicators (usually inside SIM tray), foggy camera lens, corroded charging port, unresponsive buttons.
  - **Software Issues:** Frequent app crashes, slow UI, boot loops, failed updates.
  - **Hardware Failures:**
    - *Speaker/Mic:* Crackling audio, no sound during calls.
    - *Camera:* Blurry photos, black screen in camera app, focus issues.
    - *Charging Port:* Loose connection, requires specific cable angle to charge, no charging.
  - **Motherboard/Logic Board Issues:** No power, no display even with a new screen, overheating with no specific cause.

  **2. Device Value Factors (Local Context):**
  - **Age & Model:** Newer models (iPhone 12+, Samsung S21+) retain value well. Older models (iPhone 8, Samsung S9) have lower but stable value.
  - **Market Demand:** High demand for iPhones, Samsung A-series, and budget brands like Xiaomi/Realme.
  - **Condition:**
    - *Pristine/Mint:* No visible flaws. Highest value.
    - *Good:* Minor, barely visible scratches.
    - *Fair:* Visible scratches, minor dents.
    - *Damaged:* Cracked screen/back, major dents, known hardware issues. Lowest value.
  - **Storage Capacity:** Higher storage (128GB+) significantly increases value.
  - **"GPP" / Carrier Locked Units:** Lower value than "Factory Unlocked" (FU) units.
  - **Repairs History:** Use of non-original parts (replacement screens/batteries) can lower value.

  **3. Repair Cost Estimates (Local price reference):**
  - **iPhone Screen:**
    - *LCD (iPhone 8-11):* ₱2,500 - ₱4,000
    - *OLED (iPhone X-14):* ₱5,000 - ₱12,000
  - **Android Screen:**
    - *LCD (Budget models):* ₱1,500 - ₱3,000
    - *OLED (Samsung A-series, etc.):* ₱3,500 - ₱7,000
    - *Curved OLED (Flagships):* ₱8,000 - ₱15,000
  - **Battery Replacement:**
    - *iPhone:* ₱1,200 - ₱2,500
    - *Android:* ₱800 - ₱2,000
  - **Charging Port Flex:** ₱800 - ₱1,800
  - **Water Damage Cleaning/Diagnosis:** ₱1,500 - ₱3,000 (no guarantee of fix)
  - **Motherboard Repair (Micro-soldering):* ₱3,000 - ₱10,000+ (high risk)

  **4. Model-Specific Information & Estimated Second-hand Value (Good Condition, FU):**
  - **iPhone 13 (128GB):** ~₱30,000 - ₱35,000. *Common issue: Occasional green screen tint.*
  - **iPhone 11 (64GB):** ~₱15,000 - ₱18,000. *Common issue: LCD discoloration at edges.*
  - **Samsung A52s (128GB):** ~₱10,000 - ₱12,000. *Common issue: Minor software bugs.*
  - **Xiaomi Note 10 Pro (128GB):** ~₱7,000 - ₱9,000. *Common issue: "Ghost touch" on some units.*

  **5. Recommended Actions Logic:**
  - **High Value (>₱20,000):** Repair is viable if cost is < 40% of post-repair value.
  - **Medium Value (₱8,000 - ₱20,000):** Repair if essential (screen, battery). Multiple issues may not be worth it.
  - **Low Value (<₱8,000):** Minor repairs only. Often better to sell "as-is" for parts, donate, or recycle.
  - **Cracked Screen + Other Major Issue:** Usually not worth repairing unless it's a very new model.
  ''';

  // Advanced RAG retrieval methods
  static Map<String, dynamic>? getDeviceData(String deviceModel) {
    final modelLower = deviceModel.toLowerCase();

    for (final brand in deviceDatabase.keys) {
      final brandData = deviceDatabase[brand] as Map<String, dynamic>;
      final models = brandData['models'] as Map<String, dynamic>;

      for (final modelKey in models.keys) {
        if (modelLower.contains(modelKey.replaceAll('_', ' ')) ||
            modelLower.contains(modelKey.replaceAll('_', ''))) {
          final deviceData = Map<String, dynamic>.from(
            models[modelKey] as Map<String, dynamic>,
          );
          deviceData['brand'] = brand;
          deviceData['modelKey'] = modelKey;
          return deviceData;
        }
      }
    }
    return null;
  }

  static List<String> getRelevantKnowledge(
    String deviceModel,
    List<String> identifiedIssues,
  ) {
    final relevantKnowledge = <String>[];
    final deviceData = getDeviceData(deviceModel);

    if (deviceData != null) {
      // Add device-specific information
      relevantKnowledge.add(
        'Device: ${deviceModel.toUpperCase()}\n'
        'Base Market Value: ₱${deviceData['baseValue']}\n'
        'Release Year: ${deviceData['releaseYear']}\n'
        'Market Demand: ${deviceData['marketDemand']}\n'
        'Known Issues: ${(deviceData['commonIssues'] as List).join(', ')}',
      );

      // Add repair cost information
      final repairCosts = deviceData['repairCosts'] as Map<String, dynamic>;
      final costsInfo = repairCosts.entries
          .map((e) => '${e.key}: ₱${e.value}')
          .join(', ');
      relevantKnowledge.add('Repair Costs: $costsInfo');
    }

    // Add market intelligence
    final marketData =
        marketIntelligence['local_market'] as Map<String, dynamic>;
    relevantKnowledge.add(
      'Market Context (Local): ${marketData['marketMultiplier']}x multiplier, '
      '${marketData['repairShops']} repair shops available, '
      'Avg repair time: ${marketData['averageRepairTime']}',
    );

    // Add seasonal context
    final currentMonth = DateTime.now().month;
    final monthNames = [
      '',
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final currentMonthName = monthNames[currentMonth];
    final seasonalData = marketData['seasonalDemand'] as Map<String, dynamic>;

    String demandLevel = 'moderate';
    for (final level in seasonalData.keys) {
      final months = seasonalData[level] as List;
      if (months.contains(currentMonthName)) {
        demandLevel = level;
        break;
      }
    }
    relevantKnowledge.add(
      'Current Market Demand: $demandLevel (${monthNames[currentMonth]})',
    );

    return relevantKnowledge;
  }

  static double calculatePreciseValue(
    String deviceModel,
    Map<String, dynamic> conditions,
  ) {
    final deviceData = getDeviceData(deviceModel);
    if (deviceData == null) return 10000.0; // Default fallback

    double baseValue = (deviceData['baseValue'] as num).toDouble();
    final depreciationRate = (deviceData['depreciationRate'] as num).toDouble();
    final currentYear = DateTime.now().year;
    final releaseYear = deviceData['releaseYear'] as int;

    // Apply age depreciation
    final ageYears = currentYear - releaseYear;
    baseValue *= (depreciationRate * (1 - (ageYears * 0.1))).clamp(0.3, 1.0);

    // Apply market multiplier for local market
    final marketMultiplier =
        (marketIntelligence['local_market']!['marketMultiplier'] as num)
            .toDouble();
    baseValue *= marketMultiplier;

    // Apply condition factors
    final batteryHealth =
        (conditions['batteryHealth'] as num?)?.toDouble() ?? 85.0;
    final screenCondition = conditions['screenCondition'] as String? ?? 'good';
    final hardwareCondition =
        conditions['hardwareCondition'] as String? ?? 'good';

    // Battery impact
    baseValue *= (batteryHealth / 100) * 0.7 + 0.3;

    // Screen condition impact
    final screenMultipliers = {
      'excellent': 1.1,
      'good': 1.0,
      'fair': 0.85,
      'poor': 0.7,
      'cracked': 0.5,
    };
    baseValue *= screenMultipliers[screenCondition] ?? 1.0;

    // Hardware condition impact
    final hardwareMultipliers = {
      'excellent': 1.05,
      'good': 1.0,
      'fair': 0.8,
      'poor': 0.6,
      'damaged': 0.4,
    };
    baseValue *= hardwareMultipliers[hardwareCondition] ?? 1.0;

    return baseValue;
  }

  static Map<String, double> getRepairCosts(String deviceModel) {
    final deviceData = getDeviceData(deviceModel);
    if (deviceData == null) {
      return {'screen': 3000.0, 'battery': 1500.0, 'camera': 2500.0};
    }

    final repairCosts = deviceData['repairCosts'] as Map<String, dynamic>;
    return repairCosts.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
  }
}
