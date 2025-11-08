# Enum Serialization Issues Report

## Summary
Found **multiple critical enum serialization issues** that cause the `_Namespace` error when running on Flutter Web/Chrome. The issues occur in two main categories:

1. **Direct `.name` property usage** (Web-incompatible)
2. **`.toString().split('.').last` pattern** (Works but not optimal; should use helper)
3. **Direct enum.toString() serialization in DAOs** (Produces format like `"ListingStatus.active"`)

---

## CRITICAL ISSUES FOUND

### Issue 1: Direct .name Property Usage (BREAKS ON WEB)

File: lib/screens/upcycling_workspace_screen.dart
Line 915 - Direct use of .name property on enum
```
                                    idea.difficulty.name,
```
This will crash on Flutter Web with _Namespace error.
FIX: Use getEnumName(idea.difficulty)

---

### Issue 2: DAO Layer Enum Serialization (WRONG FORMAT)

File: lib/services/resell_listing_dao.dart

Lines 75-76, 83 - Storing full enum toString format:
```
'category': listing.category.toString(),       // "ListingCategory.smartphone"
'condition': listing.condition.toString(),     // "ConditionGrade.excellent"  
'status': listing.status.toString(),           // "ListingStatus.active"
```

Lines 110, 114, 124 - Parsing back expecting wrong format:
```
category: ListingCategory.values.firstWhere(
  (e) => e.toString() == map['category'],
```

PROBLEM: Database stores full enum format "ListingStatus.active" instead of just "active"
This is incompatible with the model toJson() which serializes as just "active"

FIX: 
- Storage: Use getEnumName(listing.category) to store just "smartphone"
- Retrieval: Use getEnumName(e) == map['category'] for comparison

---

### Issue 3: Service Layer Using .toString().split Pattern

These locations use .toString().split('.').last which WORKS but is inconsistent:

lib/services/ai_resell_service.dart - Lines 27, 28, 29, 74, 103, 158, 301, 304
lib/services/ai_upcycling_service.dart - Lines 24, 25, 73, 171
lib/services/gemini_diagnosis_service.dart - Prompts
lib/providers/diagnosis_provider.dart - Prompts
lib/screens/create_listing_screen.dart - Line 1001
lib/screens/resell_marketplace_screen.dart - Lines 637, 768, 902, 964
lib/screens/upcycling_workspace_screen.dart - Lines 324, 336, 461, 658, 662
lib/widgets/pathways/resell_detail.dart - Lines 341, 345, 428
lib/widgets/upcycling/glassmorphic_project_card.dart - Lines 109, 156

Pattern: condition.toString().split('.').last

NOTE: These are SAFE for UI display but should use getEnumName() for consistency

---

## Enums Serialization Status

CORRECT - Using getEnumName() in toJson():
- lib/models/device_diagnosis.dart - Lines 140, 141, 257
- lib/models/donation.dart - Line 98
- lib/models/resell_listing.dart - Lines 103, 104, 111
- lib/models/upcycling_project.dart - Lines 119, 120, 128

WRONG - Using enum.toString() for storage:
- lib/services/resell_listing_dao.dart - Lines 75, 76, 83, 110, 114, 124

INCONSISTENT - Using .toString().split for display:
- 36+ occurrences in services, screens, and widgets

---

## Action Items

HIGH PRIORITY (Will break on web):
1. Fix lib/screens/upcycling_workspace_screen.dart line 915
   Change: idea.difficulty.name
   To: getEnumName(idea.difficulty)

2. Fix lib/services/resell_listing_dao.dart
   Lines 75, 76, 83: Use getEnumName() for storage
   Lines 110, 114, 124: Use getEnumName() for comparison

MEDIUM PRIORITY (Consistency):
3. Replace all .toString().split('.').last with getEnumName() in display code

---

## Helper Function Available

File: lib/utils/enum_helpers.dart

String getEnumName<T extends Enum>(T enumValue) {
  return enumValue.toString().split('.').last;
}

Already imported and used correctly in model classes.
