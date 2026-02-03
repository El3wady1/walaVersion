import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as f;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:http/http.dart' as http;
import 'package:saladafactory/core/utils/assets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RezoallsumBody extends StatefulWidget {
  @override
  State<RezoallsumBody> createState() => _RezoallsumBodyState();
}

class _RezoallsumBodyState extends State<RezoallsumBody> {
  List<dynamic> productionData = [];
  List<dynamic> filtetealData = [];
  bool isLoading = true;
  String errorMessage = '';

  // إحصائيات المبيعات
  double totalSalesAllTime = 0.0;
  double totalSalesLast24Hours = 0.0;
  int totalRecordsAllTime = 0;
  int totalRecordsLast24Hours = 0;

  // إحصائيات الأرباح (مبيعات - تكاليف)
  double totalProfitAllTime = 0.0;
  double todayProfit = 0.0;
  double yesterdayProfit = 0.0;
  double last7DaysProfit = 0.0;
  double last30DaysProfit = 0.0;

  // إحصائيات المبيعات الشهرية المضافة
  double currentMonthProfit = 0.0;
  double lastMonthProfit = 0.0;

  // بيانات الرسوم البيانية
  List<SalesData> dailySalesData = [];
  List<ProductSalesData> topProductsData = [];
  List<BranchSalesData> branchSalesData = [];
  List<HourlySalesData> hourlySalesData = [];
  List<MonthlySalesData> monthlySalesData = [];

  // Filter variables
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String selectedMainProduct = 'الكل'.tr();
  String selectedBranch = 'الكل'.tr();
  String selectedDeliveryApp = 'الكل'.tr();
  List<String> mainProductsList = ['الكل'.tr()];
  List<String> branchesList = ['الكل'.tr()];
  List<String> deliveryAppsList = ['الكل'.tr()];
  final TextEditingController searchController = TextEditingController();
  bool showFilter = false;
  bool showCharts = true;
  int _selectedChartTab = 0;

