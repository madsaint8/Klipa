class BundleModel {
  final String id;
  final String name;
  final double amount;
  final String currency;

  BundleModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    return BundleModel(
      id: json['id'].toString(),
      name: json['name'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currencyCode'],
    );
  }
}