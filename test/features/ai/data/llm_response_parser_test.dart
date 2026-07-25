import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/ai/data/llm_response_parser.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';

void main() {
  group('LLMResponseParser', () {
    late LLMResponseParser parser;

    setUp(() {
      parser = const LLMResponseParser();
    });

    test('parses analysis text without JSON', () {
      final result = parser.parse('This is a simple analysis.');
      expect(result.analysisText, 'This is a simple analysis.');
      expect(result.proposals, isEmpty);
    });

    test('parses analysis text before JSON block', () {
      final output =
          'The mind map contains 5 nodes about AI topics.\n\n'
          'Key themes: machine learning, neural networks.\n\n'
          '{\n'
          '  "proposals": []\n'
          '}';
      final result = parser.parse(output);
      expect(
        result.analysisText,
        'The mind map contains 5 nodes about AI topics.\n\n'
        'Key themes: machine learning, neural networks.',
      );
      expect(result.proposals, isEmpty);
    });

    test('parses new node proposal from JSON', () {
      final output =
          'Analysis text.\n\n'
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "new_node",\n'
          '      "content": "Explore deep learning further",\n'
          '      "tags": ["deep-learning", "AI"],\n'
          '      "reason": "This is a key theme in the mind map"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, hasLength(1));
      final proposal = result.proposals.first;
      expect(proposal, isA<NewNodeProposal>());
      final nodeProp = proposal as NewNodeProposal;
      expect(nodeProp.content, 'Explore deep learning further');
      expect(nodeProp.tags, ['deep-learning', 'AI']);
      expect(nodeProp.reason, 'This is a key theme in the mind map');
    });

    test('parses connection proposal from JSON', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "connection",\n'
          '      "source_id": "node-1",\n'
          '      "target_id": "node-2",\n'
          '      "reason": "These nodes are related"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, hasLength(1));
      final proposal = result.proposals.first;
      expect(proposal, isA<ConnectionProposal>());
      final connProp = proposal as ConnectionProposal;
      expect(connProp.sourceNodeId, 'node-1');
      expect(connProp.targetNodeId, 'node-2');
      expect(connProp.reason, 'These nodes are related');
    });

    test('parses multiple proposals', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "new_node",\n'
          '      "content": "New idea",\n'
          '      "tags": [],\n'
          '      "reason": "Expand thinking"\n'
          '    },\n'
          '    {\n'
          '      "type": "connection",\n'
          '      "source_id": "a",\n'
          '      "target_id": "b",\n'
          '      "reason": "Connect these"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, hasLength(2));
      expect(result.proposals[0], isA<NewNodeProposal>());
      expect(result.proposals[1], isA<ConnectionProposal>());
    });

    test('rejects empty content for new_node', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "new_node",\n'
          '      "content": "",\n'
          '      "tags": [],\n'
          '      "reason": "test"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, isEmpty);
    });

    test('rejects self-connection proposal', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "connection",\n'
          '      "source_id": "same-id",\n'
          '      "target_id": "same-id",\n'
          '      "reason": "self"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, isEmpty);
    });

    test('rejects connection with missing fields', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "connection",\n'
          '      "reason": "missing ids"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, isEmpty);
    });

    test('rejects unknown proposal type', () {
      final output =
          '{\n'
          '  "proposals": [\n'
          '    {\n'
          '      "type": "unknown_type",\n'
          '      "reason": "test"\n'
          '    }\n'
          '  ]\n'
          '}';
      final result = parser.parse(output);
      expect(result.proposals, isEmpty);
    });

    test('handles malformed JSON gracefully', () {
      final result = parser.parse('Some text with {broken json here');
      expect(result.analysisText, isNotEmpty);
      expect(result.proposals, isEmpty);
    });

    test('handles empty output', () {
      final result = parser.parse('');
      expect(result.analysisText, isEmpty);
      expect(result.proposals, isEmpty);
    });

    test('returns entire output as analysis when no JSON', () {
      final result = parser.parse('Line 1\nLine 2\nLine 3');
      expect(result.analysisText, 'Line 1\nLine 2\nLine 3');
      expect(result.proposals, isEmpty);
    });

    test('handles JSON without proposals key', () {
      final output = 'Analysis\n\n{\n  "other": "data"\n}';
      final result = parser.parse(output);
      expect(result.analysisText, 'Analysis');
      expect(result.proposals, isEmpty);
    });
  });
}
