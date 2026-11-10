class OperatorModel {
  final int id;
  final String name;
  final String countryCode;
  final String logoUrl;
  final bool supportsData;
  final bool supportsBundles;

  OperatorModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.logoUrl,
    required this.supportsData,
    required this.supportsBundles,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['operatorId'],
      name: json['name'],
      countryCode: json['countryCode'],
      logoUrl: json['logoUrls'][0],
      supportsData: json['data'] ?? false,
      supportsBundles: json['bundle'] ?? false,
    );
  }
}