import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as f;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:http/http.dart' as http;
import 'package:saladafactory/core/utils/assets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../data/model/salesReportModel.dart';
import '../../../data/services/fetchSalesReportServices.dart';

class Rezoallsum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "كاشير مجمع".tr(),
      theme: ThemeData(
        primaryColor: Color(0xFF74826A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF74826A),
          primary: Color(0xFF74826A),
          secondary: Color(0xFFEDBE2C),
          background: Color(0xFFF3F4EF),
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: RezoallsumBody(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ar', 'SA'),
    );
  }
}

class RezoallsumBody extends StatefulWidget {
  @override
  State<RezoallsumBody> createState() => _ReportsupplyproductionState();
}

class _ReportsupplyproductionState extends State<RezoallsumBody> {
  // ألوان التطبيق
  final Color primaryColor = Color(0xFF74826A);
  final Color secondaryColor = Color(0xFFEDBE2C);
  final Color accentColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);
  
  List<dynamic> productionData = [];
  List<dynamic> filtetealData = []; 
  bool isLoading = true;
  String errorMessage = '';

  // إحصائيات المبيعات
  double totalSalesAllTime = 0.0;
  double totalSalesLast24Hours = 0.0;
  int totalRecordsAllTime = 0;
  int totalRecordsLast24Hours = 0;
  
  // إحصائيات المبيعات 
  double totalSales = 0.0;
  double todaySales = 0.0;
  double yesterdaySales = 0.0;
  double last7DaysSales = 0.0;
  double last30DaysSales = 0.0;
  
  // إحصائيات المبيعات الشهرية
  double currentMonthSales = 0.0;
  double lastMonthSales = 0.0;
  
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

  // توقيت السعودية (+3 ساعات)
  static const Duration saudiTimeOffset = Duration(hours: 3);

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
      final response = await http.get(
        Uri.parse(Apiendpoints.baseUrl + Apiendpoints.rezoCasher.getAll),
      ).timeout(const Duration(seconds: 30));

      if (mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
          
          if (responseData.containsKey('data') && responseData['data'] is List) {
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
          throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
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

  // تحويل التاريخ إلى توقيت السعودية
  DateTime _toSaudiTime(DateTime dateTime) {
    return dateTime.add(saudiTimeOffset);
  }

  // الحصول على تاريخ اليوم الحالي بتوقيت السعودية
  DateTime _getCurrentSaudiTime() {
    return DateTime.now().add(saudiTimeOffset);
  }

  // الحصول على بداية اليوم بتوقيت السعودية
  DateTime _getStartOfDaySaudi(DateTime date) {
    final saudiDate = _toSaudiTime(date);
    return DateTime(saudiDate.year, saudiDate.month, saudiDate.day);
  }

  // الحصول على نهاية اليوم بتوقيت السعودية
  DateTime _getEndOfDaySaudi(DateTime date) {
    final saudiDate = _toSaudiTime(date);
    return DateTime(saudiDate.year, saudiDate.month, saudiDate.day, 23, 59, 59, 999);
  }

  // الحصول على بداية الشهر بتوقيت السعودية
  DateTime _getStartOfMonthSaudi(DateTime date) {
    final saudiDate = _toSaudiTime(date);
    return DateTime(saudiDate.year, saudiDate.month, 1);
  }

  // الحصول على نهاية الشهر بتوقيت السعودية
  DateTime _getEndOfMonthSaudi(DateTime date) {
    final saudiDate = _toSaudiTime(date);
    return DateTime(saudiDate.year, saudiDate.month + 1, 0, 23, 59, 59, 999);
  }

  // دوال حساب المبيعات (الإيرادات)
  double _calculateTotalSales(List<dynamic> receipts) {
    double total = 0;
    for (var record in receipts) {
      try {
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
          total += quantity * price;
        }
      } catch (e) {
        print('Error calculating sales: $e');
        continue;
      }
    }
    return total;
  }

  // دوال حساب المبيعات للفترات المختلفة (من الكود الأول)
  double _calculateSalesForPeriod(List<dynamic> receipts, DateTime startDate, DateTime endDate) {
    double sales = 0;

    for (var record in receipts) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);

        if (saudiRecordDate.isAfter(startDate) && saudiRecordDate.isBefore(endDate)) {
          final items = record['item'] as List? ?? [];

          for (var item in items) {
            final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

            // المبيعات = كمية × سعر
            final double revenue = quantity * price;

            sales += revenue;
          }
        }
      } catch (e) {
        print('Error calculating period sales: $e');
        continue;
      }
    }

    return sales;
  }

  double _calculateTodaySales(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();

      // تاريخ اليوم فقط بدون وقت
      final today = DateTime(saudiNow.year, saudiNow.month, saudiNow.day);

      double totalSales = 0;

      for (var record in receipts) {
        try {
          final DateTime? createdAt = _parseDate(record['createdAt']);
          if (createdAt == null) continue;

          final saudiRecord = _toSaudiTime(createdAt);
          final recordDate = DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

          // 🔥 تحقق: السجل يتبع اليوم فقط
          if (recordDate == today) {
            double recordSales = 0;
            final items = record['item'] as List? ?? [];

            for (var item in items) {
              final double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
              final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

              recordSales += qty * price;
            }

            totalSales += recordSales;
          }

        } catch (e) {
          print("❌ Error in record: $e");
        }
      }

      print("💰 Today's Sales: $totalSales");
      return totalSales;

    } catch (e) {
      print("❌ Error: $e");
      return 0.0;
    }
  }

  double _calculateYesterdaySales(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();

      final DateTime yesterday = saudiNow.subtract(const Duration(days: 1));
      final DateTime yDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

      print("=== حساب مبيعات الأمس ===");
      print("📅 الأمس: ${DateFormat('yyyy-MM-dd').format(yDate)}");

      double total = 0;

      for (var record in receipts) {
        try {
          final DateTime? createdAt = _parseDate(record['createdAt']);
          if (createdAt == null) continue;

          // تحويل لتوقيت السعودية
          final saudiRecord = _toSaudiTime(createdAt);

          // تحويل إلى تاريخ فقط
          final rDate = DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

          // 🔥 تحقق: هل السجل من "أمس"؟
          if (rDate == yDate) {
            print("✅ سجل أمس: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(saudiRecord)}");

            final items = record['item'] ?? [];
            for (var item in items) {
              final double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
              final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

              total += qty * price;
            }
          }

        } catch (e) {
          print("❌ خطأ في السجل: $e");
        }
      }

      print("💰 إجمالي مبيعات الأمس: $total ريال");
      return total;

    } catch (e) {
      print("❌ خطأ في حساب الأمس: $e");
      return 0.0;
    }
  }

  double _calculateLast7DaysSales(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();

    // تاريخ اليوم (بدون وقت)
    final DateTime today = DateTime(saudiNow.year, saudiNow.month, saudiNow.day);

    // بداية آخر 7 أيام
    final DateTime startDay = today.subtract(const Duration(days: 6));  
    // (حتى يكون الحساب شامل اليوم → 7 أيام كاملة)

    double total = 0;

    for (var record in receipts) {
      try {
        final DateTime? createdAt = _parseDate(record['createdAt']);
        if (createdAt == null) continue;

        final DateTime saudiRecord = _toSaudiTime(createdAt);
        final DateTime recordDate =
            DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

        // 🔥 تحقق: هل التاريخ ضمن آخر 7 أيام؟
        if (!recordDate.isBefore(startDay) && !recordDate.isAfter(today)) {
          final items = record['item'] ?? [];
          for (var item in items) {
            final double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

            total += qty * price;
          }
        }
      } catch (e) {
        print("❌ خطأ في سجل: $e");
      }
    }

    print("📊 إجمالي مبيعات آخر 7 أيام: $total ريال");
    return total;
  }

  double _calculateLast30DaysSales(List<dynamic> receipts) {
    final DateTime saudiNow = _getCurrentSaudiTime();

    // تاريخ اليوم (بدون وقت)
    final DateTime today = DateTime(saudiNow.year, saudiNow.month, saudiNow.day);

    // بداية آخر 30 يوم (اليوم + 29 يوم قبل)
    final DateTime startDay = today.subtract(const Duration(days: 29));

    double total = 0;

    for (var record in receipts) {
      try {
        final DateTime? createdAt = _parseDate(record['createdAt']);
        if (createdAt == null) continue;

        final DateTime saudiRecord = _toSaudiTime(createdAt);
        final DateTime recordDate =
            DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

        // 🔥 هل التاريخ ضمن آخر 30 يوم؟
        if (!recordDate.isBefore(startDay) && !recordDate.isAfter(today)) {
          final items = record['item'] ?? [];

          for (var item in items) {
            final double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

            total += qty * price;
          }
        }

      } catch (e) {
        print("❌ خطأ في سجل: $e");
      }
    }

    print("📅 إجمالي مبيعات آخر 30 يوم: $total ريال");
    return total;
  }

  double _calculateCurrentMonthSales(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();

      // بداية الشهر (اليوم 1)
      final DateTime startOfMonth = DateTime(saudiNow.year, saudiNow.month, 1);

      // تاريخ اليوم (لمنع حساب الأيام المستقبلية)
      final DateTime today = DateTime(saudiNow.year, saudiNow.month, saudiNow.day);

      double total = 0;

      print("=== حساب مبيعات الشهر الحالي ===");
      print("📅 الشهر: ${DateFormat('yyyy-MM').format(saudiNow)}");

      for (var record in receipts) {
        try {
          final DateTime? createdAt = _parseDate(record['createdAt']);
          if (createdAt == null) continue;

          final saudiRecord = _toSaudiTime(createdAt);
          final recordDate = DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

          // 🔥 هل السجل داخل الشهر الحالي؟
          if (!recordDate.isBefore(startOfMonth) && !recordDate.isAfter(today)) {
            print("✅ سجل داخل الشهر الحالي: ${DateFormat('yyyy-MM-dd').format(recordDate)}");

            final items = record['item'] ?? [];
            for (var item in items) {
              final double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
              final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;

              total += qty * price;
            }
          }

        } catch (e) {
          print("❌ خطأ في سجل من الشهر: $e");
        }
      }

      print("💰 إجمالي مبيعات الشهر الحالي: $total ريال");
      return total;

    } catch (e) {
      print("❌ خطأ في حساب الشهر الحالي: $e");
      return 0.0;
    }
  }

  double _calculateLastMonthSales(List<dynamic> receipts) {
    try {
      final DateTime saudiNow = _getCurrentSaudiTime();

      // تحديد الشهر الماضي
      final DateTime lastMonth = DateTime(saudiNow.year, saudiNow.month - 1, 1);

      // بداية الشهر الماضي
      final DateTime startOfLastMonth =
          DateTime(lastMonth.year, lastMonth.month, 1);

      // نهاية الشهر الماضي (اليوم الأخير)
      final DateTime endOfLastMonth =
          DateTime(lastMonth.year, lastMonth.month + 1, 0);

      double total = 0;

      print("=== حساب مبيعات الشهر الماضي ===");
      print("📅 الشهر الماضي: ${DateFormat('yyyy-MM').format(lastMonth)}");

      for (var record in receipts) {
        try {
          final DateTime? createdAt = _parseDate(record['createdAt']);
          if (createdAt == null) continue;

          final DateTime saudiRecord = _toSaudiTime(createdAt);
          final DateTime recordDate =
              DateTime(saudiRecord.year, saudiRecord.month, saudiRecord.day);

          // 🔥 هل السجل داخل الشهر الماضي؟
          if (!recordDate.isBefore(startOfLastMonth) &&
              !recordDate.isAfter(endOfLastMonth)) {
            print("✅ سجل من الشهر الماضي: ${DateFormat('yyyy-MM-dd').format(recordDate)}");

            for (var item in record['item'] ?? []) {
              final double qty = double.tryParse(item['qty'].toString()) ?? 0;
              final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0;

              total += qty * price;
            }
          }
        } catch (e) {
          print("❌ خطأ في معالجة سجل من الشهر الماضي: $e");
        }
      }

      print("💰 إجمالي مبيعات الشهر الماضي: $total ريال");
      return total;

    } catch (e) {
      print("❌ خطأ في حساب الشهر الماضي: $e");
      return 0.0;
    }
  }

  // إعداد بيانات الرسوم البيانية
  void _prepareChartData() {
    _prepareDailySalesData();
    _prepareTopProductsData();
    _prepareBranchSalesData();
    _prepareHourlySalesData();
    _prepareMonthlySalesData();
    _ensureDataIsSorted();
  }

  void _prepareDailySalesData() {
    final Map<DateTime, double> dailySales = {};
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last30Days = _getStartOfDaySaudi(saudiNow.subtract(const Duration(days: 30)));

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);
        
        if (saudiRecordDate.isAfter(last30Days)) {
          // استخدام التاريخ فقط بدون وقت
          final DateTime dateOnly = DateTime(
            saudiRecordDate.year, 
            saudiRecordDate.month, 
            saudiRecordDate.day
          );
          
          double dayTotal = 0.0;
          final items = record['item'] as List? ?? [];
          for (var item in items) {
            final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
            dayTotal += quantity * price;
          }
          
          dailySales.update(dateOnly, (value) => value + dayTotal, ifAbsent: () => dayTotal);
        }
      } catch (e) {
        print('Error in daily sales: $e');
        continue;
      }
    }

    // تحويل إلى قائمة وترتيب حسب التاريخ
    dailySalesData = dailySales.entries
        .map((entry) => SalesData(
          entry.key, 
          _formatChartDate(entry.key),
          entry.value
        ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // إضافة أيام مفقودة بين التواريخ
    dailySalesData = _fillMissingDates(dailySalesData);
    
    print('Daily sales data sorted: ${dailySalesData.map((e) => e.dateLabel).toList()}');
  }

  // دالة لإضافة أيام مفقودة
  List<SalesData> _fillMissingDates(List<SalesData> data) {
    if (data.isEmpty) return data;
    
    final List<SalesData> filledData = [];
    final DateTime firstDate = data.first.date;
    final DateTime lastDate = data.last.date;
    
    DateTime currentDate = firstDate;
    while (currentDate.isBefore(lastDate) || currentDate.isAtSameMomentAs(lastDate)) {
      final existingData = data.firstWhere(
        (item) => item.date.year == currentDate.year &&
                  item.date.month == currentDate.month &&
                  item.date.day == currentDate.day,
        orElse: () => SalesData(currentDate, _formatChartDate(currentDate), 0.0)
      );
      
      filledData.add(existingData);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return filledData;
  }

  void _prepareTopProductsData() {
    final Map<String, double> productSales = {};

    for (var record in filtetealData) {
      try {
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final product = item['product'] as Map?;
          final String productName = product?['name']?.toString() ?? 'غير معروف'.tr();
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(product?['price']?.toString() ?? '') ?? 0.0;
          final double total = quantity * price;
          
          productSales.update(productName, (value) => value + total, ifAbsent: () => total);
        }
      } catch (e) {
        print('Error in top products: $e');
        continue;
      }
    }

    topProductsData = productSales.entries
        .toList()
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(6)
        .map((entry) => ProductSalesData(
          _truncateText(entry.key, 15), 
          entry.value
        ))
        .toList();
  }

  void _prepareBranchSalesData() {
    final Map<String, double> branchSales = {};

    for (var record in filtetealData) {
      try {
        final branch = record['branch'] as Map?;
        final String branchName = branch?['name']?.toString() ?? 'غير معروف'.tr();
        
        double branchTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
          branchTotal += quantity * price;
        }
        
        branchSales.update(branchName, (value) => value + branchTotal, ifAbsent: () => branchTotal);
      } catch (e) {
        print('Error in branch sales: $e');
        continue;
      }
    }

    branchSalesData = branchSales.entries
        .map((entry) => BranchSalesData(_truncateText(entry.key, 12), entry.value))
        .toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));
  }

  void _prepareHourlySalesData() {
    final List<HourlySalesData> hourlyList = [];
    
    // إنشاء جميع الساعات من 0 إلى 23
    for (int i = 0; i < 24; i++) {
      hourlyList.add(HourlySalesData(_formatHourlyLabel(i), 0.0));
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
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
          hourTotal += quantity * price;
        }
        
        // تحديث قيمة الساعة المناسبة
        hourlyList[hour] = HourlySalesData(_formatHourlyLabel(hour), 
            hourlyList[hour].sales + hourTotal);
      } catch (e) {
        print('Error in hourly sales: $e');
        continue;
      }
    }

    hourlySalesData = hourlyList;
  }

  void _prepareMonthlySalesData() {
    final Map<DateTime, double> monthlySales = {};
    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime last12Months = DateTime(saudiNow.year - 1, saudiNow.month, 1);

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);
        
        if (saudiRecordDate.isAfter(last12Months)) {
          // استخدام أول يوم من الشهر للمقارنة
          final DateTime monthOnly = DateTime(
            saudiRecordDate.year, 
            saudiRecordDate.month, 
            1
          );
          
          double monthTotal = 0.0;
          final items = record['item'] as List? ?? [];
          for (var item in items) {
            final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
            final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
            monthTotal += quantity * price;
          }
          
          monthlySales.update(monthOnly, (value) => value + monthTotal, ifAbsent: () => monthTotal);
        }
      } catch (e) {
        print('Error in monthly sales: $e');
        continue;
      }
    }

    // تحويل إلى قائمة وترتيب حسب التاريخ
    monthlySalesData = monthlySales.entries
        .map((entry) => MonthlySalesData(
          entry.key, 
          _formatChartMonth(entry.key),
          entry.value
        ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // إضافة أشهر مفقودة
    monthlySalesData = _fillMissingMonths(monthlySalesData);
    
    print('Monthly sales data sorted: ${monthlySalesData.map((e) => e.monthLabel).toList()}');
  }

  // دالة لإضافة أشهر مفقودة
  List<MonthlySalesData> _fillMissingMonths(List<MonthlySalesData> data) {
    if (data.isEmpty) return data;
    
    final List<MonthlySalesData> filledData = [];
    final DateTime firstDate = data.first.date;
    final DateTime lastDate = data.last.date;
    
    DateTime currentDate = firstDate;
    while (currentDate.isBefore(lastDate) || currentDate.isAtSameMomentAs(lastDate)) {
      final existingData = data.firstWhere(
        (item) => item.date.year == currentDate.year &&
                  item.date.month == currentDate.month,
        orElse: () => MonthlySalesData(currentDate, _formatChartMonth(currentDate), 0.0)
      );
      
      filledData.add(existingData);
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }
    
    return filledData;
  }

  // دالة لتأكيد ترتيب البيانات
  void _ensureDataIsSorted() {
    // تأكيد ترتيب البيانات في جميع القوائم
    dailySalesData.sort((a, b) => a.date.compareTo(b.date));
    monthlySalesData.sort((a, b) => a.date.compareTo(b.date));
    
    // ترتيب البيانات الساعية
    hourlySalesData.sort((a, b) {
      final hourA = int.parse(a.hour.split(':')[0]);
      final hourB = int.parse(b.hour.split(':')[0]);
      return hourA.compareTo(hourB);
    });
    
    // ترتيب بيانات المنتجات تنازلياً حسب المبيعات
    topProductsData.sort((a, b) => b.sales.compareTo(a.sales));
    
    // ترتيب بيانات الفروع تنازلياً حسب المبيعات
    branchSalesData.sort((a, b) => b.sales.compareTo(a.sales));
  }

  void _calculateSalesStatistics() {
    double allTimeSales = 0.0;
    double last24HoursSales = 0.0;
    int allTimeRecords = productionData.length;
    int last24HoursRecords = 0;

    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime twentyFourHoursAgo = saudiNow.subtract(const Duration(hours: 24));

    for (var record in productionData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);
        
        double recordTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
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
      
      totalSales = _calculateTotalSales(productionData);
      todaySales = _calculateTodaySales(productionData);
      yesterdaySales = _calculateYesterdaySales(productionData);
      last7DaysSales = _calculateLast7DaysSales(productionData);
      last30DaysSales = _calculateLast30DaysSales(productionData);
      
      currentMonthSales = _calculateCurrentMonthSales(productionData);
      lastMonthSales = _calculateLastMonthSales(productionData);
    });
  }

  void _calculateFilteredStatistics() {
    double filteredAllTimeSales = 0.0;
    double filteredLast24HoursSales = 0.0;
    int filteredAllTimeRecords = filtetealData.length;
    int filteredLast24HoursRecords = 0;

    final DateTime saudiNow = _getCurrentSaudiTime();
    final DateTime twentyFourHoursAgo = saudiNow.subtract(const Duration(hours: 24));

    for (var record in filtetealData) {
      try {
        final DateTime? recordDate = _parseDate(record['createdAt']);
        if (recordDate == null) continue;

        final DateTime saudiRecordDate = _toSaudiTime(recordDate);
        
        double recordTotal = 0.0;
        final items = record['item'] as List? ?? [];
        for (var item in items) {
          final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
          final double price = double.tryParse(item['product']['price']?.toString() ?? '') ?? 0.0;
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
      
      totalSales = _calculateTotalSales(filtetealData);
      todaySales = _calculateTodaySales(filtetealData);
      yesterdaySales = _calculateYesterdaySales(filtetealData);
      last7DaysSales = _calculateLast7DaysSales(filtetealData);
      last30DaysSales = _calculateLast30DaysSales(filtetealData);
      
      currentMonthSales = _calculateCurrentMonthSales(filtetealData);
      lastMonthSales = _calculateLastMonthSales(filtetealData);
      
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

  // دالة للتحقق من التاريخ ضمن النطاق بتوقيت السعودية
  bool _isDateInSaudiRange(DateTime recordDate, DateTime? fromDate, DateTime? toDate) {
    // تحويل جميع التواريخ إلى توقيت السعودية
    final DateTime saudiRecordDate = _toSaudiTime(recordDate);
    final DateTime recordDateSaudiOnly = DateTime(
      saudiRecordDate.year, 
      saudiRecordDate.month, 
      saudiRecordDate.day
    );
    
    if (fromDate != null) {
      final DateTime saudiFromDate = _toSaudiTime(fromDate);
      final DateTime fromDateSaudiOnly = DateTime(
        saudiFromDate.year, 
        saudiFromDate.month, 
        saudiFromDate.day
      );
      
      if (recordDateSaudiOnly.isBefore(fromDateSaudiOnly)) {
        return false;
      }
    }
    
    if (toDate != null) {
      final DateTime saudiToDate = _toSaudiTime(toDate);
      final DateTime toDateSaudiOnly = DateTime(
        saudiToDate.year, 
        saudiToDate.month, 
        saudiToDate.day
      );
      
      if (recordDateSaudiOnly.isAfter(toDateSaudiOnly)) {
        return false;
      }
    }
    
    return true;
  }

  void applyFilter() {
    if (!mounted) return;

    setState(() {
      if (fromDate == null && toDate == null && 
          selectedMainProduct == 'الكل'.tr() && 
          selectedBranch == 'الكل'.tr() && 
          selectedDeliveryApp == 'الكل'.tr() && 
          searchController.text.isEmpty) {
        filtetealData = List.from(productionData);
      } else {
        filtetealData = productionData.where((record) {
          try {
            // Date filter بتوقيت السعودية
            bool dateCondition = true;
            if (fromDate != null || toDate != null) {
              final DateTime? recordDate = _parseDate(record['createdAt']);
              if (recordDate == null) return false;
              
              dateCondition = _isDateInSaudiRange(recordDate, fromDate, toDate);
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

            // Delivery App filter - إضافة فلتر deliveryApp
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
                final productName = product?['name']?.toString().toLowerCase() ?? '';
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

  String _formatEnglishDate(DateTime dateTime) {
    final saudiTime = _toSaudiTime(dateTime);
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a', 'en');
    return dateFormat.format(saudiTime);
  }

  String _formatEnglishDateOnly(DateTime dateTime) {
    final saudiTime = _toSaudiTime(dateTime);
    final dateFormat = DateFormat('yyyy-MM-dd', 'en');
    return dateFormat.format(saudiTime);
  }

  String _formatBeautifulEnglishDate(DateTime dateTime) {
    final saudiTime = _toSaudiTime(dateTime);
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'en');
    return dateFormat.format(saudiTime);
  }

  String _formatChartDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatChartMonth(DateTime date) {
    return '${date.month}/${date.year}';
  }

  String _formatHourlyLabel(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  String _formatArabicDate(String englishDate) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(englishDate);
      final saudiDate = _toSaudiTime(date);
      return DateFormat('MM/dd', 'en').format(saudiDate);
    } catch (e) {
      return englishDate;
    }
  }

  String _formatArabicMonth(String englishMonth) {
    try {
      final date = DateFormat('yyyy-MM').parse(englishMonth);
      final saudiDate = _toSaudiTime(date);
      return DateFormat('MM/yyyy', 'en').format(saudiDate);
    } catch (e) {
      return englishMonth;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
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
      initialDate: isFromDate ? (fromDate ?? _getCurrentSaudiTime()) : (toDate ?? _getCurrentSaudiTime()),
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
        final String productName = product?['name']?.toString() ?? 'غير معروف'.tr();
        final double quantity = double.tryParse(item['qty'].toString()) ?? 0.0;
        final double price = double.tryParse(product?['price']?.toString() ?? '') ?? 0.0;

        final double totalValue = quantity * price;

        if (!productSummary.containsKey(productName)) {
          final branch = record['branch'] as Map?;
          final deliveryApp = record['deliveryApp'] as Map?;

          productSummary[productName] = {
            'totalQuantity': 0.0,
            'totalValue': 0.0,
            'firstDate': saudiRecordDate,
            'lastDate': saudiRecordDate,
            'price': price,
            'branch': branch?['name']?.toString() ?? "",
            'deliveryApp': deliveryApp?['name']?.toString() ?? "",
          };
        }

        productSummary[productName]!['totalQuantity'] =
            productSummary[productName]!['totalQuantity'] + quantity;

        productSummary[productName]!['totalValue'] =
            productSummary[productName]!['totalValue'] + totalValue;

        if (saudiRecordDate.isBefore(productSummary[productName]!['firstDate'])) {
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
          _buildChartTab('منتجات'.tr(), 1, Icons.star),
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
        padding: EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedChartTab == index ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedChartTab == index ? primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _isMobile ? 14 : 16, color: _selectedChartTab == index ? primaryColor : Colors.grey),
            SizedBox(height: _isMobile ? 2 : 4),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: _isMobile ? 10 : 12,
                fontWeight: _selectedChartTab == index ? FontWeight.bold : FontWeight.normal,
                color: _selectedChartTab == index ? primaryColor : Colors.grey,
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
    if (dailySalesData.isEmpty) {
      return _buildEmptyChart('لا توجد بيانات للمبيعات اليومية');
    }
    
    return _buildChartCard(
      'المبيعات اليومية - 30 يوم'.tr(),
      Icons.trending_up,
      primaryColor,
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('dd/MM'),
          intervalType: DateTimeIntervalType.days,
          interval: dailySalesData.length > 15 ? 3 : 1,
          labelRotation: -45,
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'en_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          LineSeries<SalesData, DateTime>(
            dataSource: dailySalesData,
            xValueMapper: (SalesData sales, _) => sales.date,
            yValueMapper: (SalesData sales, _) => sales.sales,
            name: 'المبيعات'.tr(),
            color: primaryColor,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            dataLabelSettings: DataLabelSettings(
              isVisible: dailySalesData.length <= 10,
              labelAlignment: ChartDataLabelAlignment.auto,
              textStyle: GoogleFonts.cairo(fontSize: _isMobile ? 7 : 8),
            ),
          )
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (data, point, series, pointIndex, seriesIndex) {
            final salesData = data as SalesData;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('yyyy-MM-dd').format(salesData.date)}',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    'المبيعات: ${NumberFormat('#,##0').format(salesData.sales)} ر.س',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopProductsChart(double height) {
    if (topProductsData.isEmpty) {
      return _buildEmptyChart('لا توجد بيانات للمنتجات');
    }
    
    return _buildChartCard(
      'أفضل منتجات'.tr(),
      Icons.star,
      secondaryColor,
      height,
      SfCartesianChart(
        margin:  EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 7 : 7,fontWeight: FontWeight.w800),
          labelRotation: 0,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'en_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 5 : 5),
        ),
        series: [
          BarSeries<ProductSalesData, String>(
            dataSource: topProductsData,
            xValueMapper: (ProductSalesData product, _) => product.productName.split("\n")[0],
            yValueMapper: (ProductSalesData product, _) => product.sales,
            name: 'المبيعات'.tr(),
            color: secondaryColor,
            width: 0.6,
          )
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildBranchSalesChart(double height) {
    if (branchSalesData.isEmpty) {
      return _buildEmptyChart('لا توجد بيانات للفروع');
    }
    
    return _buildChartCard(
      'المبيعات حسب الفرع'.tr(),
      Icons.business,
      accentColor,
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
          )
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
    if (hourlySalesData.isEmpty) {
      return _buildEmptyChart('لا توجد بيانات للساعات');
    }
    
    return _buildChartCard(
      'المبيعات بالساعة'.tr(),
      Icons.access_time,
      primaryColor.withOpacity(0.8),
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: CategoryAxis(
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'en_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          ColumnSeries<HourlySalesData, String>(
            dataSource: hourlySalesData,
            xValueMapper: (HourlySalesData data, _) => data.hour,
            yValueMapper: (HourlySalesData data, _) => data.sales,
            name: 'المبيعات'.tr(),
            color: primaryColor.withOpacity(0.8),
          )
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildMonthlySalesChart(double height) {
    if (monthlySalesData.isEmpty) {
      return _buildEmptyChart('لا توجد بيانات شهرية');
    }
    
    return _buildChartCard(
      'المبيعات الشهرية'.tr(),
      Icons.calendar_today,
      secondaryColor.withOpacity(0.8),
      height,
      SfCartesianChart(
        margin: const EdgeInsets.all(0),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('MM/yyyy'),
          intervalType: DateTimeIntervalType.months,
          interval: 1,
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(locale: 'en_SA'),
          labelStyle: GoogleFonts.cairo(fontSize: _isMobile ? 8 : 10),
        ),
        series: [
          LineSeries<MonthlySalesData, DateTime>(
            dataSource: monthlySalesData,
            xValueMapper: (MonthlySalesData data, _) => data.date,
            yValueMapper: (MonthlySalesData data, _) => data.sales,
            name: 'المبيعات'.tr(),
            color: secondaryColor.withOpacity(0.8),
            width: 2,
            markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            dataLabelSettings: DataLabelSettings(
              isVisible: monthlySalesData.length <= 10,
              labelAlignment: ChartDataLabelAlignment.auto,
              textStyle: GoogleFonts.cairo(fontSize: _isMobile ? 7 : 8),
            ),
          )
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (data, point, series, pointIndex, seriesIndex) {
            final monthlyData = data as MonthlySalesData;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('MMMM yyyy', 'ar').format(monthlyData.date)}',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  Text(
                    'المبيعات: ${NumberFormat('#,##0').format(monthlyData.sales)} ر.س',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Colors.grey.shade400, size: 40),
            SizedBox(height: 8),
            Text(
              message.tr(),
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, IconData icon, Color color, double height, Widget chart) {
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

  // أزرار التحكم في العرض
  Widget _buildControlButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              icon: Icon(
                showFilter ? Icons.filter_alt_off : Icons.filter_alt,
                size: 16,
              ),
              label: Text(
                showFilter ?  "hide_filter".tr() :"show_filter".tr(),
                style: GoogleFonts.cairo(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: showFilter ? primaryColor.withOpacity(0.1) : primaryColor,
                foregroundColor: showFilter ? primaryColor : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: primaryColor),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showCharts = !showCharts;
                });
              },
              icon: Icon(
                showCharts ? Icons.bar_chart_outlined : Icons.bar_chart,
                size: 16,
              ),
              label: Text(
                showCharts ? "hide_charts".tr(): "show_charts".tr(),
                style: GoogleFonts.cairo(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: showCharts ? secondaryColor.withOpacity(0.1) : secondaryColor,
                foregroundColor: showCharts ? secondaryColor : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: secondaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> productSummary = calculateProductSummary();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "تقرير كاشير ريزو".tr(),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: _isMobile ? 16 : 18,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildMainContent(productSummary),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Loadingwidget(),
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
            Icon(
              Icons.error_outline,
              color: primaryColor,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
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
              label: Text('إعادة المحاولة'.tr(), style: GoogleFonts.cairo(fontSize: 12)),
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          _buildControlButtons(),
          _buildSearchBar(),
          if (showFilter)
            _buildFilterSection(),

          FutureBuilder<SalesReport>(
            future: fetchSalesReport(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: primaryColor,),
                ));
              }

              if (snapshot.hasError) {
                return Center(child: Text("حدث خطأ في جلب البيانات".tr()));
              }

              final data = snapshot.data!;

              return _buildStatsSection(
                yesterdaySaless: data.yesterday.toString(),
                todaySaless: data.today.toString(),
                currentMonthSaless: data.thisMonth.toString(),
                lastMonthSaless: data.lastMonth.toString(),
              );
            },
          ),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              Icon(Icons.filter_alt, color: primaryColor, size: 16),
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
        SizedBox(
          width: 150,
          child: _buildBranchFilter(),
        ),
        SizedBox(
          width: 150,
          child: _buildDeliveryAppFilter(),
        ),
        SizedBox(
          width: 180,
          child: _buildProductFilter(),
        ),
        SizedBox(
          width: 120,
          child: _buildFilterButtons(),
        ),
      ],
    );
  }

  Widget _buildMobileFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDateField('من تاريخ'.tr(), fromDateController, true)),
            const SizedBox(width: 6),
            Expanded(child: _buildDateField('إلى تاريخ'.tr(), toDateController, false)),
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

  Widget _buildDateField(String label, TextEditingController controller, bool isFromDate) {
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
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade500, size: 16),
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
            style: GoogleFonts.cairo(fontSize: 11,color: primaryColor,fontWeight: FontWeight.w500),
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
        labelStyle: GoogleFonts.cairo(fontSize: 11,color: primaryColor,fontWeight: FontWeight.w500),
        isDense: true,
      ),
      items: deliveryAppsList.map((String deliveryApp) {
        return DropdownMenuItem<String>(
          value: deliveryApp,
          child: Text(
            _truncateText(deliveryApp, 15),
            style: GoogleFonts.cairo(fontSize: 11,color: primaryColor,fontWeight: FontWeight.w500),
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
        labelText: 'منتج'.tr(),
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
      style: GoogleFonts.cairo(fontSize: 11,color: primaryColor,fontWeight: FontWeight.w500),
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
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: resetFilter,
          icon: const Icon(Icons.clear, size: 14),
          label: Text('إعادة تعيين'.tr(), style: GoogleFonts.cairo(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection({required String yesterdaySaless,required String todaySaless,required String currentMonthSaless,required String lastMonthSaless }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _isMobile ? 3 : 3;
    final spacing = _isMobile ? 0.0 : 0.0;
    
    final stats = [
      _StatItem('المبيعات'.tr(), '${totalSales.toStringAsFixed(0)}', primaryColor, Icons.attach_money, true),
      _StatItem('الفواتير'.tr(), totalRecordsAllTime.toString(), accentColor, Icons.list_alt, false),
      _StatItem('اليوم'.tr(), '$todaySaless', secondaryColor, Icons.today, true),
      _StatItem('الأمس'.tr(), '${yesterdaySaless}', primaryColor.withOpacity(0.8), Icons.history, true),
      _StatItem('الشهر الحالي'.tr(), '${currentMonthSaless}', secondaryColor.withOpacity(0.8), Icons.calendar_today, true),
      _StatItem('الشهر الماضي'.tr(), '${lastMonthSaless}', accentColor.withOpacity(0.8), Icons.calendar_view_month, true),
    ];

    return Container(
      margin: const EdgeInsets.all(6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: _isMobile ? 1.68 : 1.68,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatCard(
            stat.title,
            stat.value,
            stat.color,
            stat.icon,
            stat.showCurrency
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, bool showCurrency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: _isMobile ? 12 : 14),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _truncateText(value, 8),
                  style: GoogleFonts.cairo(
                    fontSize: MediaQuery.of(context).size.width*0.027,
                    fontWeight: FontWeight.w900,
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
              ]
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: MediaQuery.of(context).size.width*0.02,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w900
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateColumnWidths(double screenWidth) {
    if (screenWidth < 400) {
      final widths = {
        'indexWidth': 22.0,
        'productWidth': MediaQuery.of(context).size.width*0.17,
        'branchWidth': MediaQuery.of(context).size.width*0.14,
        'priceWidth':  MediaQuery.of(context).size.width*0.1,
        'quantityWidth': MediaQuery.of(context).size.width*0.1,
        'valueWidth':  MediaQuery.of(context).size.width*0.2,
      };
      widths['totalWidth'] = widths.values.reduce((a, b) => a + b) + 48;
      return widths;
    } else if (screenWidth < 600) {
      final widths = {
        'indexWidth': 22.0,
        'productWidth': MediaQuery.of(context).size.width*0.17,
        'branchWidth': MediaQuery.of(context).size.width*0.14,
        'priceWidth':  MediaQuery.of(context).size.width*0.1,
        'quantityWidth': MediaQuery.of(context).size.width*0.1,
        'valueWidth':  MediaQuery.of(context).size.width*0.2,
      };
      widths['totalWidth'] = widths.values.reduce((a, b) => a + b) + 48;
      return widths;
    } else {
      final widths = {
        'indexWidth': 22.0,
        'productWidth':  MediaQuery.of(context).size.width*0.17,
        'branchWidth':  MediaQuery.of(context).size.width*0.14,
        'priceWidth':  MediaQuery.of(context).size.width*0.1,
        'quantityWidth':  MediaQuery.of(context).size.width*0.1,
        'valueWidth':  MediaQuery.of(context).size.width*0.2,
      };
      widths['totalWidth'] = widths.values.reduce((a, b) => a + b) + 48;
      return widths;
    }
  }

  List<DataColumn> _buildResponsiveColumns(double screenWidth, Map<String, double> widths) {
    final isVerySmall = screenWidth < 400;
    
    if (isVerySmall) {
      return [
        DataColumn(
          label: SizedBox(
            width: widths['indexWidth'],
            child: const Center(child: Text('')),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: widths['productWidth'],
            child:  Text( "المنتج".tr()),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: widths['quantityWidth'],
            child:  Center(child: Text('الكمية'.tr())),
          ),
          numeric: true,
        ),
        DataColumn(
          label: SizedBox(
            width: widths['valueWidth'],
            child:  Center(child: Text('القيمة'.tr())),
          ),
          numeric: true,
        ),
      ];
    } else {
      return [
        DataColumn(
          label: SizedBox(
            width: widths['indexWidth'],
            child: const Center(child: Text('')),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: widths['productWidth'],
            child:  Text( "المنتج".tr()),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: widths['branchWidth'],
            child:  Center(child: Text('الفرع'.tr())),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: widths['priceWidth'],
            child:  Center(child: Text('السعر'.tr())),
          ),
          numeric: true,
        ),
        DataColumn(
          label: SizedBox(
            width: widths['quantityWidth'],
            child:  Center(child: Text('الكمية'.tr())),
          ),
          numeric: true,
        ),
        DataColumn(
          label: SizedBox(
            width: widths['valueWidth'],
            child:  Center(child: Text('القيمة'.tr())),
          ),
          numeric: true,
        ),
      ];
    }
  }

  Widget _buildProductsTable(Map<String, Map<String, dynamic>> productSummary) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.table_chart, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'منتجات المجمعة'.tr(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (productSummary.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${productSummary.length}'+ 'منتج'.tr(),
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
      )
    );
  }

  Widget _buildDataTable(Map<String, Map<String, dynamic>> productSummary, double screenWidth) {
    final isVerySmall = screenWidth < 400;
    
    final Map<String, double> columnWidths = _calculateColumnWidths(screenWidth);
    
    return SizedBox(
      width: screenWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: columnWidths['totalWidth']!,
          child: DataTable(
            columnSpacing: 8,
            horizontalMargin: 8,
            headingRowHeight: 36,
            dataRowMinHeight: 28,
            headingTextStyle: GoogleFonts.cairo(
              fontSize: isVerySmall ? 9 : 10,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            dataTextStyle: GoogleFonts.cairo(
              fontSize: isVerySmall ? 8 : 9,
            ),
            columns: _buildResponsiveColumns(screenWidth, columnWidths),
            rows: _buildTableRows(productSummary, isVerySmall, columnWidths),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows(
    Map<String, Map<String, dynamic>> productSummary, 
    bool isVerySmall,
    Map<String, double> widths
  ) {
    List<DataRow> rows = [];
    int index = 1;

    productSummary.forEach((productName, summary) {
      final double totalQuantity = summary['totalQuantity'];
      final double totalValue = summary['totalValue'];
      final double price = summary['price'];
      final String branchName = summary['branch'] ?? '';

      rows.add(DataRow(
        cells: isVerySmall
            ? _buildSmallCells(index, productName, totalQuantity, totalValue, widths)
            : _buildNormalCells(index, productName, branchName, totalQuantity, totalValue, price, widths),
      ));
      index++;
    });

    return rows;
  }

  List<DataCell> _buildSmallCells(int index, String productName, double totalQuantity, double totalValue, Map<String, double> widths) {
    return [
      DataCell(
        Container(
          width: widths['indexWidth']!,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['productWidth']!,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            _truncateText(productName.split("\n")[0], 20),
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['quantityWidth']!,
          alignment: Alignment.center,
          child: Text(
            totalQuantity.toStringAsFixed(0),
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['valueWidth']!,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _getColorForIndex(index - 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  totalValue.toStringAsFixed(0),
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Image.asset(
                AssetIcons.saudi_Riyal,
                width: 10,
                height: 10,
                color: Colors.white,
              ),]
            )))]; }

  List<DataCell> _buildNormalCells(
    int index, 
    String productName, 
    String branchName,
    double totalQuantity, 
    double totalValue, 
    double price,
    Map<String, double> widths
  ) {
    return [
      DataCell(
        Container(
          width: widths['indexWidth']!,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['productWidth']!,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            _truncateText(productName.split("\n")[0], 25),
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['branchWidth']!,
          alignment: Alignment.center,
          child: Text(
            _truncateText(selectedBranch, 12),
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: accentColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['priceWidth']!,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                price.toStringAsFixed(0),
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Image.asset(
                AssetIcons.saudi_Riyal,
                width: 10,
                height: 10,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['quantityWidth']!,
          alignment: Alignment.center,
          child: Text(
            totalQuantity.toStringAsFixed(0),
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: widths['valueWidth']!,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: _getColorForIndex(index - 1),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _getColorForIndex(index - 1).withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  totalValue.toStringAsFixed(0),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Image.asset(
                AssetIcons.saudi_Riyal,
                width: 12,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 36, color: accentColor),
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
    final List<Color> colors = [
      primaryColor,
      secondaryColor,
      accentColor,
      primaryColor.withOpacity(0.8),
      secondaryColor.withOpacity(0.8),
      accentColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      secondaryColor.withOpacity(0.6),
      accentColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
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

// نماذج البيانات للرسوم البيانية (محدثة)
class SalesData {
  final DateTime date;
  final String dateLabel;
  final double sales;

  SalesData(this.date, this.dateLabel, this.sales);
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
  final DateTime date;
  final String monthLabel;
  final double sales;

  MonthlySalesData(this.date, this.monthLabel, this.sales);
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