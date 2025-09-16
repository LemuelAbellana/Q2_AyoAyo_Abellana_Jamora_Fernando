import 'package:ayoayo/services/technician_service.dart';

void main() async {
  print('🧪 Testing Technician Service...');

  final technicianService = TechnicianService();

  try {
    // Test getting vetted technicians
    print('📋 Getting vetted technicians...');
    final technicians = await technicianService.getVettedTechnicians();

    print('✅ Found ${technicians.length} technicians:');
    for (var tech in technicians) {
      print(
        '  • ${tech.name} (${tech.specialization}) - ${tech.city} - ⭐${tech.rating}',
      );
    }

    // Test filtering for Davao
    print('\n🏙️ Testing Davao City filter...');
    final davaoTechs = await technicianService.getTechniciansWithFilter(
      location: 'Davao',
    );
    print('✅ Found ${davaoTechs.length} technicians in Davao:');
    for (var tech in davaoTechs) {
      print('  • ${tech.name} - ${tech.city}, ${tech.province}');
    }

    print('\n🎉 Technician service test completed successfully!');
  } catch (e) {
    print('❌ Error testing technician service: $e');
  }
}

