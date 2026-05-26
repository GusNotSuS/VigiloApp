class MessageModel {
  final String id;
  final String content;
  final String? resultLink;
  final bool? hasSocialEngineering;
  final bool? isPhishing;
  final bool? isSafe;
  final double? riskScore;
  final String? analysisComment;
  final String? createdAt;
  final String? updatedAt;

  MessageModel({
    required this.id,
    required this.content,
    this.resultLink,
    this.hasSocialEngineering,
    this.isPhishing,
    this.isSafe,
    this.riskScore,
    this.analysisComment,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      resultLink: json['result_link'],
      hasSocialEngineering: json['has_social_engineering'],
      isPhishing: json['is_phishing'],
      isSafe: json['is_safe'],
      riskScore: json['risk_score'] != null ? (json['risk_score'] as num).toDouble() : null,
      analysisComment: json['analysis_comment'],
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