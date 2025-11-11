class JwtAuthResponseModel {
  final String token;

  JwtAuthResponseModel({required this.token});

  factory JwtAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return JwtAuthResponseModel(token: json['token']);
  }
}
