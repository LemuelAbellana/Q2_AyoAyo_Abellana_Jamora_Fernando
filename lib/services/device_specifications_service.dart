
class DeviceSpecification {
  final String deviceModel;
  final String manufacturer;
  final String ram;
  final String storage;
  final String processor;
  final String displaySize;
  final String displayResolution;
  final String camera;
  final String battery;
  final String operatingSystem;
  final int releaseYear;
  final String connectivity;
  final String build;
  final String colors;
  final double originalPrice;

  DeviceSpecification({
    required this.deviceModel,
    required this.manufacturer,
    required this.ram,
    required this.storage,
    required this.processor,
    required this.displaySize,
    required this.displayResolution,
    required this.camera,
    required this.battery,
    required this.operatingSystem,
    required this.releaseYear,
    this.connectivity = '',
    this.build = '',
    this.colors = '',
    this.originalPrice = 0.0,
  });

  factory DeviceSpecification.fromJson(Map<String, dynamic> json) {
    return DeviceSpecification(
      deviceModel: json['deviceModel'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      processor: json['processor'] ?? '',
      displaySize: json['displaySize'] ?? '',
      displayResolution: json['displayResolution'] ?? '',
      camera: json['camera'] ?? '',
      battery: json['battery'] ?? '',
      operatingSystem: json['operatingSystem'] ?? '',
      releaseYear: json['releaseYear'] ?? 2020,
      connectivity: json['connectivity'] ?? '',
      build: json['build'] ?? '',
      colors: json['colors'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'ram': ram,
      'storage': storage,
      'processor': processor,
      'displaySize': displaySize,
      'displayResolution': displayResolution,
      'camera': camera,
      'battery': battery,
      'operatingSystem': operatingSystem,
      'releaseYear': releaseYear,
      'connectivity': connectivity,
      'build': build,
      'colors': colors,
      'originalPrice': originalPrice,
    };
  }
}

class DeviceSpecificationsService {
  static final Map<String, DeviceSpecification> _deviceDatabase = {
    // Samsung Galaxy S21 Ultra
    'samsung galaxy s21 ultra': DeviceSpecification(
      deviceModel: 'Samsung Galaxy S21 Ultra',
      manufacturer: 'Samsung',
      ram: '12GB / 16GB',
      storage: '128GB / 256GB / 512GB',
      processor: 'Exynos 2100 / Snapdragon 888',
      displaySize: '6.8 inches',
      displayResolution: '3200 x 1440 (WQHD+)',
      camera: '108MP + 12MP + 10MP + 10MP',
      battery: '5000 mAh',
      operatingSystem: 'Android 11 (upgradable)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Gorilla Glass Victus',
      colors: 'Phantom Black, Phantom Silver, Phantom Violet, Phantom Brown, Phantom Navy',
      originalPrice: 65000.0,
    ),

    // Samsung Galaxy S22 Ultra
    'samsung galaxy s22 ultra': DeviceSpecification(
      deviceModel: 'Samsung Galaxy S22 Ultra',
      manufacturer: 'Samsung',
      ram: '8GB / 12GB',
      storage: '128GB / 256GB / 512GB / 1TB',
      processor: 'Exynos 2200 / Snapdragon 8 Gen 1',
      displaySize: '6.8 inches',
      displayResolution: '3088 x 1440 (WQHD+)',
      camera: '108MP + 12MP + 10MP + 10MP',
      battery: '5000 mAh',
      operatingSystem: 'Android 12 (upgradable)',
      releaseYear: 2022,
      connectivity: '5G, Wi-Fi 6E, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Gorilla Glass Victus+',
      colors: 'Phantom Black, Phantom White, Burgundy, Green',
      originalPrice: 70000.0,
    ),

    // iPhone 13 Pro Max
    'iphone 13 pro max': DeviceSpecification(
      deviceModel: 'iPhone 13 Pro Max',
      manufacturer: 'Apple',
      ram: '6GB',
      storage: '128GB / 256GB / 512GB / 1TB',
      processor: 'A15 Bionic chip',
      displaySize: '6.7 inches',
      displayResolution: '2778 x 1284 (Super Retina XDR)',
      camera: '12MP Triple camera system',
      battery: '4352 mAh',
      operatingSystem: 'iOS 15 (upgradable)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.0, Lightning',
      build: 'Stainless steel frame, Ceramic Shield',
      colors: 'Graphite, Gold, Silver, Sierra Blue, Alpine Green',
      originalPrice: 75000.0,
    ),

    // iPhone 14 Pro Max
    'iphone 14 pro max': DeviceSpecification(
      deviceModel: 'iPhone 14 Pro Max',
      manufacturer: 'Apple',
      ram: '6GB',
      storage: '128GB / 256GB / 512GB / 1TB',
      processor: 'A16 Bionic chip',
      displaySize: '6.7 inches',
      displayResolution: '2796 x 1290 (Super Retina XDR)',
      camera: '48MP + 12MP + 12MP',
      battery: '4323 mAh',
      operatingSystem: 'iOS 16 (upgradable)',
      releaseYear: 2022,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.3, Lightning',
      build: 'Stainless steel frame, Ceramic Shield',
      colors: 'Deep Purple, Gold, Silver, Space Black',
      originalPrice: 85000.0,
    ),

    // Xiaomi Mi 11 Ultra
    'xiaomi mi 11 ultra': DeviceSpecification(
      deviceModel: 'Xiaomi Mi 11 Ultra',
      manufacturer: 'Xiaomi',
      ram: '8GB / 12GB',
      storage: '256GB / 512GB',
      processor: 'Snapdragon 888',
      displaySize: '6.81 inches',
      displayResolution: '3200 x 1440 (WQHD+)',
      camera: '50MP + 48MP + 48MP',
      battery: '5000 mAh',
      operatingSystem: 'Android 11 (MIUI 12)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6E, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Gorilla Glass Victus',
      colors: 'Ceramic Black, Ceramic White',
      originalPrice: 55000.0,
    ),

    // OnePlus 9 Pro
    'oneplus 9 pro': DeviceSpecification(
      deviceModel: 'OnePlus 9 Pro',
      manufacturer: 'OnePlus',
      ram: '8GB / 12GB',
      storage: '128GB / 256GB',
      processor: 'Snapdragon 888',
      displaySize: '6.7 inches',
      displayResolution: '3216 x 1440 (WQHD+)',
      camera: '48MP + 8MP + 50MP + 2MP',
      battery: '4500 mAh',
      operatingSystem: 'Android 11 (OxygenOS 11)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Gorilla Glass 5',
      colors: 'Morning Mist, Pine Green, Stellar Black',
      originalPrice: 45000.0,
    ),

    // Google Pixel 6 Pro
    'google pixel 6 pro': DeviceSpecification(
      deviceModel: 'Google Pixel 6 Pro',
      manufacturer: 'Google',
      ram: '12GB',
      storage: '128GB / 256GB / 512GB',
      processor: 'Google Tensor',
      displaySize: '6.7 inches',
      displayResolution: '3120 x 1440 (WQHD+)',
      camera: '50MP + 12MP + 48MP',
      battery: '5003 mAh',
      operatingSystem: 'Android 12 (upgradable)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6E, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Gorilla Glass Victus',
      colors: 'Sorta Sunny, Cloudy White, Stormy Black',
      originalPrice: 50000.0,
    ),

    // Samsung Galaxy Note 20 Ultra
    'samsung galaxy note 20 ultra': DeviceSpecification(
      deviceModel: 'Samsung Galaxy Note 20 Ultra',
      manufacturer: 'Samsung',
      ram: '12GB',
      storage: '128GB / 256GB / 512GB',
      processor: 'Exynos 990 / Snapdragon 865+',
      displaySize: '6.9 inches',
      displayResolution: '3088 x 1440 (WQHD+)',
      camera: '108MP + 12MP + 12MP',
      battery: '4500 mAh',
      operatingSystem: 'Android 10 (upgradable)',
      releaseYear: 2020,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.0, USB-C',
      build: 'Aluminum frame, Gorilla Glass Victus',
      colors: 'Mystic Bronze, Mystic White, Mystic Black',
      originalPrice: 60000.0,
    ),

    // iPhone 12 Pro Max
    'iphone 12 pro max': DeviceSpecification(
      deviceModel: 'iPhone 12 Pro Max',
      manufacturer: 'Apple',
      ram: '6GB',
      storage: '128GB / 256GB / 512GB',
      processor: 'A14 Bionic chip',
      displaySize: '6.7 inches',
      displayResolution: '2778 x 1284 (Super Retina XDR)',
      camera: '12MP Triple camera system',
      battery: '3687 mAh',
      operatingSystem: 'iOS 14 (upgradable)',
      releaseYear: 2020,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.0, Lightning',
      build: 'Stainless steel frame, Ceramic Shield',
      colors: 'Graphite, Gold, Silver, Pacific Blue',
      originalPrice: 70000.0,
    ),

    // Huawei P40 Pro
    'huawei p40 pro': DeviceSpecification(
      deviceModel: 'Huawei P40 Pro',
      manufacturer: 'Huawei',
      ram: '8GB',
      storage: '128GB / 256GB / 512GB',
      processor: 'Kirin 990 5G',
      displaySize: '6.58 inches',
      displayResolution: '2640 x 1200 (FHD+)',
      camera: '50MP + 40MP + 12MP + ToF',
      battery: '4200 mAh',
      operatingSystem: 'Android 10 (EMUI 10.1)',
      releaseYear: 2020,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.1, USB-C',
      build: 'Aluminum frame, Curved glass',
      colors: 'Black, Blush Gold, Silver Frost, Deep Sea Blue, Ice White',
      originalPrice: 55000.0,
    ),

    // OPPO Find X3 Pro
    'oppo find x3 pro': DeviceSpecification(
      deviceModel: 'OPPO Find X3 Pro',
      manufacturer: 'OPPO',
      ram: '12GB',
      storage: '256GB',
      processor: 'Snapdragon 888',
      displaySize: '6.7 inches',
      displayResolution: '3216 x 1440 (WQHD+)',
      camera: '50MP + 13MP + 50MP + 3MP',
      battery: '4500 mAh',
      operatingSystem: 'Android 11 (ColorOS 11.2)',
      releaseYear: 2021,
      connectivity: '5G, Wi-Fi 6, Bluetooth 5.2, USB-C',
      build: 'Aluminum frame, Curved glass',
      colors: 'Gloss Black, Blue, White',
      originalPrice: 48000.0,
    ),
  };

  static DeviceSpecification? getDeviceSpecification(String deviceModel) {
    final normalizedModel = deviceModel.toLowerCase().trim();
    return _deviceDatabase[normalizedModel];
  }

  static List<DeviceSpecification> searchDevices(String query) {
    final normalizedQuery = query.toLowerCase();
    return _deviceDatabase.values
        .where((device) =>
            device.deviceModel.toLowerCase().contains(normalizedQuery) ||
            device.manufacturer.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  static List<String> getSupportedDeviceModels() {
    return _deviceDatabase.keys.toList();
  }

  static DeviceSpecification? identifyDeviceFromImage(String analysisText) {
    final text = analysisText.toLowerCase();

    // Look for specific device models mentioned in the analysis
    for (final entry in _deviceDatabase.entries) {
      final modelParts = entry.key.split(' ');
      bool allPartsFound = true;

      for (final part in modelParts) {
        if (!text.contains(part)) {
          allPartsFound = false;
          break;
        }
      }

      if (allPartsFound) {
        return entry.value;
      }
    }

    // Fallback: look for manufacturer and partial model matches
    if (text.contains('samsung') && text.contains('s21')) {
      return _deviceDatabase['samsung galaxy s21 ultra'];
    }
    if (text.contains('iphone') && text.contains('13')) {
      return _deviceDatabase['iphone 13 pro max'];
    }
    if (text.contains('xiaomi') && text.contains('mi 11')) {
      return _deviceDatabase['xiaomi mi 11 ultra'];
    }

    return null;
  }

  static String generateDevicePrompt() {
    return '''
    📱 DEVICE IDENTIFICATION AND SPECIFICATIONS ANALYSIS

    You are an expert device identification specialist. Based on the uploaded images, identify the specific device model and provide detailed specifications.

    🔍 ANALYSIS REQUIREMENTS:
    1. Identify the exact device model (e.g., "Samsung Galaxy S21 Ultra", "iPhone 13 Pro Max")
    2. Determine manufacturer
    3. Estimate the device's release year
    4. Assess physical condition from visual inspection

    📋 SUPPORTED DEVICE MODELS:
    ${getSupportedDeviceModels().map((model) => '• $model').join('\n')}

    🎯 RESPONSE FORMAT:
    Provide your analysis in this exact format:

    **DEVICE IDENTIFICATION:**
    - Model: [Exact device model name]
    - Manufacturer: [Brand name]
    - Release Year: [Year]
    - Confidence: [High/Medium/Low]

    **PHYSICAL ASSESSMENT:**
    - Screen Condition: [Excellent/Good/Fair/Poor/Cracked]
    - Body Condition: [Excellent/Good/Fair/Poor/Damaged]
    - Notable Issues: [List any visible damage or wear]

    **SPECIFICATIONS MATCH:**
    Based on the identified model, confirm if this appears to match the expected device specifications and design.

    If you cannot identify the specific model, indicate "Unknown Device" and provide general observations about the device type and condition.
    ''';
  }
}