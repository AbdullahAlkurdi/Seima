import 'dart:convert';
import 'package:mindora/features/ai/domain/ai_proposal.dart';
import 'package:mindora/features/ai/domain/ai_response.dart';

class LLMResponseParser {
  static const maxContentLength = 2000;
  static const maxTagLength = 50;
  static const maxTags = 10;

  const LLMResponseParser();

  AIResponse parse(String rawOutput) {
    final analysisText = _extractAnalysisText(rawOutput);
    final proposals = _extractProposals(rawOutput);
    return AIResponse(analysisText: analysisText, proposals: proposals);
  }

  String _extractAnalysisText(String output) {
    final jsonStart = output.indexOf('{');
    if (jsonStart <= 0) {
      return output.trim();
    }
    final beforeJson = output.substring(0, jsonStart).trim();
    if (beforeJson.isNotEmpty) return beforeJson;
    return output.trim();
  }

  List<AIProposal> _extractProposals(String output) {
    final proposals = <AIProposal>[];

    final jsonStart = output.indexOf('{');
    if (jsonStart < 0) return proposals;

    final jsonEnd = output.lastIndexOf('}');
    if (jsonEnd < jsonStart) return proposals;

    final jsonStr = output.substring(jsonStart, jsonEnd + 1);

    Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return proposals;
    }

    final rawProposals = json['proposals'];
    if (rawProposals is! List) return proposals;

    for (final item in rawProposals) {
      if (item is! Map) continue;
      final proposal = _parseProposal(item.cast<String, dynamic>());
      if (proposal != null) proposals.add(proposal);
    }

    return proposals;
  }

  AIProposal? _parseProposal(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final reason = json['reason'] as String? ?? '';

    switch (type) {
      case 'new_node':
        final content = json['content'] as String?;
        if (content == null || content.trim().isEmpty) return null;
        if (content.length > maxContentLength) return null;
        final tags = _parseTags(json['tags']);
        return NewNodeProposal(content: content, tags: tags, reason: reason);
      case 'connection':
        final sourceId = json['source_id'] as String?;
        final targetId = json['target_id'] as String?;
        if (sourceId == null || targetId == null) return null;
        if (sourceId == targetId) return null;
        return ConnectionProposal(
          sourceNodeId: sourceId,
          targetNodeId: targetId,
          reason: reason,
        );
      default:
        return null;
    }
  }

  List<String> _parseTags(dynamic tags) {
    if (tags is List) {
      return tags
          .whereType<String>()
          .where((t) => t.trim().isNotEmpty && t.length <= maxTagLength)
          .take(maxTags)
          .toList();
    }
    return [];
  }
}