  // متغير للتحقق من نوع الجهاز
  bool get _isMobile => MediaQuery.of(context).size.width < 600;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await fetchProductionData();
  }

  Future<void> fetchProductionData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final response = await http
          .get(Uri.parse(Apiendpoints.baseUrl + Apiendpoints.rezoCasher.getAll))
          .timeout(const Duration(seconds: 30));

      if (mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(
            utf8.decode(response.bodyBytes),
          );

          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            setState(() {
              productionData = responseData['data'] ?? [];
              filtetealData = List.from(productionData);
              _extractMainProducts();
              _extractBranches();
              _extractDeliveryApps();
              _calculateSalesStatistics();
              _prepareChartData();
              isLoading = false;
            });
          } else {
            throw FormatException('Invalid data format received'.tr());
          }
        } else {
          throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}'.tr(),
          );
        }
      }
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'خطأ في الشبكة: $e'.tr();
          isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'انتهت مهلة الطلب: $e'.tr();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'خطأ غير متوقع: $e'.tr();
          isLoading = false;
        });
      }
    }
  }

  // دوال حساب المبيعات والأرباح
  double _calculateTotalSales(List<dynamic> receipts) {
    double total = 0;
    for (var record in receipts) {
      try {
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          total += quantity * price;
        }
      } catch (e) {
        continue;
      }
    }
    return total;
  }

  double _calculateTotalProfit(List<dynamic> receipts) {
    double totalProfit = 0;
    for (var record in receipts) {
      try {
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          final double cost =
              double.tryParse(item['product']['cost']?.toString() ?? '0.0') ??
              0.0;
          totalProfit += (quantity * price) - (quantity * cost);
        }
      } catch (e) {
        continue;
      }
    }
    return totalProfit;
  }

  // دوال التحويل الزمني
  DateTime _toSaudiTime(DateTime dateTime) =>
      dateTime.add(const Duration(hours: 0));
  DateTime _getCurrentSaudiTime() => _toSaudiTime(DateTime.now());
  DateTime _getStartOfDaySaudi(DateTime date) =>
      DateTime(date.year, date.month, date.day);
  DateTime _getEndOfDaySaudi(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  DateTime _getStartOfMonthSaudi(DateTime date) =>
      DateTime(date.year, date.month, 1);
  DateTime _getEndOfMonthSaudi(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

  // دوال حساب الأرباح للفترات المختلفة
  double _calculateProfitForPeriod(
    List<dynamic> receipts,
    DateTime startDate,
    DateTime endDate,
  ) {
    double profit = 0;
    for (var record in receipts) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        if (saudiRecordDate.isAfter(startDate) &&
            saudiRecordDate.isBefore(endDate)) {
          final items = record['item'] as List? ?? [];
          for (var item in items) {
            final double quantity =
                double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price =
                double.tryParse(item['product']['price']?.toString() ?? '') ??
                0.0;
            final double cost =
                double.tryParse(item['product']['cost']?.toString() ?? '0.0') ??
                0.0;
            profit += (quantity * price) - (quantity * cost);
          }
        }
      } catch (e) {
        continue;
      }
    }
    return profit;
  }

  double _calculateTodayProfit(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();
      final DateTime todayStart = _getStartOfDaySaudi(saudiNow);
      final DateTime todayEnd = _getEndOfDaySaudi(saudiNow);

      return _calculateProfitForPeriod(receipts, todayStart, todayEnd);
    } catch (e) {
      return 0.0;
    }
  }

  double calculateYesterdayProfit(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();
      final DateTime yesterdaySaudi = saudiNow.subtract(
        const Duration(days: 1),
      );
      final DateTime yesterdayStart = _getStartOfDaySaudi(yesterdaySaudi);
      final DateTime yesterdayEnd = _getEndOfDaySaudi(yesterdaySaudi);
      return _calculateProfitForPeriod(receipts, yesterdayStart, yesterdayEnd);
    } catch (e) {
      return 0.0;
    }
  }

  double _calculateLast7DaysProfit(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last7DaysStart = _getStartOfDaySaudi(
      saudiNow.subtract(const Duration(days: 7)),
    );
    final DateTime todayEnd = _getEndOfDaySaudi(saudiNow);
    return _calculateProfitForPeriod(receipts, last7DaysStart, todayEnd);
  }

  double _calculateLast30DaysProfit(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last30DaysStart = _getStartOfDaySaudi(
      saudiNow.subtract(const Duration(days: 30)),
    );
    final DateTime todayEnd = _getEndOfDaySaudi(saudiNow);
    return _calculateProfitForPeriod(receipts, last30DaysStart, todayEnd);
  }

  double _calculateCurrentMonthProfit(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime currentMonthStart = _getStartOfMonthSaudi(saudiNow);
    final DateTime currentMonthEnd = _getEndOfMonthSaudi(saudiNow);
    return _calculateProfitForPeriod(
      receipts,
      currentMonthStart,
      currentMonthEnd,
    );
  }

  double _calculateLastMonthProfit(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime lastMonth = DateTime(saudiNow.year, saudiNow.month - 1, 1);
    final DateTime lastMonthStart = _getStartOfMonthSaudi(lastMonth);
    final DateTime lastMonthEnd = _getEndOfMonthSaudi(lastMonth);
    return _calculateProfitForPeriod(receipts, lastMonthStart, lastMonthEnd);
  }

  // إعداد بيانات الرسوم البيانية
  void _prepareChartData() {
    _prepareDailySalesData();
    _prepareTopProductsData();
    _prepareBranchSalesData();
    _prepareHourlySalesData();
    _prepareMonthlySalesData();
  }

  void _prepareDailySalesData() {
    final Map<String, double> dailySales = {};
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last30Days = _getStartOfDaySaudi(
      saudiNow.subtract(const Duration(days: 30)),
    );

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        if (saudiRecordDate.isAfter(last30Days)) {
          final String dateKey = DateFormat(
            'yyyy-MM-dd',
          ).format(saudiRecordDate);

          double dayTotal = 0.0;
          final items = record['item'] as List? ?? [];
          for (var item in items) {
            final double quantity =
                double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price =
                double.tryParse(item['product']['price']?.toString() ?? '') ??
                0.0;
            dayTotal += quantity * price;
          }

          dailySales.update(
            dateKey,
            (value) => value + dayTotal,
            ifAbsent: () => dayTotal,
          );
        }
      } catch (e) {
        continue;
      }
    }

    dailySalesData =
        dailySales.entries
            .map(
              (entry) => SalesData(_formatArabicDate(entry.key), entry.value),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _prepareTopProductsData() {
    final Map<String, double> productSales = {};

    for (var record in filtetealData) {
      try {
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final product = item['product'] as Map?;
          final String productName =
              product?['name']?.toString() ?? 'غير معروف'.tr();
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(product?['price']?.toString() ?? '') ?? 0.0;
          final double total = quantity * price;

          productSales.update(
            productName,
            (value) => value + total,
            ifAbsent: () => total,
          );
        }
      } catch (e) {
        continue;
      }
    }

    topProductsData = productSales.entries
        .toList()
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(6)
        .map(
          (entry) =>
              ProductSalesData(_truncateText(entry.key, 15), entry.value),
        )
        .toList();
  }

  void _prepareBranchSalesData() {
    final Map<String, double> branchSales = {};

    for (var record in filtetealData) {
      try {
        final branch = record['branch'] as Map?;
        final String branchName =
            branch?['name']?.toString() ?? 'غير معروف'.tr();

        double branchTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          branchTotal += quantity * price;
        }

        branchSales.update(
          branchName,
          (value) => value + branchTotal,
          ifAbsent: () => branchTotal,
        );
      } catch (e) {
        continue;
      }
    }

    branchSalesData =
        branchSales.entries
            .map(
              (entry) =>
                  BranchSalesData(_truncateText(entry.key, 12), entry.value),
            )
            .toList()
          ..sort((a, b) => b.sales.compareTo(a.sales));
  }

  void _prepareHourlySalesData() {
    final Map<int, double> hourlySales = {};

    for (int i = 0; i < 24; i++) {
      hourlySales[i] = 0.0;
    }

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);
        final int hour = saudiRecordDate.hour;

        double hourTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          hourTotal += quantity * price;
        }

        hourlySales[hour] = hourlySales[hour]! + hourTotal;
      } catch (e) {
        continue;
      }
    }

    hourlySalesData =
        hourlySales.entries
            .map((entry) => HourlySalesData('${entry.key}:00', entry.value))
            .toList()
          ..sort(
            (a, b) => int.parse(
              a.hour.split(':')[0],
            ).compareTo(int.parse(b.hour.split(':')[0])),
          );
  }

  void _prepareMonthlySalesData() {
    final Map<String, double> monthlySales = {};
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last12Months = DateTime(
      saudiNow.year - 1,
      saudiNow.month,
      1,
    );

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        if (saudiRecordDate.isAfter(last12Months)) {
          final String monthKey = DateFormat('yyyy-MM').format(saudiRecordDate);

          double monthTotal = 0.0;
          final items = record['item'] as List? ?? [];
          for (var item in items) {
            final double quantity =
                double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price =
                double.tryParse(item['product']['price']?.toString() ?? '') ??
                0.0;
            monthTotal += quantity * price;
          }

          monthlySales.update(
            monthKey,
            (value) => value + monthTotal,
            ifAbsent: () => monthTotal,
          );
        }
      } catch (e) {
        continue;
      }
    }

    monthlySalesData =
        monthlySales.entries
            .map(
              (entry) =>
                  MonthlySalesData(_formatArabicMonth(entry.key), entry.value),
            )
            .toList()
          ..sort((a, b) => a.month.compareTo(b.month));
  }

  void _calculateSalesStatistics() {
    double allTimeSales = 0.0;
    double last24HoursSales = 0.0;
    int allTimeRecords = productionData.length;
    int last24HoursRecords = 0;

    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime twentyFourHoursAgo = saudiNow.subtract(
      const Duration(hours: 24),
    );

    for (var record in productionData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        double recordTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          recordTotal += quantity * price;
        }

        allTimeSales += recordTotal;

        if (saudiRecordDate.isAfter(twentyFourHoursAgo)) {
          last24HoursSales += recordTotal;
          last24HoursRecords++;
        }
      } catch (e) {
        continue;
      }
    }

    setState(() {
      totalSalesAllTime = allTimeSales;
      totalSalesLast24Hours = last24HoursSales;
      totalRecordsAllTime = allTimeRecords;
      totalRecordsLast24Hours = last24HoursRecords;

      totalProfitAllTime = _calculateTotalProfit(productionData);
      todayProfit = _calculateTodayProfit(productionData);
      yesterdayProfit = calculateYesterdayProfit(productionData);
      last7DaysProfit = _calculateLast7DaysProfit(productionData);
      last30DaysProfit = _calculateLast30DaysProfit(productionData);

      currentMonthProfit = _calculateCurrentMonthProfit(productionData);
      lastMonthProfit = _calculateLastMonthProfit(productionData);
    });
  }

  void _calculateFilteredStatistics() {
    double filteredAllTimeSales = 0.0;
    double filteredLast24HoursSales = 0.0;
    int filteredAllTimeRecords = filtetealData.length;
    int filteredLast24HoursRecords = 0;

    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime twentyFourHoursAgo = saudiNow.subtract(
      const Duration(hours: 24),
    );

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        double recordTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity =
              double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price =
              double.tryParse(item['product']['price']?.toString() ?? '') ??
              0.0;
          recordTotal += quantity * price;
        }

        filteredAllTimeSales += recordTotal;

        if (saudiRecordDate.isAfter(twentyFourHoursAgo)) {
          filteredLast24HoursSales += recordTotal;
          filteredLast24HoursRecords++;
        }
      } catch (e) {
        continue;
      }
    }

    setState(() {
      totalSalesAllTime = filteredAllTimeSales;
      totalSalesLast24Hours = filteredLast24HoursSales;
      totalRecordsAllTime = filteredAllTimeRecords;
      totalRecordsLast24Hours = filteredLast24HoursRecords;

      totalProfitAllTime = _calculateTotalProfit(filtetealData);
      todayProfit = _calculateTodayProfit(filtetealData);
      yesterdayProfit = calculateYesterdayProfit(filtetealData);
      last7DaysProfit = _calculateLast7DaysProfit(filtetealData);
      last30DaysProfit = _calculateLast30DaysProfit(filtetealData);

      currentMonthProfit = _calculateCurrentMonthProfit(filtetealData);
      lastMonthProfit = _calculateLastMonthProfit(filtetealData);

      _prepareChartData();
    });
  }

  void _extractMainProducts() {
    final Set<String> mainProducts = {'الكل'.tr()};

    for (var record in productionData) {
      final items = record['item'] as List? ?? [];
      for (var item in items) {
        final product = item['product'] as Map?;
        final productName = product?['name']?.toString();

        if (productName != null && productName.isNotEmpty) {
          mainProducts.add(productName);
        }
      }
    }

    setState(() {
      mainProductsList = mainProducts.toList();
    });
  }

  void _extractBranches() {
    final Set<String> branches = {'الكل'.tr()};

    for (var record in productionData) {
      final branch = record['branch'] as Map?;
      final branchName = branch?['name']?.toString();

      if (branchName != null && branchName.isNotEmpty) {
        branches.add(branchName);
      }
    }

    setState(() {
      branchesList = branches.toList();
    });
  }

  void _extractDeliveryApps() {
    final Set<String> deliveryApps = {'الكل'.tr()};

    for (var record in productionData) {
      final deliveryApp = record['deliveryApp'] as Map?;
      final deliveryAppName = deliveryApp?['name']?.toString();

      if (deliveryAppName != null && deliveryAppName.isNotEmpty) {
        deliveryApps.add(deliveryAppName);
      }
    }

    setState(() {
      deliveryAppsList = deliveryApps.toList();
    });
  }

  void applyFilter() {
    if (!mounted) return;

    setState(() {
      if (fromDate == null &&
          toDate == null &&
          selectedMainProduct == 'الكل'.tr() &&
          selectedBranch == 'الكل'.tr() &&
          selectedDeliveryApp == 'الكل'.tr() &&
          searchController.text.isEmpty) {
        filtetealData = List.from(productionData);
      } else {
        filtetealData = productionData.where((record) {
          try {
            // Date filter
            bool dateCondition = true;
            if (fromDate != null || toDate != null) {
              final DateTime? recordDate = _parseDate(record['createdAt']);
              if (recordDate == null) return false;

              final DateTime saudiRecordDate = _toSaudiTime(recordDate);

              bool fromCondition = true;
              bool toCondition = true;

              if (fromDate != null) {
                final fromDateStart = _getStartOfDaySaudi(fromDate!);
                fromCondition =
                    saudiRecordDate.isAfter(
                      fromDateStart.subtract(const Duration(seconds: 1)),
                    ) ||
                    _isSameDaySaudi(saudiRecordDate, fromDateStart);
              }

              if (toDate != null) {
                final toDateEnd = _getEndOfDaySaudi(toDate!);
                toCondition =
                    saudiRecordDate.isBefore(
                      toDateEnd.add(const Duration(seconds: 1)),
                    ) ||
                    _isSameDaySaudi(saudiRecordDate, toDateEnd);
              }

              dateCondition = fromCondition && toCondition;
              if (!dateCondition) return false;
            }

            // Branch filter
            bool branchCondition = true;
            if (selectedBranch != 'الكل'.tr()) {
              final branch = record['branch'] as Map?;
              final branchName = branch?['name']?.toString();
              branchCondition = branchName == selectedBranch;
              if (!branchCondition) return false;
            }

            // Delivery App filter
            bool deliveryAppCondition = true;
            if (selectedDeliveryApp != 'الكل'.tr()) {
              final deliveryApp = record['deliveryApp'] as Map?;
              final deliveryAppName = deliveryApp?['name']?.toString();
              deliveryAppCondition = deliveryAppName == selectedDeliveryApp;
              if (!deliveryAppCondition) return false;
            }

            // Main product filter
            bool mainProductCondition = true;
            if (selectedMainProduct != 'الكل'.tr()) {
              final items = record['item'] as List? ?? [];
              mainProductCondition = items.any((item) {
                final product = item['product'] as Map?;
                final productName = product?['name']?.toString();
                return productName == selectedMainProduct;
              });
              if (!mainProductCondition) return false;
            }

            // Search filter
            bool searchCondition = true;
            if (searchController.text.isNotEmpty) {
              final searchText = searchController.text.toLowerCase();
              final items = record['item'] as List? ?? [];
              searchCondition = items.any((item) {
                final product = item['product'] as Map?;
                final productName =
                    product?['name']?.toString().toLowerCase() ?? '';
                return productName.contains(searchText);
              });
              if (!searchCondition) return false;
            }

            return true;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      _calculateFilteredStatistics();
    });
  }

  void _performSearch() {
    applyFilter();
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-ddTHH:mm:ss.Z').parse(dateString);
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        } catch (e) {
          return null;
        }
      }
    }
  }

  String _formatEnglishDateOnly(DateTime dateTime) {
    final saudiTime = _toSaudiTime(dateTime);
    return DateFormat('yyyy-MM-dd', 'en').format(saudiTime);
  }

  String _formatBeautifulEnglishDate(DateTime dateTime) {
    final saudiTime = _toSaudiTime(dateTime);
    return DateFormat('yyyy/MM/dd - hh:mm a', 'en').format(saudiTime);
  }

  String _formatArabicDate(String englishDate) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(englishDate);
      final saudiDate = _toSaudiTime(date);
      return DateFormat('MM/dd', 'ar').format(saudiDate);
    } catch (e) {
      return englishDate;
    }
  }

  String _formatArabicMonth(String englishMonth) {
    try {
      final date = DateFormat('yyyy-MM').parse(englishMonth);
      final saudiDate = _toSaudiTime(date);
      return DateFormat('MM/yyyy', 'ar').format(saudiDate);
    } catch (e) {
      return englishMonth;
    }
  }

  bool _isSameDaySaudi(DateTime date1, DateTime date2) {
    final saudiDate1 = _toSaudiTime(date1);
    final saudiDate2 = _toSaudiTime(date2);

    return saudiDate1.year == saudiDate2.year &&
        saudiDate1.month == saudiDate2.month &&
        saudiDate1.day == saudiDate2.day;
  }

  void resetFilter() {
    if (!mounted) return;

    setState(() {
      fromDate = null;
      toDate = null;
      selectedMainProduct = 'الكل'.tr();
      selectedBranch = 'الكل'.tr();
      selectedDeliveryApp = 'الكل'.tr();
      searchController.clear();
      fromDateController.clear();
      toDateController.clear();
      filtetealData = List.from(productionData);
      _calculateSalesStatistics();
      _prepareChartData();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? _getCurrentSaudiTime())
          : (toDate ?? _getCurrentSaudiTime()),
      firstDate: DateTime(2020),
      lastDate: _getCurrentSaudiTime(),
      locale: const Locale('ar', 'SA'),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          fromDateController.text = _formatEnglishDateOnly(picked);
        } else {
          toDate = picked;
          toDateController.text = _formatEnglishDateOnly(picked);
        }
      });
      applyFilter();
    }
  }

  Map<String, Map<String, dynamic>> calculateProductSummary() {
    final Map<String, Map<String, dynamic>> productSummary = {};

    for (var record in filtetealData) {
      final DateTime? recordDate = _parseDate(record['createdAt']);
      if (recordDate == null) continue;

      final DateTime saudiRecordDate = _toSaudiTime(recordDate);
      final items = record['item'] as List? ?? [];

      for (var item in items) {
        bool shouldInclude = true;

        if (selectedBranch != 'الكل'.tr()) {
          final branch = record['branch'] as Map?;
          final branchName = branch?['name']?.toString();
          shouldInclude = branchName == selectedBranch;
        }

        if (shouldInclude && selectedDeliveryApp != 'الكل'.tr()) {
          final deliveryApp = record['deliveryApp'] as Map?;
          final deliveryAppName = deliveryApp?['name']?.toString();
          shouldInclude = deliveryAppName == selectedDeliveryApp;
        }

        if (shouldInclude && selectedMainProduct != 'الكل'.tr()) {
          final product = item['product'] as Map?;
          final productName = product?['name']?.toString();
          shouldInclude = productName == selectedMainProduct;
        }

        if (shouldInclude && searchController.text.isNotEmpty) {
          final searchText = searchController.text.toLowerCase();
          final product = item['product'] as Map?;
          final productName = product?['name']?.toString().toLowerCase() ?? '';
          shouldInclude = productName.contains(searchText);
        }

        if (!shouldInclude) continue;

        final product = item['product'] as Map?;
        final String productName =
            product?['name']?.toString() ?? 'غير معروف'.tr();
        final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
        final double price =
            double.tryParse(product?['price']?.toString() ?? '') ?? 0.0;
        final double cost =
            double.tryParse(product?['cost']?.toString() ?? '0.0') ?? 0.0;
        final double totalValue = quantity * price;
        final double totalCost = quantity * cost;
        final double profit = totalValue - totalCost;

        if (!productSummary.containsKey(productName)) {
          final branch = record['branch'] as Map?;
          final deliveryApp = record['deliveryApp'] as Map?;

          productSummary[productName] = {
            'totalQuantity': 0.0,
            'totalValue': 0.0,
            'totalCost': 0.0,
            'totalProfit': 0.0,
            'firstDate': saudiRecordDate,
            'lastDate': saudiRecordDate,
            'price': price,
            'cost': cost,
            'branch': branch?['name']?.toString() ?? "",
            'deliveryApp': deliveryApp?['name']?.toString() ?? "",
          };
        }

        productSummary[productName]!['totalQuantity'] =
            productSummary[productName]!['totalQuantity'] + quantity;
        productSummary[productName]!['totalValue'] =
            productSummary[productName]!['totalValue'] + totalValue;
        productSummary[productName]!['totalCost'] =
            productSummary[productName]!['totalCost'] + totalCost;
        productSummary[productName]!['totalProfit'] =
            productSummary[productName]!['totalProfit'] + profit;

        if (saudiRecordDate.isBefore(
          productSummary[productName]!['firstDate'],
        )) {
          productSummary[productName]!['firstDate'] = saudiRecordDate;
        }

        if (saudiRecordDate.isAfter(productSummary[productName]!['lastDate'])) {
          productSummary[productName]!['lastDate'] = saudiRecordDate;
        }
      }
    }

    final sortedEntries = productSummary.entries.toList()
      ..sort((a, b) => b.value['totalValue'].compareTo(a.value['totalValue']));

    return Map.fromEntries(sortedEntries);
  }

  // دوال الرسوم البيانية
  Widget _buildChartsSection() {
    if (!showCharts) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        children: [
          _buildChartTabs(),
          const SizedBox(height: 8),
          _buildSelectedChart(),
        ],
      ),
    );
  }

  Widget _buildChartTabs() {
    return Container(
      height: _isMobile ? 48 : 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChartTab('اليومية'.tr(), 0, Icons.trending_up),
          SizedBox(width: _isMobile ? 4 : 8),
          _buildChartTab('المنتجات'.tr(), 1, Icons.star),
          SizedBox(width: _isMobile ? 4 : 8),
          _buildChartTab('الفروع'.tr(), 2, Icons.business),
          SizedBox(width: _isMobile ? 4 : 8),
          _buildChartTab('الساعة'.tr(), 3, Icons.access_time),
          SizedBox(width: _isMobile ? 4 : 8),
          _buildChartTab('الشهرية'.tr(), 4, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildChartTab(String title, int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _isMobile ? 12 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _selectedChartTab == index
              ? Colors.teal.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedChartTab == index
                ? Colors.teal
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: _isMobile ? 14 : 16,
              color: _selectedChartTab == index ? Colors.teal : Colors.grey,
            ),
            SizedBox(height: _isMobile ? 2 : 4),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: _isMobile ? 10 : 12,
                fontWeight: _selectedChartTab == index
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedChartTab == index ? Colors.teal : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    final chartHeight = _isMobile ? 250.0 : 300.0;

    switch (_selectedChartTab) {
      case 0:
        return _buildDailySalesChart(chartHeight);
      case 1:
        return _buildTopProductsChart(chartHeight);
      case 2:
        return _buildBranchSalesChart(chartHeight);
      case 3:
        return _buildHourlySalesChart(chartHeight);
      case 4:
        return _buildMonthlySalesChart(chartHeight);
      default:
        return _buildDailySalesChart(chartHeight);
    }
  }

  Widget _buildDailySalesChart(double height) {
    return _buildChartCard(
      'المبيعات اليومية - 30 يوم'.tr(),
      Icons.trending_up,
      Colors.teal,
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelRotation: -45,
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'ar_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          LineSeries<SalesData, String>(
            dataSource: dailySalesData,
            xValueMapper: (SalesData sales, _) => sales.date,
            yValueMapper: (SalesData sales, _) => sales.sales,
            name: 'المبيعات'.tr(),
            color: Colors.teal,
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildTopProductsChart(double height) {
    return _buildChartCard(
      'أفضل المنتجات'.tr(),
      Icons.star,
      Colors.orange,
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
          labelRotation: -45,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'ar_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          BarSeries<ProductSalesData, String>(
            dataSource: topProductsData,
            xValueMapper: (ProductSalesData product, _) => product.productName,
            yValueMapper: (ProductSalesData product, _) => product.sales,
            name: 'المبيعات'.tr(),
            color: Colors.orange,
            width: 0.6,
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildBranchSalesChart(double height) {
    return _buildChartCard(
      'المبيعات حسب الفرع'.tr(),
      Icons.business,
      Colors.purple,
      height,
      SfCircularChart(
        margin: const EdgeInsets.all(0),
        series: <CircularSeries>[
          PieSeries<BranchSalesData, String>(
            dataSource: branchSalesData,
            xValueMapper: (BranchSalesData branch, _) => branch.branchName,
            yValueMapper: (BranchSalesData branch, _) => branch.sales,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
            ),
            enableTooltip: true,
          ),
        ],
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
          overflowMode: LegendItemOverflowMode.wrap,
        ),
      ),
    );
  }

  Widget _buildHourlySalesChart(double height) {
    return _buildChartCard(
      'المبيعات بالساعة'.tr(),
      Icons.access_time,
      Colors.blue,
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'ar_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          ColumnSeries<HourlySalesData, String>(
            dataSource: hourlySalesData,
            xValueMapper: (HourlySalesData data, _) => data.hour,
            yValueMapper: (HourlySalesData data, _) => data.sales,
            name: 'المبيعات'.tr(),
            color: Colors.blue,
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildMonthlySalesChart(double height) {
    return _buildChartCard(
      'المبيعات الشهرية'.tr(),
      Icons.calendar_today,
      Colors.green,
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'ar_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          LineSeries<MonthlySalesData, String>(
            dataSource: monthlySalesData,
            xValueMapper: (MonthlySalesData data, _) => data.month,
            yValueMapper: (MonthlySalesData data, _) => data.sales,
            name: 'المبيعات'.tr(),
            color: Colors.green,
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    IconData icon,
    Color color,
    double height,
    Widget chart,
  ) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: _isMobile ? 14 : 16, color: color),
              SizedBox(width: _isMobile ? 4 : 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: _isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(child: chart),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> productSummary =
        calculateProductSummary();

    return Directionality(
      textDirection: f.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "كاشير ريزو المجمع".tr(),
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: _isMobile ? 16 : 18,
            ),
          ),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              icon: Icon(
                showCharts ? Icons.bar_chart : Icons.bar_chart_outlined,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  showCharts = !showCharts;
                });
              },
              tooltip: 'الرسوم البيانية'.tr(),
            ),
            IconButton(
              icon: Icon(
                showFilter ? Icons.filter_alt_off : Icons.filter_alt,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              tooltip: 'الفلاتر'.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: fetchProductionData,
              tooltip: 'تحديث'.tr(),
            ),
          ],
        ),
        body: isLoading
            ? _buildLoadingWidget()
            : errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _buildMainContent(productSummary),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'جاري التحميل...'.tr(),
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        width: _isMobile ? 280 : 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.teal.shade400, size: 40),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: fetchProductionData,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                'إعادة المحاولة'.tr(),
                style: GoogleFonts.cairo(fontSize: 12),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Map<String, Map<String, dynamic>> productSummary) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(),
          if (showFilter) _buildFilterSection(),
          _buildStatsSection(),
          if (showCharts) _buildChartsSection(),
          _buildProductsTable(productSummary),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...'.tr(),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintStyle: GoogleFonts.cairo(fontSize: 12),
                isDense: true,
              ),
              onChanged: (value) {
                _performSearch();
              },
              style: GoogleFonts.cairo(fontSize: 12),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                searchController.clear();
                _performSearch();
              },
              tooltip: 'مسح'.tr(),
              padding: const EdgeInsets.all(4),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.teal.shade700, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'فلاتر البحث'.tr(),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey.shade600, size: 16),
                onPressed: () {
                  setState(() {
                    showFilter = false;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isMobile) _buildMobileFilter() else _buildDesktopFilter(),
        ],
      ),
    );
  }

  Widget _buildDesktopFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 180,
          child: _buildDateField('من تاريخ'.tr(), fromDateController, true),
        ),
        SizedBox(
          width: 180,
          child: _buildDateField('إلى تاريخ'.tr(), toDateController, false),
        ),
        SizedBox(width: 150, child: _buildBranchFilter()),
        SizedBox(width: 150, child: _buildDeliveryAppFilter()),
        SizedBox(width: 180, child: _buildProductFilter()),
        SizedBox(width: 120, child: _buildFilterButtons()),
      ],
    );
  }

  Widget _buildMobileFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateField('من تاريخ'.tr(), fromDateController, true),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildDateField('إلى تاريخ'.tr(), toDateController, false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBranchFilter()),
            const SizedBox(width: 6),
            Expanded(child: _buildDeliveryAppFilter()),
          ],
        ),
        const SizedBox(height: 8),
        _buildProductFilter(),
        const SizedBox(height: 8),
        _buildFilterButtons(),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    bool isFromDate,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Colors.grey.shade500,
          size: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.cairo(fontSize: 11),
        isDense: true,
      ),
      readOnly: true,
      onTap: () => _selectDate(context, isFromDate),
      style: GoogleFonts.cairo(fontSize: 11),
    );
  }

  Widget _buildBranchFilter() {
    return DropdownButtonFormField<String>(
      value: selectedBranch,
      decoration: InputDecoration(
        labelText: 'الفرع'.tr(),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.cairo(fontSize: 11),
        isDense: true,
      ),
      items: branchesList.map((String branch) {
        return DropdownMenuItem<String>(
          value: branch,
          child: Text(
            _truncateText(branch, 15),
            style: GoogleFonts.cairo(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedBranch = newValue;
          });
          applyFilter();
        }
      },
      style: GoogleFonts.cairo(fontSize: 11),
    );
  }

  Widget _buildDeliveryAppFilter() {
    return DropdownButtonFormField<String>(
      value: selectedDeliveryApp,
      decoration: InputDecoration(
        labelText: 'تطبيق التوصيل'.tr(),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.cairo(fontSize: 11),
        isDense: true,
      ),
      items: deliveryAppsList.map((String deliveryApp) {
        return DropdownMenuItem<String>(
          value: deliveryApp,
          child: Text(
            _truncateText(deliveryApp, 15),
            style: GoogleFonts.cairo(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedDeliveryApp = newValue;
          });
          applyFilter();
        }
      },
      style: GoogleFonts.cairo(fontSize: 11),
    );
  }

  Widget _buildProductFilter() {
    return DropdownButtonFormField<String>(
      value: selectedMainProduct,
      decoration: InputDecoration(
        labelText: 'المنتج'.tr(),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.cairo(fontSize: 11),
        isDense: true,
      ),
      items: mainProductsList.map((String product) {
        return DropdownMenuItem<String>(
          value: product,
          child: Text(
            _truncateText(product.replaceAll('\n', ' '), 15),
            style: GoogleFonts.cairo(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedMainProduct = newValue;
          });
          applyFilter();
        }
      },
      style: GoogleFonts.cairo(fontSize: 11),
    );
  }

  Widget _buildFilterButtons() {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: applyFilter,
          icon: const Icon(Icons.search, size: 14),
          label: Text('تطبيق'.tr(), style: GoogleFonts.cairo(fontSize: 11)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: resetFilter,
          icon: const Icon(Icons.clear, size: 14),
          label: Text(
            'إعادة تعيين'.tr(),
            style: GoogleFonts.cairo(fontSize: 11),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _isMobile ? 3 : 4;
    final spacing = _isMobile ? 4.0 : 6.0;

    final stats = [
      _StatItem(
        'المبيعات'.tr(),
        '${totalSalesAllTime.toStringAsFixed(0)}',
        Colors.blue.shade600,
        Icons.attach_money,
        true,
      ),
      _StatItem(
        'الفواتير'.tr(),
        totalRecordsAllTime.toString(),
        Colors.purple.shade600,
        Icons.list_alt,
        false,
      ),
      _StatItem(
        'اليوم'.tr(),
        '${todayProfit.toStringAsFixed(0)}',
        Colors.blue.shade700,
        Icons.today,
        true,
      ),
      _StatItem(
        'الأمس'.tr(),
        '${yesterdayProfit.toStringAsFixed(0)}',
        Colors.orange.shade700,
        Icons.history,
        true,
      ),
      _StatItem(
        'الشهر الحالي'.tr(),
        '${currentMonthProfit.toStringAsFixed(0)}',
        Colors.purple.shade700,
        Icons.calendar_today,
        true,
      ),
      _StatItem(
        'الشهر الماضي'.tr(),
        '${lastMonthProfit.toStringAsFixed(0)}',
        Colors.indigo.shade700,
        Icons.calendar_view_month,
        true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: _isMobile ? 0.9 : 1.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatCard(
            stat.title,
            stat.value,
            stat.color,
            stat.icon,
            stat.showCurrency,
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
    bool showCurrency,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: _isMobile ? 16 : 18),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _truncateText(value, 8),
                  style: GoogleFonts.cairo(
                    fontSize: _isMobile ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCurrency) ...[
                const SizedBox(width: 2),
                Image.asset(
                  AssetIcons.saudi_Riyal,
                  width: _isMobile ? 12 : 14,
                  height: _isMobile ? 12 : 14,
                  color: color,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: _isMobile ? 9 : 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(Map<String, Map<String, dynamic>> productSummary) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 400;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(6),
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'المنتجات المجمعة'.tr(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (productSummary.isNotEmpty)
                    Text(
                      '${productSummary.length} منتج'.tr(),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.teal.shade100,
                      ),
                    ),
                ],
              ),
            ),
            productSummary.isEmpty
                ? _buildEmptyState()
                : _buildDataTable(productSummary, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(
    Map<String, Map<String, dynamic>> productSummary,
    double screenWidth,
  ) {
    // تحديد عرض الأعمدة بناءً على حجم الشاشة
    late List<DataColumn> columns;

    if (screenWidth < 500) {
      // شاشات صغيرة جداً - نعرض الأساسيات فقط مع الفرع
      columns = _buildExtraSmallColumns();
    } else if (screenWidth < 700) {
      // شاشات صغيرة - نعرض الفرع والكمية والقيمة
      columns = _buildSmallColumns();
    } else if (screenWidth < 1000) {
      // شاشات متوسطة - نعرض جميع الأعمدة الأساسية
      columns = _buildMediumColumns();
    } else {
      // شاشات كبيرة - نعرض جميع الأعمدة
      columns = _buildLargeColumns();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 5,
          horizontalMargin: 12,
          headingRowHeight: 40,
          dataRowMinHeight: 38,
          headingTextStyle: GoogleFonts.cairo(
            fontSize: screenWidth < 500 ? 11 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
          dataTextStyle: GoogleFonts.cairo(
            fontSize: screenWidth < 500 ? 10 : 11,
          ),
          columns: columns,
          rows: _buildTableRows(productSummary, screenWidth),
        ),
      ),
    );
  }

  List<DataColumn> _buildExtraSmallColumns() {
    return [
      DataColumn(label: SizedBox(width: 40, child: Text('#'.tr()))),
      DataColumn(label: Expanded(child: Text('المنتج'.tr()))),
      DataColumn(label: Expanded(child: Text('الفرع'.tr()))),
      DataColumn(
        label: Expanded(child: Text('القيمة'.tr())),
        numeric: true,
      ),
    ];
  }

  List<DataColumn> _buildSmallColumns() {
    return [
      DataColumn(label: SizedBox(width: 5, child: Text('#'.tr()))),
      DataColumn(label: Expanded(child: Text('المنتج'.tr()))),
      DataColumn(label: Expanded(child: Text('الفرع'.tr()))),
      DataColumn(label: Expanded(child: Text('الكمية'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('القيمة'.tr())), numeric: true),
    ];
  }

  List<DataColumn> _buildMediumColumns() {
    return [
      DataColumn(label: SizedBox(width: 5, child: Text('#'.tr()))),
      DataColumn(label: Expanded(child: Text('المنتج'.tr()))),
      DataColumn(label: Expanded(child: Text('الفرع'.tr()))),
      DataColumn(label: Expanded(child: Text('السعر'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('الكمية'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('القيمة'.tr())), numeric: true),
    ];
  }

  List<DataColumn> _buildLargeColumns() {
    return [
      DataColumn(label: SizedBox(width: 5, child: Text('#'.tr()))),
      DataColumn(label: Expanded(child: Text('المنتج'.tr()))),
      DataColumn(label: Expanded(child: Text('الفرع'.tr()))),
      DataColumn(label: Expanded(child: Text('التطبيق'.tr()))),
      DataColumn(label: Expanded(child: Text('السعر'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('الكمية'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('التكلفة'.tr())), numeric: true),
      DataColumn(label: Expanded(child: Text('القيمة'.tr())), numeric: true),
    ];
  }
List<DataRow> _buildTableRows(
  Map<String, Map<String, dynamic>> productSummary,
  double screenWidth,
) {
  List<DataRow> rows = [];
  int index = 1;

  productSummary.forEach((productName, summary) {
    final double totalQuantity = summary['totalQuantity'];
    final double totalValue = summary['totalValue'];
    final double price = summary['price'];
    final String branch = summary['branch'] ?? 'غير محدد'.tr();
    final String deliveryApp = summary['deliveryApp'] ?? '';
    final double totalCost = summary['totalCost'];

    DataRow row;

    // ----------------------------------------------------
    // 📱  SMALL SCREEN  < 500 px
    // ----------------------------------------------------
    if (screenWidth < 500) {
      row = DataRow(
        cells: [
          DataCell(Center(child: Text(index.toString()))),
          DataCell(Text(_truncateText(productName, 12))),
          DataCell(Text(_truncateText(branch, 8))),
          DataCell(_buildValueCell(totalValue, screenWidth)),
        ],
      );
    }

    // ----------------------------------------------------
    // 📱 SMALL–MEDIUM SCREEN < 700 px
    // ----------------------------------------------------
    else if (screenWidth < 700) {
      row = DataRow(cells: [
        DataCell(Center(child: Text(index.toString()))),
        DataCell(Text(_truncateText(productName, 18))),
        DataCell(Text(_truncateText(branch, 12))),
        DataCell(Center(child: Text(totalQuantity.toStringAsFixed(0)))),
        DataCell(_buildValueCell(totalValue, screenWidth)),
      ]);
    }

    // ----------------------------------------------------
    // 💻 MEDIUM SCREEN < 1000 px
    // ----------------------------------------------------
    else if (screenWidth < 1000) {
      row = DataRow(cells: [
        DataCell(Center(child: Text(index.toString()))),
        DataCell(Text(_truncateText(productName, 22))),
        DataCell(Text(_truncateText(branch, 15))),
        DataCell(_buildPriceCell(price, screenWidth)),
        DataCell(Center(child: Text(totalQuantity.toStringAsFixed(0)))),
        DataCell(_buildValueCell(totalValue, screenWidth)),
      ]);
    }

    // ----------------------------------------------------
    // 🖥️ LARGE SCREEN ≥ 1000 px
    // ----------------------------------------------------
    else {
      row = DataRow(cells: [
        DataCell(Center(child: Text(index.toString()))),
        DataCell(Text(_truncateText(productName, 25))),
        DataCell(Text(_truncateText(branch, 15))),
        DataCell(Text(_truncateText(deliveryApp, 12))),
        DataCell(_buildPriceCell(price, screenWidth)),
        DataCell(Center(child: Text(totalQuantity.toStringAsFixed(0)))),
        DataCell(_buildPriceCell(totalCost, screenWidth)),
        DataCell(_buildValueCell(totalValue, screenWidth)),
      ]);
    }

    rows.add(row);
    index++;
  });

  return rows;
}
  Widget _buildValueCell(double value, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value.toStringAsFixed(0),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
                fontSize: screenWidth < 500 ? 10 : 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: screenWidth < 500 ? 2 : 4),
          Image.asset(
            AssetIcons.saudi_Riyal,
            width: screenWidth < 500 ? 10 : 12,
            height: screenWidth < 500 ? 10 : 12,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell(double price, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              price.toStringAsFixed(0),
              style: GoogleFonts.cairo(
                color: Colors.green.shade700,
                fontSize: screenWidth < 500 ? 10 : 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: screenWidth < 500 ? 2 : 4),
          Image.asset(
            AssetIcons.saudi_Riyal,
            width: screenWidth < 500 ? 8 : 10,
            height: screenWidth < 500 ? 8 : 10,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // دالة تقصير النصوص
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'لا توجد بيانات'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const List<Color> colors = [
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

// نماذج البيانات للرسوم البيانية
class SalesData {
  final String date;
  final double sales;

  SalesData(this.date, this.sales);
}

class ProductSalesData {
  final String productName;
  final double sales;

  ProductSalesData(this.productName, this.sales);
}

class BranchSalesData {
  final String branchName;
  final double sales;

  BranchSalesData(this.branchName, this.sales);
}

class HourlySalesData {
  final String hour;
  final double sales;

  HourlySalesData(this.hour, this.sales);
}

class MonthlySalesData {
  final String month;
  final double sales;

  MonthlySalesData(this.month, this.sales);
}

class _StatItem {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool showCurrency;

  _StatItem(this.title, this.value, this.color, this.icon, this.showCurrency);
}

extension ListExtensions<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}