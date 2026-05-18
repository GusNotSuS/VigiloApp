class MessageModel {
  final String id;
  final String content;
  final String? resultLink;
  final bool? hasSocialEngineering;
  final bool? isPhishing;
  final bool? isSafe;
  final String? classificationReason;
  final String? createdAt;
  final String? updatedAt;
  final double? riskScore;

  MessageModel({
    required this.id,
    required this.content,
    this.resultLink,
    this.hasSocialEngineering,
    this.isPhishing,
    this.isSafe,
    this.classificationReason,
    this.createdAt,
    this.updatedAt,
    this.riskScore,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      resultLink: json['result_link'],
      hasSocialEngineering: json['has_social_engineering'] ?? false,
      isPhishing: json['is_phishing'] ?? false,
      isSafe: json['is_safe'] ?? true,
      classificationReason: json['reason'] ?? json['classification_reason'],
      riskScore: json['risk_score']?.toDouble() ?? 0.0,
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
