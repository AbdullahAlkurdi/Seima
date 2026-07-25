import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/ai/domain/ai_proposal.dart';

void main() {
  group('AIProposal', () {
    test('NewNodeProposal creates with content and tags', () {
      final proposal = NewNodeProposal(
        content: 'New idea',
        tags: ['tag1', 'tag2'],
        reason: 'Useful addition',
      );
      expect(proposal.content, 'New idea');
      expect(proposal.tags, contains('tag1'));
      expect(proposal.tags, contains('tag2'));
      expect(proposal.reason, 'Useful addition');
    });

    test('ConnectionProposal creates with source and target', () {
      final proposal = ConnectionProposal(
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
        reason: 'These are related',
      );
      expect(proposal.sourceNodeId, 'n1');
      expect(proposal.targetNodeId, 'n2');
      expect(proposal.reason, 'These are related');
    });

    test('sealed types are distinct', () {
      final nodeProposal = NewNodeProposal(content: 'idea', reason: 'reason');
      final connProposal = ConnectionProposal(
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
        reason: 'reason',
      );
      expect(nodeProposal, isA<NewNodeProposal>());
      expect(connProposal, isA<ConnectionProposal>());
      expect(nodeProposal, isNot(isA<ConnectionProposal>()));
    });
  });
}
