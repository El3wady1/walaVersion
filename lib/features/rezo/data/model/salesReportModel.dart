class SalesReport {
  final int today;
  final int yesterday;
  final int thisMonth;
  final int lastMonth;

  SalesReport({
    required this.today,
    required this.yesterday,
    required this.thisMonth,
    required this.lastMonth,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      today: json["today"]["totalSales"] ?? 0,
      yesterday: json["yesterday"]["totalSales"] ?? 0,
      thisMonth: json["thisMonth"]["totalSales"] ?? 0,
      lastMonth: json["lastMonth"]["totalSales"] ?? 0,
    );
  }
}
