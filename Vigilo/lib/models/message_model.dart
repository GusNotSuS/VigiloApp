class MessageModel {
  final String id;
  final String content;
  final String? resultLink;
  final bool hasSocialEngineering;
  final bool isPhishing;
  final bool isSafe;
  final double riskScore;
  final String? analysisComment;
  final String? createdAt;
  final String? updatedAt;

  MessageModel({
    required this.id,
    required this.content,
    this.resultLink,
    required this.hasSocialEngineering,
    required this.isPhishing,
    required this.isSafe,
    required this.riskScore,
    this.analysisComment,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      resultLink: json['result_link'],
      // FALLBACKS: Tratando campos nulos vindo do Supabase para não quebrar o Flutter
      hasSocialEngineering: json['has_social_engineering'] ?? false,
      isPhishing: json['is_phishing'] ?? false,
      isSafe: json['is_safe'] ?? false,
      riskScore: json['risk_score'] != null ? (json['risk_score'] as num).toDouble() : 0.0,
      analysisComment: json['analysis_comment'] ?? 'Sem comentários disponíveis.',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'content': content,
    };
  }
}