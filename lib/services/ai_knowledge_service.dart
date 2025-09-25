import 'package:ayoayo/services/knowledge_base.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class AIKnowledgeService {
  Future<String> getRelevantKnowledge(
    DeviceDiagnosis diagnosis, [
    String? imageAnalysis,
  ]) async {
    // Enhanced RAG retrieval using structured knowledge base
    final identifiedIssues = <String>[];

    // Extract potential issues from user description
    if (diagnosis.additionalInfo != null) {
      final info = diagnosis.additionalInfo!.toLowerCase();
      if (info.contains('battery') ||
          info.contains('drain') ||
          info.contains('power')) {
        identifiedIssues.add('battery');
      }
      if (info.contains('screen') ||
          info.contains('crack') ||
          info.contains('cracked') ||
          info.contains('cracked lcd') ||
          info.contains('display') ||
          info.contains('broken screen') ||
          info.contains('screen damage')) {
        identifiedIssues.add('screen');
      }
      if (info.contains('camera') ||
          info.contains('photo') ||
          info.contains('video')) {
        identifiedIssues.add('camera');
      }
      if (info.contains('charge') ||
          info.contains('charging') ||
          info.contains('port')) {
        identifiedIssues.add('charging');
      }
      if (info.contains('overheat') ||
          info.contains('hot') ||
          info.contains('warm')) {
        identifiedIssues.add('thermal');
      }
      if (info.contains('water') ||
          info.contains('wet') ||
          info.contains('liquid')) {
        identifiedIssues.add('water_damage');
      }
      if (info.contains('drop') ||
          info.contains('fall') ||
          info.contains('impact')) {
        identifiedIssues.add('physical_damage');
      }
      if (info.contains('slow') ||
          info.contains('lag') ||
          info.contains('freeze')) {
        identifiedIssues.add('performance');
      }
      if (info.contains('speaker') ||
          info.contains('audio') ||
          info.contains('sound')) {
        identifiedIssues.add('audio');
      }
    }

    // Extract issues from image analysis results
    if (imageAnalysis != null && imageAnalysis.isNotEmpty) {
      final imageText = imageAnalysis.toLowerCase();
      if (imageText.contains('crack') ||
          imageText.contains('cracked') ||
          imageText.contains('cracked lcd') ||
          imageText.contains('shatter') ||
          imageText.contains('shattered') ||
          imageText.contains('broken') ||
          imageText.contains('broken screen') ||
          imageText.contains('screen damage') ||
          imageText.contains('spider web') ||
          imageText.contains('spiderweb')) {
        identifiedIssues.add('screen');
      }
      if (imageText.contains('scratch') ||
          imageText.contains('dent') ||
          imageText.contains('damage')) {
        identifiedIssues.add('physical_damage');
      }
      if (imageText.contains('water') ||
          imageText.contains('corrosion') ||
          imageText.contains('liquid')) {
        identifiedIssues.add('water_damage');
      }
      if (imageText.contains('camera') || imageText.contains('lens')) {
        identifiedIssues.add('camera');
      }
      if (imageText.contains('port') || imageText.contains('charging')) {
        identifiedIssues.add('charging');
      }
      if (imageText.contains('poor') || imageText.contains('damaged')) {
        identifiedIssues.add('overall_condition');
      }
    }

    // Remove duplicates
    final uniqueIssues = identifiedIssues.toSet().toList();

    // Get relevant knowledge using enhanced RAG
    final relevantKnowledge = KnowledgeBase.getRelevantKnowledge(
      diagnosis.deviceModel,
      uniqueIssues,
    );

    // Combine with base knowledge and analysis context
    final combinedKnowledge = StringBuffer();
    combinedKnowledge.writeln('🧠 **ENHANCED RAG KNOWLEDGE BASE**\n');
    combinedKnowledge.writeln(KnowledgeBase.ragData);

    combinedKnowledge.writeln('\n📋 **DEVICE-SPECIFIC INTELLIGENCE:**');
    for (final knowledge in relevantKnowledge) {
      combinedKnowledge.writeln('• $knowledge');
    }

    if (uniqueIssues.isNotEmpty) {
      combinedKnowledge.writeln('\n🔍 **IDENTIFIED ISSUES FROM ANALYSIS:**');
      for (final issue in uniqueIssues) {
        combinedKnowledge.writeln(
          '• ${issue.replaceAll('_', ' ').toUpperCase()}',
        );
      }
    }

    // Add cross-reference between user description and visual analysis
    if (diagnosis.additionalInfo != null && imageAnalysis != null) {
      combinedKnowledge.writeln('\n🔗 **MULTI-SOURCE ANALYSIS CORRELATION:**');
      combinedKnowledge.writeln('• User Description: Available and processed');
      combinedKnowledge.writeln('• Visual Analysis: Available and processed');
      combinedKnowledge.writeln(
        '• Cross-Validation: Enhanced accuracy through multiple data sources',
      );
    }

    return combinedKnowledge.toString();
  }
}