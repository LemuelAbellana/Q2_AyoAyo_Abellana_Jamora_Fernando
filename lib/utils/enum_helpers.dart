/// Web-safe enum utilities for Chrome compatibility.
/// Fixes: Unsupported operation: _Namespace error.
///
/// The .name property on Dart enums doesn't work in Flutter web/Chrome
/// because it doesn't transpile correctly to JavaScript.
/// These utilities provide a cross-platform way to work with enums.
library;

/// Safely get enum name
/// Works on all platforms including web/Chrome
String getEnumName<T extends Enum>(T enumValue) {
  // In modern Flutter/Dart, the .name property is the correct way
  // The .name property works on web when using Dart 2.17+
  try {
    return enumValue.name;
  } catch (e) {
    // Fallback for older Dart versions or edge cases
    final str = '$enumValue';
    final lastDot = str.lastIndexOf('.');
    return lastDot != -1 ? str.substring(lastDot + 1) : str;
  }
}

/// Safely parse enum from string value
/// Returns null if not found
T? parseEnum<T extends Enum>(List<T> values, String? value) {
  if (value == null) return null;

  final normalizedValue = value.toLowerCase().trim();

  for (final enumValue in values) {
    final enumName = getEnumName(enumValue).toLowerCase();
    if (enumName == normalizedValue) {
      return enumValue;
    }
  }

  return null;
}

/// Parse enum with fallback value
/// Returns fallback if value is null or not found
T parseEnumWithFallback<T extends Enum>(
  List<T> values,
  String? value,
  T fallback,
) {
  return parseEnum(values, value) ?? fallback;
}

/// Get display name for enum (formatted)
/// Converts camelCase to Title Case for UI display
String getEnumDisplayName<T extends Enum>(T enumValue) {
  final name = getEnumName(enumValue);
  // Convert camelCase to Title Case
  return name
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(0)}',
      )
      .trim();
}
