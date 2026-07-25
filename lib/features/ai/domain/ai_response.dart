import 'ai_proposal.dart';

class AIResponse {
  final String analysisText;
  final List<AIProposal> proposals;

  const AIResponse({required this.analysisText, this.proposals = const []});
}
