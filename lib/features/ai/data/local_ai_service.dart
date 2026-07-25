import 'dart:async';
import 'package:seima/features/ai/data/ai_service.dart';
import 'package:seima/features/ai/domain/ai_config.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';
import 'package:seima/features/ai/domain/ai_response.dart';

class LocalAIService implements AIService {
  const LocalAIService();

  @override
  Future<AIResponse> analyze({
    required AIContext context,
    required AIConfig config,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.nodes.isEmpty) {
      return const AIResponse(
        analysisText:
            'This mind map has no nodes yet. Add some content to get started.',
        proposals: [],
      );
    }

    final analysis = _buildAnalysis(context);
    final proposals = _buildProposals(context);
    return AIResponse(analysisText: analysis, proposals: proposals);
  }

  @override
  Stream<String> analyzeStreaming({
    required AIContext context,
    required AIConfig config,
  }) async* {
    final result = await analyze(context: context, config: config);
    yield result.analysisText;
    for (final proposal in result.proposals) {
      yield '\n[Proposal: ${proposal.runtimeType}]';
    }
  }

  String _buildAnalysis(AIContext context) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Your mind map "${context.title}" contains ${context.nodeCount} nodes',
    );
    if (context.connectionCount > 0) {
      buffer.writeln('with ${context.connectionCount} connections.');
    } else {
      buffer.writeln('and no connections yet.');
    }
    buffer.writeln();

    final contentNodes = context.nodes
        .where((n) => n.content.isNotEmpty)
        .toList();
    final emptyNodes = context.nodes.where((n) => n.content.isEmpty).toList();

    if (contentNodes.isNotEmpty) {
      buffer.writeln('Key Themes (based on word frequency):');
      final themes = _extractThemes(contentNodes);
      for (final theme in themes.take(5)) {
        buffer.writeln('- $theme');
      }
      buffer.writeln();
    }

    if (contentNodes.isNotEmpty) {
      buffer.writeln('Content Overview:');
      for (final node in contentNodes.take(10)) {
        buffer.writeln('- "${node.content}"');
      }
      if (contentNodes.length > 10) {
        buffer.writeln('- ... and ${contentNodes.length - 10} more nodes');
      }
      buffer.writeln();
    }

    if (emptyNodes.isNotEmpty) {
      buffer.writeln(
        '${emptyNodes.length} node(s) are empty and could use content.',
      );
      buffer.writeln();
    }

    final taggedNodes = context.nodes.where((n) => n.tags.isNotEmpty).toList();
    if (taggedNodes.isNotEmpty) {
      buffer.writeln('Tags used across nodes:');
      final allTags = <String>{};
      for (final node in taggedNodes) {
        allTags.addAll(node.tags);
      }
      for (final tag in allTags) {
        final count = taggedNodes.where((n) => n.tags.contains(tag)).length;
        buffer.writeln('- $tag ($count node(s))');
      }
      buffer.writeln();
    }

    if (context.connections.isNotEmpty) {
      final connectedNodeIds = <String>{};
      for (final conn in context.connections) {
        connectedNodeIds.add(conn.sourceNodeId);
        connectedNodeIds.add(conn.targetNodeId);
      }
      final isolated = context.nodes
          .where((n) => !connectedNodeIds.contains(n.id))
          .toList();
      if (isolated.isNotEmpty) {
        buffer.writeln('Isolated Nodes (no connections):');
        for (final node in isolated) {
          final label = node.content.isNotEmpty ? node.content : '(empty node)';
          buffer.writeln('- $label');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('Areas to Explore:');
    if (context.nodes.length > 5 && context.connections.isEmpty) {
      buffer.writeln(
        '- Consider creating connections between related nodes to show relationships.',
      );
    }
    if (emptyNodes.isNotEmpty) {
      buffer.writeln('- Fill in empty nodes with content.');
    }
    if (context.nodes.length <= 3) {
      buffer.writeln('- Expand with more ideas or subtopics.');
    }
    if (context.connections.length < context.nodes.length - 1) {
      buffer.writeln(
        '- Look for nodes that could be connected to form a more complete picture.',
      );
    }
    buffer.writeln(
      '- Review isolated nodes and consider how they connect to the rest of the map.',
    );

    return buffer.toString().trim();
  }

  List<String> _extractThemes(List<AIContextNode> nodes) {
    final wordCount = <String, int>{};
    final stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'from',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'can',
      'could',
      'should',
      'may',
      'might',
      'shall',
      'this',
      'that',
      'these',
      'those',
      'i',
      'me',
      'my',
      'we',
      'our',
      'you',
      'your',
      'it',
      'its',
      'they',
      'them',
      'their',
      'what',
      'which',
      'who',
      'not',
      'no',
      'nor',
      'so',
      'if',
      'then',
      'than',
      'too',
      'very',
    };

    for (final node in nodes) {
      final words = node.content.toLowerCase().split(RegExp(r'\s+'));
      for (final word in words) {
        final cleaned = word.replaceAll(RegExp(r'[^\w]'), '');
        if (cleaned.length > 2 && !stopWords.contains(cleaned)) {
          wordCount[cleaned] = (wordCount[cleaned] ?? 0) + 1;
        }
      }
    }

    final sorted = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  List<AIProposal> _buildProposals(AIContext context) {
    final proposals = <AIProposal>[];

    final contentNodes = context.nodes
        .where((n) => n.content.isNotEmpty)
        .toList();
    if (contentNodes.length >= 2) {
      final connectedNodeIds = <String>{};
      for (final conn in context.connections) {
        connectedNodeIds.add(conn.sourceNodeId);
        connectedNodeIds.add(conn.targetNodeId);
      }

      for (int i = 0; i < contentNodes.length && proposals.length < 3; i++) {
        for (
          int j = i + 1;
          j < contentNodes.length && proposals.length < 3;
          j++
        ) {
          final a = contentNodes[i];
          final b = contentNodes[j];

          if (a.id == b.id) continue;

          final alreadyConnected = context.connections.any(
            (c) =>
                (c.sourceNodeId == a.id && c.targetNodeId == b.id) ||
                (c.sourceNodeId == b.id && c.targetNodeId == a.id),
          );
          if (alreadyConnected) continue;

          if (_wordsOverlap(a.content, b.content)) {
            proposals.add(
              ConnectionProposal(
                sourceNodeId: a.id,
                targetNodeId: b.id,
                reason:
                    'Both nodes share common topics and could be connected.',
              ),
            );
          }
        }
      }
    }

    if (contentNodes.length >= 2 && proposals.isEmpty) {
      final themes = _extractThemes(contentNodes);
      if (themes.isNotEmpty) {
        proposals.add(
          NewNodeProposal(
            content: 'Explore more about: ${themes.first}',
            tags: [themes.first],
            reason:
                'This theme appears frequently and could be expanded further.',
          ),
        );
      }
    }

    if (contentNodes.length <= 3 && proposals.isEmpty) {
      proposals.add(
        NewNodeProposal(
          content: 'What other ideas relate to this topic?',
          tags: ['expansion'],
          reason: 'Your mind map has room to grow with additional ideas.',
        ),
      );
    }

    return proposals;
  }

  bool _wordsOverlap(String a, String b) {
    final wordsA = a
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
        .where((w) => w.length > 3)
        .toSet();
    final wordsB = b
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
        .where((w) => w.length > 3)
        .toSet();
    return wordsA.intersection(wordsB).isNotEmpty;
  }
}
