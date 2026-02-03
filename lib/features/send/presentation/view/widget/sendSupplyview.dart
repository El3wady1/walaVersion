import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'dart:convert';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:saladafactory/features/home/presentation/view/widget/bannnerHome.dart';
import 'package:saladafactory/features/send/presentation/view/widget/lastSendView.dart';
import 'package:saladafactory/features/send/presentation/view/widget/sendSupplyview.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/material.dart' as material;

class SendSupplyView extends StatefulWidget {
  final String role;
  SendSupplyView({required this.role});

  @override
  _SendSupplyViewState createState() => _SendSupplyViewState();
}

class _SendSupplyViewState extends State<SendSupplyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SendSupplyBodyView(role: widget.role,)

    );
  }
}

class SendSupplyBodyView extends StatefulWidget {
  final String role;
  SendSupplyBodyView({required this.role});

  @override
  _SendSupplyBodyViewState createState() => _SendSupplyBodyViewState();
}

class _SendSupplyBodyViewState extends State<SendSupplyBodyView> {
  List<SendSupplyItem> items = [];
  List<SendSupplyItem> filteredItems = [];
  List<AdditionalProduct> additionalProducts = [];
  List<AdditionalProduct> filteredAdditionalProducts = [];
  Map<String, TextEditingController> quantityControllers = {};
  bool isLoading = false;
  bool isLoadingAdditional = false;
  String apiUrl = "${Apiendpoints.baseUrl}${Apiendpoints.orderSupply.getOrderSof2Days}";
  String additionalProductsUrl =
      "${Apiendpoints.baseUrl}${Apiendpoints.productOP.getAll}";
  String submitUrl =
      "${Apiendpoints.baseUrl + Apiendpoints.productionSupply.request}";
  String branchesUrl = "${Apiendpoints.baseUrl}${Apiendpoints.branch.getall}";

  // Colors
  final Color primaryColor = Color(0xFF74826A);
  final Color accentColor = Color(0xFFEDBE2C);
  final Color secondaryColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);
  final Color textColor = Color(0xFF333333);
  final Color lightTextColor = Color(0xFF666666);

  List<Branch> branches = [];
  Branch? selectedBranch;
  bool showAdditionalProducts = false;
  List<String> orderIds = [];

  @override
  void initState() {
    super.initState();

    _loadBranches();
    _loadSendSupplyRequests();
    _loadAdditionalProducts(); 
  }

  @override
  void dispose() {
    quantityControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // دالة مساعدة للحصول على متحكم آمن
  TextEditingController _getController(String id) {
    if (quantityControllers.containsKey(id)) {
      return quantityControllers[id]!;
    } else {
      final controller = TextEditingController(text: '0');
      quantityControllers[id] = controller;
      return controller;
    }
  }

  Future<void> _loadBranches() async {
    if (!mounted) return;

    try {
      print("📋 جاري تحميل الفروع من: $branchesUrl");
      final response = await http.get(Uri.parse(branchesUrl)).timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ استجابة الفروع: ${data['data']?.length ?? 0} فرع");

        final List<dynamic> branchesData = data['data'] ?? [];
        
        List<Branch> loadedBranches = [];
        for (var branch in branchesData) {
          try {
            final newBranch = Branch(
              id: branch['_id'] ?? '',
              name: branch['name'] ?? 'غير معروف'.tr(),
            );
            loadedBranches.add(newBranch);
            print('   ✅ فرع: ${newBranch.name}');
          } catch (e) {
            print("⚠️ خطأ في إنشاء فرع: $e");
            continue;
          }
        }

        if (!mounted) return;
        setState(() {
          branches = loadedBranches;
          if (selectedBranch == null && branches.isNotEmpty) {
            selectedBranch = branches.first;
            print('🎯 الفرع المحدد افتراضيًا: ${selectedBranch!.name}');
            _filterItems();
          }
        });
      } else {
        print("❌ فشل تحميل الفروع: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ خطأ في تحميل الفروع: $e");
    }
  }

  Future<void> _loadAdditionalProducts() async {
    if (!mounted) return;

    setState(() => isLoadingAdditional = true);

    try {
      print("📥 جاري تحميل المنتجات الإضافية من: $additionalProductsUrl");
      final response = await http
          .get(Uri.parse(additionalProductsUrl))
          .timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ استجابة المنتجات الإضافية: ${data['data']?.length ?? 0} منتج");

        final List<dynamic> productsData = data['data'] ?? [];
        
        List<AdditionalProduct> loadedProducts = [];
        for (var product in productsData) {
          try {
            // تصفية المنتجات الإضافية فقط
            if (product['isorderSupply'] == true) {
              final newProduct = AdditionalProduct(
                id: product['_id'] ?? '',
                name: product['name'] ?? 'غير معروف'.tr(),
                package: product['packSize']?.toString() ?? '0',
                packageUnitname: product['packageUnit']?['name'] ?? '',
                mainProductId: product['mainProductOP']?['_id'] ?? '',
                mainProductName: product['mainProductOP']?['name'] ?? '',
                mainProductOrder: product['mainProductOP']?['order'] ?? 0,
                branchId: product['branch']?['_id'] ?? '',
                branchName: product['branch']?['name'] ?? '',
              );
              loadedProducts.add(newProduct);
              print('   ✅ منتج إضافي: ${newProduct.name} (الفرع: ${newProduct.branchName})');
            }
          } catch (e) {
            print("⚠️ خطأ في معالجة المنتج: $e");
            continue;
          }
        }

        if (!mounted) return;
        setState(() {
          additionalProducts = loadedProducts;
          _filterAdditionalProducts();
          
          print('📊 إجمالي المنتجات الإضافية: ${additionalProducts.length}');
          print('📊 المنتجات الإضافية للفرع الحالي: ${filteredAdditionalProducts.length}');
        });
      } else {
        print("❌ فشل تحميل المنتجات الإضافية: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ خطأ في تحميل المنتجات الإضافية: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingAdditional = false);
      }
    }
  }

  void _filterAdditionalProducts() {
    if (selectedBranch == null) {
      setState(() {
        filteredAdditionalProducts = [];
        showAdditionalProducts = false;
      });
      return;
    }

    setState(() {
      filteredAdditionalProducts = additionalProducts.where((product) {
        // إذا كان المنتج مرتبطًا بفرع محدد، قارن مع الفرع المحدد
        if (product.branchId.isNotEmpty) {
          return product.branchId == selectedBranch!.id;
        }
        // إذا لم يكن مرتبطًا بفرع، عرضه للجميع
        return true;
      }).toList();

      print('🎯 المنتجات الإضافية للفرع "${selectedBranch!.name}": ${filteredAdditionalProducts.length}');
      
      // إخفاء قسم المنتجات الإضافية إذا لم يكن هناك منتجات
      if (filteredAdditionalProducts.isEmpty) {
        showAdditionalProducts = false;
      }
    });
  }

  Future<void> _loadSendSupplyRequests() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      print("📦 جاري تحميل طلبات التوريد من: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl)).timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ استجابة طلبات التوريد: ${data['data']?.length ?? 0} طلب");

        final List<dynamic> SendSupplyData = data['data'] ?? [];

        // Map لتخزين أحدث طلب لكل فرع
        Map<String, MapEntry<String, DateTime>> latestOrdersPerBranch = {};
        Set<String> uniqueBranches = {};

        // المرور الأول: العثور على أحدث طلب لكل فرع
        for (var item in SendSupplyData) {
          try {
            final branchName = item['branch']['name'] ?? 'غير معروف'.tr();
            uniqueBranches.add(branchName);

            final orderNameRaw = item['ordername'] ?? '';
            final regex = RegExp(r'طلب توريد - (\d{1,2})/(\d{1,2})/(\d{4}) - (\d{1,2}):(\d{1,2})');
            final match = regex.firstMatch(orderNameRaw);

            if (match != null) {
              final day = int.parse(match.group(1)!);
              final month = int.parse(match.group(2)!);
              final year = int.parse(match.group(3)!);
              final hour = int.parse(match.group(4)!);
              final minute = int.parse(match.group(5)!);

              final parsedDate = DateTime(year, month, day, hour, minute);

              if (!latestOrdersPerBranch.containsKey(branchName) ||
                  parsedDate.isAfter(latestOrdersPerBranch[branchName]!.value)) {
                latestOrdersPerBranch[branchName] = MapEntry(orderNameRaw, parsedDate);
              }
            }
          } catch (e) {
            print("⚠️ خطأ في معالجة الطلب: $e");
            continue;
          }
        }

        // المرور الثاني: جمع جميع العناصر من الطلبات الأحدث
        List<SendSupplyItem> allItems = [];
        for (var item in SendSupplyData) {
          try {
            final branchName = item['branch']['name'] ?? 'غير معروف'.tr();
            final orderName = item['ordername'] ?? '';

            if (latestOrdersPerBranch.containsKey(branchName) &&
                latestOrdersPerBranch[branchName]!.key == orderName &&
                item['isSend'] == false) {
              
              if (!orderIds.contains(item['_id'])) {
                orderIds.add(item['_id']);
              }

              final newItem = SendSupplyItem(
                id: item['_id'] ?? '',
                productId: item['product']['_id'] ?? '',
                name: item['product']['name'] ?? 'غير معروف'.tr(),
                package: item['package']?.toString() ?? '0',
                requestedQty: (item['qty'] is int)
                    ? (item['qty'] as int).toDouble()
                    : (item['qty'] as double),
                branch: branchName,
                orderName: orderName,
                packageUnitname: item['packageUnit']?['name'] ?? "",
                mainProductId: item['mainProductOP']?['_id'] ?? '',
                mainProductName: item['mainProductOP']?['name'] ?? '',
                mainProductOrder: item['mainProductOP']?['order'] ?? 0,
              );

              allItems.add(newItem);
              print('   ✅ طلب: ${newItem.name} - الفرع: $branchName - الكمية: ${newItem.requestedQty}');
            }
          } catch (e) {
            print("⚠️ خطأ في إنشاء عنصر التوريد: $e");
            continue;
          }
        }

        // تجميع العناصر حسب المنتج الرئيسي مع جمع الكميات للمنتجات المتشابهة
        List<SendSupplyItem> groupedItems = _groupAndSortItems(allItems);

        if (!mounted) return;
        setState(() {
          items = groupedItems;
          quantityControllers = {};
          for (var item in items) {
            if (!item.isBranchHeader && !item.isMainProduct) {
              quantityControllers[item.id] = TextEditingController(
                  text: _formatQuantity(item.requestedQty));
            }
          }

          // تهيئة المتحكمات للمنتجات الإضافية
          for (var product in filteredAdditionalProducts) {
            quantityControllers[product.id] = TextEditingController(text: '0');
          }
          
          print('📊 إجمالي العناصر المجمعة: ${items.length}');
          print('📊 المتحكمات المبدئية: ${quantityControllers.length}');
        });
      } else {
        throw Exception('${"فشل في تحميل البيانات من السيرفر:".tr()} ${response.statusCode}');
      }
    } catch (e) {
      print("❌ خطأ في تحميل طلبات التوريد: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _formatQuantity(double quantity) {
    // التحقق مما إذا كانت الكمية تحتوي على كسور
    if (quantity % 1 == 0) {
      // إذا كانت كمية صحيحة
      return quantity.toStringAsFixed(0);
    } else {
      // إذا كانت كمية كسرية
      return quantity.toStringAsFixed(2);
    }
  }

  List<SendSupplyItem> _groupAndSortItems(List<SendSupplyItem> allItems) {
    List<SendSupplyItem> groupedItems = [];
    
    // تجميع العناصر حسب الفرع أولاً
    Map<String, List<SendSupplyItem>> branchItemsMap = {};
    for (var item in allItems) {
      if (!branchItemsMap.containsKey(item.branch)) {
        branchItemsMap[item.branch] = [];
      }
      branchItemsMap[item.branch]!.add(item);
    }

    // بناء القائمة النهائية مع التجميع والترتيب
    branchItemsMap.forEach((branch, items) {
      // إضافة عنوان الفرع
      groupedItems.add(SendSupplyItem(
        id: branch,
        productId: '',
        name: branch,
        package: '',
        requestedQty: 0,
        branch: branch,
        orderName: '',
        packageUnitname: '',
        isBranchHeader: true,
      ));

      // تجميع العناصر حسب المنتج الرئيسي أولاً
      Map<String, List<SendSupplyItem>> mainProductGroups = {};
      for (var item in items) {
        String mainProductKey = item.mainProductId.isNotEmpty 
            ? item.mainProductId 
            : 'without_main_${item.productId}';
        
        if (!mainProductGroups.containsKey(mainProductKey)) {
          mainProductGroups[mainProductKey] = [];
        }
        mainProductGroups[mainProductKey]!.add(item);
      }

      // تحويل الـ Map إلى قائمة وترتيبها حسب حقل order
      List<MapEntry<String, List<SendSupplyItem>>> sortedMainProducts = 
          mainProductGroups.entries.toList()
            ..sort((a, b) {
              // الحصول على قيمة order من العنصر الأول في كل مجموعة
              int orderA = a.value.first.mainProductOrder;
              int orderB = b.value.first.mainProductOrder;
              return orderA.compareTo(orderB);
            });

      // إضافة المجموعات المرتبة إلى القائمة
      for (var entry in sortedMainProducts) {
        String mainProductKey = entry.key;
        List<SendSupplyItem> subItems = entry.value;

        if (subItems.isNotEmpty) {
          // إذا كان هناك منتج رئيسي، نضيف عنوانه
          if (mainProductKey != 'without_main_${subItems.first.productId}' && 
              subItems.first.mainProductName.isNotEmpty) {
            groupedItems.add(SendSupplyItem(
              id: mainProductKey,
              productId: mainProductKey,
              name: subItems.first.mainProductName,
              package: '',
              requestedQty: 0,
              branch: branch,
              orderName: '',
              packageUnitname: '',
              isMainProduct: true,
              mainProductOrder: subItems.first.mainProductOrder,
            ));
          }
          
          // تجميع المنتجات المتشابهة في نفس المجموعة
          Map<String, SendSupplyItem> uniqueProducts = {};
          for (var subItem in subItems) {
            String productKey = '${subItem.productId}_${subItem.name}_${subItem.package}_${subItem.packageUnitname}';
            
            if (uniqueProducts.containsKey(productKey)) {
              // إذا المنتج موجود مسبقاً، نجمع الكمية
              uniqueProducts[productKey]!.requestedQty += subItem.requestedQty;
            } else {
              // إذا المنتج جديد، نضيفه
              uniqueProducts[productKey] = SendSupplyItem(
                id: subItem.id,
                productId: subItem.productId,
                name: subItem.name,
                package: subItem.package,
                requestedQty: subItem.requestedQty,
                branch: subItem.branch,
                orderName: subItem.orderName,
                packageUnitname: subItem.packageUnitname,
                mainProductId: subItem.mainProductId,
                mainProductName: subItem.mainProductName,
                mainProductOrder: subItem.mainProductOrder,
              );
            }
          }
          
          // إضافة المنتجات المميزة إلى القائمة
          groupedItems.addAll(uniqueProducts.values);
        }
      }
    });

    return groupedItems;
  }

  void _filterItems() {
    if (!mounted || selectedBranch == null) return;

    setState(() {
      filteredItems = items.where((item) {
        return item.branch == selectedBranch!.name || item.isBranchHeader;
      }).toList();
      
      _filterAdditionalProducts();
      
      print('🎯 العناصر المصفاة للفرع "${selectedBranch!.name}": ${filteredItems.length}');
      print('🎯 المنتجات الإضافية المصفاة: ${filteredAdditionalProducts.length}');
    });
  }

  bool get _isQadiBranch {
    return selectedBranch?.name.toLowerCase().contains('قاضي') == true;
  }

  bool get _hasAdditionalProductsForCurrentBranch {
    return filteredAdditionalProducts.isNotEmpty;
  }

  bool get _hasRequestsForCurrentBranch {
    return filteredItems.isNotEmpty && filteredItems.any((item) => !item.isBranchHeader && !item.isMainProduct);
  }

  bool get _shouldShowAdditionalProductsButton {
    return !_isQadiBranch && 
           _hasAdditionalProductsForCurrentBranch && 
           _hasRequestsForCurrentBranch;
  }

  void _validateAndUpdateQuantity(String itemId, String newValue) {
    if (!mounted) return;
    
    // تنظيف النص من المسافات
    String cleanValue = newValue.trim();
    
    // التحقق مما إذا كانت القيمة فارغة
    if (cleanValue.isEmpty) {
      final controller = _getController(itemId);
      controller.text = '0';
      setState(() {
        var item = items.firstWhere((element) => element.id == itemId, orElse: () => SendSupplyItem(
          id: '', productId: '', name: '', package: '', requestedQty: 0, branch: '', orderName: ''
        ));
        if (item.id.isNotEmpty) {
          item.requestedQty = 0;
        }
      });
      return;
    }
    
    // استبدال الفاصلة بنقطة للتعامل مع الإدخال العربي
    cleanValue = cleanValue.replaceAll(',', '.');
    
    // التحقق من أن هناك نقطة واحدة فقط
    if (cleanValue.split('.').length > 2) {
      // إذا كان هناك أكثر من نقطة، رفض القيمة
      final controller = _getController(itemId);
      // الحفاظ على القيمة الصالحة الأخيرة
      return;
    }
    
    // التحقق من صحة التنسيق - سماح بأرقام مع نقطة عشرية
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(cleanValue)) {
      // إذا كان التنسيق غير صالح، العودة للقيمة السابقة
      final controller = _getController(itemId);
      return;
    }
    
    // التحقق من أن القيمة لا تبدأ بنقطة
    if (cleanValue.startsWith('.')) {
      cleanValue = '0$cleanValue';
    }
    
    // التحقق من أنه لا توجد نقطة في النهاية فقط
    if (cleanValue.endsWith('.')) {
      // السماح بنقطة في النهاية للكتابة المستمرة
      final controller = _getController(itemId);
      controller.text = cleanValue;
      return;
    }
    
    // محاولة تحويل النص إلى رقم
    double? parsedValue = double.tryParse(cleanValue);
    
    if (parsedValue == null || parsedValue < 0) {
      // إذا كان التحويل غير ناجح أو القيمة سالبة
      final controller = _getController(itemId);
      controller.text = '0';
      setState(() {
        var item = items.firstWhere((element) => element.id == itemId, orElse: () => SendSupplyItem(
          id: '', productId: '', name: '', package: '', requestedQty: 0, branch: '', orderName: ''
        ));
        if (item.id.isNotEmpty) {
          item.requestedQty = 0;
        }
      });
    } else {
      // إذا كان الرقم صالحاً
      final controller = _getController(itemId);
      
      // تنسيق القيمة لعرضها مع الاحتفاظ بالكسور
      String formattedValue;
      if (cleanValue.contains('.') && cleanValue.endsWith('0')) {
        // إذا كانت القيمة تحتوي على كسور وتنتهي بصفر، احتفظ بالتنسيق الأصلي
        formattedValue = cleanValue;
      } else if (parsedValue % 1 == 0) {
        // إذا كانت كمية صحيحة
        formattedValue = parsedValue.toStringAsFixed(0);
      } else {
        // إذا كانت كمية كسرية
        formattedValue = parsedValue.toStringAsFixed(2);
      }
      
      controller.text = formattedValue;
      setState(() {
        var item = items.firstWhere((element) => element.id == itemId, orElse: () => SendSupplyItem(
          id: '', productId: '', name: '', package: '', requestedQty: 0, branch: '', orderName: ''
        ));
        if (item.id.isNotEmpty) {
          item.requestedQty = parsedValue;
        }
      });
    }
  }

  void _validateAndUpdateAdditionalQuantity(String productId, String newValue) {
    if (!mounted) return;
    
    // نفس منطق _validateAndUpdateQuantity ولكن للمنتجات الإضافية
    String cleanValue = newValue.trim();
    
    if (cleanValue.isEmpty) {
      final controller = _getController(productId);
      controller.text = '0';
      return;
    }
    
    cleanValue = cleanValue.replaceAll(',', '.');
    
    if (cleanValue.split('.').length > 2) {
      final controller = _getController(productId);
      return;
    }
    
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(cleanValue)) {
      final controller = _getController(productId);
      return;
    }
    
    if (cleanValue.startsWith('.')) {
      cleanValue = '0$cleanValue';
    }
    
    // السماح بنقطة في النهاية
    if (cleanValue.endsWith('.')) {
      final controller = _getController(productId);
      controller.text = cleanValue;
      return;
    }
    
    double? parsedValue = double.tryParse(cleanValue);
    final controller = _getController(productId);
    
    if (parsedValue == null || parsedValue < 0) {
      controller.text = '0';
    } else {
      String formattedValue;
      if (cleanValue.contains('.') && cleanValue.endsWith('0')) {
        formattedValue = cleanValue;
      } else if (parsedValue % 1 == 0) {
        formattedValue = parsedValue.toStringAsFixed(0);
      } else {
        formattedValue = parsedValue.toStringAsFixed(2);
      }
      
      controller.text = formattedValue;
    }
  }

  Widget _buildHeaderRow() {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: secondaryColor.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isVerySmallScreen ? 8 : isSmallScreen ? 10 : 12,
          horizontal: isVerySmallScreen ? 6 : isSmallScreen ? 8 : 10,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'القسم / الصنف'.tr(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 10 : isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Container(
              width: isVerySmallScreen ? 45 : isSmallScreen ? 55 : 65,
              alignment: Alignment.center,
              child: Text(
                'الوحدة'.tr(),
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 11 : isSmallScreen ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'المطلوب'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 12 : isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 6.0 : isSmallScreen ? 8.0 : 10.0,
        vertical: isVerySmallScreen ? 3.0 : 6.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 8.0 : isSmallScreen ? 10.0 : 12.0,
                      vertical: 8,
                    ),
                    child: DropdownButton<Branch>(
                      value: selectedBranch,
                      isExpanded: true,
                      underline: SizedBox(),
                      hint: Text(
                        'اختر الفرع'.tr(),
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : isSmallScreen ? 15 : 17,
                          color: lightTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: isVerySmallScreen ? 20 : isSmallScreen ? 24 : 28,
                        color: primaryColor,
                      ),
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 13 : isSmallScreen ? 15 : 17,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (value) {
                        if (value != null && mounted) {
                          setState(() {
                            selectedBranch = value;
                            showAdditionalProducts = false;
                            _filterItems();
                          });
                        }
                      },
                      items: branches.map((branch) {
                        return DropdownMenuItem<Branch>(
                          value: branch,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isVerySmallScreen ? 4 : isSmallScreen ? 6 : 8,
                            ),
                            child: Text(
                              branch.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.refresh, color: primaryColor, size: isVerySmallScreen ? 20 : 24),
                onPressed: () async {
                  print('🔄 جاري تحديث البيانات...');
                  await Future.wait([
                    _loadSendSupplyRequests(),
                    _loadAdditionalProducts(),
                  ]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ تم تحديث البيانات'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 6),
          if (_shouldShowAdditionalProductsButton)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showAdditionalProducts = !showAdditionalProducts;
                  print('🎯 حالة عرض المنتجات الإضافية: $showAdditionalProducts');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: showAdditionalProducts ? primaryColor : secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, isVerySmallScreen ? 42 : 46),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(showAdditionalProducts ? Icons.arrow_drop_up : Icons.arrow_drop_down, 
                    size: isVerySmallScreen ? 20 : 22),
                  SizedBox(width: 6),
                  Text(
                    showAdditionalProducts ? "إخفاء الأصناف الإضافية".tr() : "إظهار الأصناف الإضافية".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700, 
                      fontSize: isVerySmallScreen ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSendSupplyItemRow(SendSupplyItem item, int index) {
    if (item.isBranchHeader) {
      return _buildBranchHeader(item);
    } else if (item.isMainProduct) {
      return _buildMainProductHeader(item);
    } else {
      return _buildSingleItemRow(item, index);
    }
  }

  Widget _buildAdditionalProductsGrouped() {
    if (filteredAdditionalProducts.isEmpty) {
      return SizedBox();
    }

    // تجميع المنتجات حسب المنتج الرئيسي
    Map<String, List<AdditionalProduct>> groupedProducts = {};
    
    for (var product in filteredAdditionalProducts) {
      String mainProductKey = product.mainProductId.isNotEmpty 
          ? '${product.mainProductId}_${product.mainProductName}'
          : 'without_main';
      
      if (!groupedProducts.containsKey(mainProductKey)) {
        groupedProducts[mainProductKey] = [];
      }
      groupedProducts[mainProductKey]!.add(product);
    }

    // ترتيب المجموعات حسب الترتيب
    List<MapEntry<String, List<AdditionalProduct>>> sortedGroups = 
        groupedProducts.entries.toList()
          ..sort((a, b) {
            if (a.key == 'without_main') return 1;
            if (b.key == 'without_main') return -1;
            int orderA = a.value.first.mainProductOrder;
            int orderB = b.value.first.mainProductOrder;
            return orderA.compareTo(orderB);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الأصناف الإضافية'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${filteredAdditionalProducts.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        
        ...sortedGroups.map((entry) {
          String mainProductKey = entry.key;
          List<AdditionalProduct> products = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mainProductKey != 'without_main' && products.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: secondaryColor.withOpacity(0.2),
                  child: Row(
                    children: [
                      Icon(Icons.category, size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          products.first.mainProductName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          " ( "+ " ${products.length} " +" ) "+'منتج'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              ...products.map((product) => _buildAdditionalProductRow(
                product, 
                filteredAdditionalProducts.indexOf(product)
              )).toList(),
              
              SizedBox(height: 6),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalProductRow(AdditionalProduct product, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    // الحصول على المتحكم الآمن
    final TextEditingController controller = _getController(product.id);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.mainProductName.isNotEmpty)
                    Text(
                      product.mainProductName,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 9 : 11,
                        color: lightTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  "${product.package} ${product.packageUnitname}",
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w500,
                    color: lightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, 
                        color: primaryColor, 
                        size: isVerySmallScreen ? 20 : 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        double currentValue = double.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          currentValue = (currentValue * 100 - 100) / 100; // تخفيض 1.00
                          if (currentValue < 0) currentValue = 0;
                          _validateAndUpdateAdditionalQuantity(product.id, currentValue.toString());
                        } else {
                          controller.text = '0';
                          _validateAndUpdateAdditionalQuantity(product.id, '0');
                        }
                      });
                    },
                  ),
                  
                  Expanded(
                    child: SizedBox(
                      height: isVerySmallScreen ? 35 : 40,
                      child: TextField(
                        key: ValueKey('additional_${product.id}'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          // السماح بالأرقام والنقطة والفاصلة
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              String newText = newValue.text;
                              String checkText = newText.replaceAll(',', '.');
                              
                              if (checkText.isEmpty) {
                                return newValue;
                              }
                              
                              final regex = RegExp(r'^\d*\.?\d*$');
                              if (!regex.hasMatch(checkText)) {
                                return oldValue;
                              }
                              
                              if (checkText.split('.').length > 2) {
                                return oldValue;
                              }
                              
                              return newValue;
                            },
                          ),
                        ],
                        controller: controller,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: accentColor, width: 2),
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) {
                          _validateAndUpdateAdditionalQuantity(product.id, value);
                        },
                      ),
                    ),
                  ),
                  
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, 
                        color: primaryColor, 
                        size: isVerySmallScreen ? 20 : 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        double currentValue = double.tryParse(controller.text) ?? 0;
                        currentValue = (currentValue * 100 + 100) / 100; // زيادة 1.00
                        _validateAndUpdateAdditionalQuantity(product.id, currentValue.toString());
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchHeader(SendSupplyItem item) {
    return Container();
  }

  Widget _buildMainProductHeader(SendSupplyItem item) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: isVerySmallScreen ? 10 : 12,
        ),
        child: Row(
          children: [
            Icon(
              Icons.category,
              color: primaryColor,
              size: isVerySmallScreen ? 16 : 18,
            ),
            SizedBox(width: isVerySmallScreen ? 6 : 8),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 13 : isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: primaryColor.withOpacity(0.6),
              size: isVerySmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleItemRow(SendSupplyItem item, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    // الحصول على المتحكم الآمن
    final TextEditingController controller = _getController(item.id);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isVerySmallScreen ? 4 : isSmallScreen ? 6 : 8,
          horizontal: isVerySmallScreen ? 4 : isSmallScreen ? 6 : 8,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 9 : isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  if (item.mainProductName.isNotEmpty)
                    Text(
                      item.mainProductName,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 7 : isSmallScreen ? 8 : 9,
                        fontWeight: FontWeight.w400,
                        color: lightTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                "${item.package} ${item.packageUnitname}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 10 : isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: lightTextColor,
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, 
                        color: primaryColor, 
                        size: isVerySmallScreen ? 18 : 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        double currentValue = double.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          currentValue = (currentValue * 100 - 100) / 100; // تخفيض 1.00
                          if (currentValue < 0) currentValue = 0;
                          _validateAndUpdateQuantity(item.id, currentValue.toString());
                        } else {
                          controller.text = '0';
                          _validateAndUpdateQuantity(item.id, '0');
                        }
                      });
                    },
                  ),

                  Expanded(
                    child: SizedBox(
                      height: isVerySmallScreen ? 32 : isSmallScreen ? 36 : 40,
                      child: TextField(
                        key: ValueKey(item.id),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          // السماح بالأرقام والنقطة والفاصلة
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              // السماح بالأرقام والنقطة والفاصلة والفراغات
                              String newText = newValue.text;
                              
                              // استبدال الفاصلة بنقطة للتحقق
                              String checkText = newText.replaceAll(',', '.');
                              
                              // التحقق من التنسيق الصحيح
                              if (checkText.isEmpty) {
                                return newValue;
                              }
                              
                              // السماح فقط برقم واحد ونقطة عشرية واحدة
                              final regex = RegExp(r'^\d*\.?\d*$');
                              if (!regex.hasMatch(checkText)) {
                                return oldValue;
                              }
                              
                              // التحقق من عدد النقاط
                              if (checkText.split('.').length > 2) {
                                return oldValue;
                              }
                              
                              return newValue;
                            },
                          ),
                        ],
                        controller: controller,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 11 : isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: accentColor, width: 1.2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) {
                          _validateAndUpdateQuantity(item.id, value);
                        },
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.add_circle_outline, 
                        color: primaryColor, 
                        size: isVerySmallScreen ? 18 : 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        double currentValue = double.tryParse(controller.text) ?? 0;
                        currentValue = (currentValue * 100 + 100) / 100; // زيادة 1.00
                        _validateAndUpdateQuantity(item.id, currentValue.toString());
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    if (!mounted || selectedBranch == null) return;

    // طباعة بيانات التصحيح
    _debugPrintData();

    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveValue({
      required double normal,
      required double small,
      required double verySmall,
    }) {
      if (screenWidth < 320) return verySmall;
      if (screenWidth < 380) return small;
      return normal;
    }

    SizedBox _verticalSpace() => SizedBox(height: getResponsiveValue(normal: 16, small: 12, verySmall: 8));
    SizedBox _horizontalSpace() => SizedBox(width: getResponsiveValue(normal: 14, small: 10, verySmall: 6));

    Widget _buildTextButton(String text, VoidCallback onPressed) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveValue(normal: 18, small: 14, verySmall: 10),
            vertical: getResponsiveValue(normal: 10, small: 8, verySmall: 6),
          ),
        ),
        child: Text(
          text.tr(),
          style: TextStyle(
            fontSize: getResponsiveValue(normal: 16, small: 15, verySmall: 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
      );
    }

    Widget _buildElevatedButton(String text, VoidCallback onPressed) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveValue(normal: 20, small: 16, verySmall: 12),
            vertical: getResponsiveValue(normal: 10, small: 8, verySmall: 6),
          ),
        ),
        child: Text(
          text.tr(),
          style: TextStyle(
            fontSize: getResponsiveValue(normal: 16, small: 15, verySmall: 14),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
      );
    }

    // حساب إجمالي المنتجات الأساسية والإضافية
    int basicProductsCount = filteredItems
        .where((item) {
          if (item.isMainProduct || item.isBranchHeader) return false;
          final controller = _getController(item.id);
          final qty = double.tryParse(controller.text) ?? 0;
          return qty > 0;
        })
        .length;
    
    int additionalProductsCount = 0;
    if (!_isQadiBranch && _hasAdditionalProductsForCurrentBranch) {
      additionalProductsCount = filteredAdditionalProducts
          .where((product) {
            final controller = _getController(product.id);
            final qty = double.tryParse(controller.text) ?? 0;
            return qty > 0;
          })
          .length;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: backgroundColor,
        child: Directionality(
          textDirection: material.TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(getResponsiveValue(normal: 16, small: 12, verySmall: 10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'تأكيد الارسال'.tr(),
                    style: TextStyle(
                      fontSize: getResponsiveValue(normal: 18, small: 16, verySmall: 14),
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                _verticalSpace(),
                Text(
                  textAlign: TextAlign.center,
                  'هل أنت متأكد من الكميات المنتجة؟'.tr(),
                  style: TextStyle(
                    fontSize: getResponsiveValue(normal: 16, small: 15, verySmall: 14),
                    color: textColor,
                  ),
                ),
                _verticalSpace(),
                
                // تفاصيل الإرسال
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: secondaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: primaryColor, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "الفرع:".tr() +"("+'${selectedBranch!.name}'+")",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.inventory, color: primaryColor, size: 18),
                          SizedBox(width: 6),
                          Text(
                           "("+'$basicProductsCount'+")"+":"+ "المنتجات".tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      if (additionalProductsCount > 0) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.add_box, color: accentColor, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'المنتجات الإضافية: $additionalProductsCount',
                              style: TextStyle(
                                fontSize: 14,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                _verticalSpace(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTextButton('إلغاء'.tr(), () => Navigator.pop(context)),
                    _horizontalSpace(),
                    _buildElevatedButton("الارسال".tr(), () async {
                      Navigator.pop(context);
                      await _submitSendSupplyRequest();
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitSendSupplyRequest() async {
    if (!mounted || selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ لم يتم اختيار فرع"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print('=' * 60);
      print('🚀 بدء عملية إرسال بيانات التوريد');
      print('=' * 60);

      // جمع المنتجات الأساسية
      final itemsToSubmit = <Map<String, dynamic>>[];
      
      // المنتجات الأساسية
      for (var item in filteredItems) {
        if (!item.isBranchHeader && !item.isMainProduct) {
          final controller = _getController(item.id);
          double qty = double.tryParse(controller.text) ?? 0;
          
          if (qty > 0) {
            itemsToSubmit.add({
              "productId": item.productId,
              "qty": qty,
              "isAdditional": false
            });
            print('✅ منتج أساسي: ${item.name} - الكمية: $qty - ID: ${item.productId}');
          }
        }
      }

      print('📊 المنتجات الأساسية: ${itemsToSubmit.length}');

      // المنتجات الإضافية
      if (!_isQadiBranch && _hasAdditionalProductsForCurrentBranch) {
        for (var product in filteredAdditionalProducts) {
          final controller = _getController(product.id);
          double qty = double.tryParse(controller.text) ?? 0;
          
          if (qty > 0) {
            itemsToSubmit.add({
              "productId": product.id,
              "qty": qty,
              "isAdditional": true
            });
            print('✅ منتج إضافي: ${product.name} - الكمية: $qty - ID: ${product.id}');
          } else {
            print('➖ منتج إضافي (كمية صفر): ${product.name}');
          }
        }
      }

      print('📦 إجمالي العناصر المرسلة: ${itemsToSubmit.length}');

      if (itemsToSubmit.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ لا توجد أصناف للإرسال'.tr()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // الحصول على ID المستخدم
      var userId;
      try {
        userId = await Localls.getUserID();
        print('👤 ID المستخدم: $userId');
      } catch (e) {
        print('⚠️ خطأ في الحصول على ID المستخدم: $e');
        userId = 'unknown';
      }

      // إعداد بيانات الإرسال
      final requestData = {
        "isAdmin": true,
        "items": itemsToSubmit,
        "branch": selectedBranch!.id,
        "isSend": true,
        "userID": userId
      };

      print('📤 جاري الإرسال إلى: $submitUrl');
      print('📄 البيانات المرسلة: ${json.encode(requestData)}');

      // إرسال الطلب
      final response = await http
          .post(
            Uri.parse(submitUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(minutes: 20));

      print('📥 استجابة السيرفر: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        print('✅ استجابة JSON: $data');

        // تحديث حالة الطلبات الأساسية فقط
        if (orderIds.isNotEmpty) {
          int successCount = 0;
          int failCount = 0;

          // الحصول على IDs الطلبات الأساسية فقط
          final basicProductIds = filteredItems
              .where((item) => 
                  !item.isBranchHeader && 
                  !item.isMainProduct && 
                  item.branch == selectedBranch!.name)
              .map((item) => item.id)
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList();

          print("🔄 طلبات الفرع الأساسية: ${basicProductIds.length}");

          for (String orderId in basicProductIds) {
            try {
              await updateOrderIsSended(orderId: orderId, isSend: true);
              successCount++;
              print("✅ تم تحديث حالة الطلب $orderId بنجاح");
            } catch (e) {
              failCount++;
              print("⚠️ فشل في تحديث حالة الطلب $orderId: $e");
            }
          }

          print("📊 تم تحديث $successCount طلب بنجاح، فشل في تحديث $failCount طلب");
        }

        if (!mounted) return;
        
        // إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ تم إرسال التوريد بنجاح!",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: Duration(seconds: 4),
          ),
        );

        // تحديث البيانات بعد الإرسال
        print('🔄 جاري تحديث البيانات...');
        await Future.wait([
          _loadSendSupplyRequests(),
          _loadAdditionalProducts(),
        ]);

        // إعادة تعيين الكميات
        if (!_isQadiBranch && _hasAdditionalProductsForCurrentBranch) {
          for (var product in filteredAdditionalProducts) {
            final controller = _getController(product.id);
            controller.text = '0';
          }
        }

        // إعادة تعيين التصفية
        if (mounted) {
          setState(() {
            showAdditionalProducts = false;
          });
        }

        print('🎉 تمت عملية التوريد بنجاح!');
        
      } else {
        final errorData = json.decode(response.body);
        print('❌ خطأ من السيرفر: $errorData');
        throw Exception(errorData['message'] ?? 'فشل في عملية الإرسال (${response.statusCode})');
      }
    } catch (e) {
      print("❌ خطأ في إرسال التوريد: $e");
      print('📌 نوع الخطأ: ${e.runtimeType}');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ فشل في إرسال التوريد: ${e.toString().replaceAll('Exception:', '').trim()}',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // دالة لطباعة بيانات التصحيح
  void _debugPrintData() {
    print('=' * 60);
    print('🔍 بيانات التصحيح - التوريد - ${DateTime.now()}');
    print('=' * 60);
    
    print('🎯 الفرع المحدد: ${selectedBranch?.name ?? "لا يوجد"}');
    print('🎯 هو فرع قاضي: $_isQadiBranch');
    
    print('\n📊 المنتجات الأساسية:');
    int basicCount = 0;
    filteredItems.where((item) => !item.isBranchHeader && !item.isMainProduct).forEach((item) {
      final controller = _getController(item.id);
      final qty = double.tryParse(controller.text) ?? 0;
      if (qty > 0) {
        print('   ✅ ${item.name}: $qty (ID: ${item.id})');
        basicCount++;
      } else {
        print('   ➖ ${item.name}: $qty');
      }
    });
    
    print('\n📊 المنتجات الإضافية:');
    int additionalCount = 0;
    filteredAdditionalProducts.forEach((product) {
      final controller = _getController(product.id);
      final qty = double.tryParse(controller.text) ?? 0;
      if (qty > 0) {
        print('   ✅ ${product.name}: $qty (ID: ${product.id})');
        additionalCount++;
      } else {
        print('   ➖ ${product.name}: $qty');
      }
    });
    
    print('\n📈 الإحصائيات:');
    print('   المنتجات الأساسية: $basicCount');
    print('   المنتجات الإضافية: $additionalCount');
    print('   الإجمالي: ${basicCount + additionalCount}');
    
    print('\n🎯 حالة العرض:');
    print('   عرض المنتجات الإضافية: $showAdditionalProducts');
    print('   يوجد منتجات إضافية: $_hasAdditionalProductsForCurrentBranch');
    print('   يوجد طلبات للفرع: $_hasRequestsForCurrentBranch');
    
    print('=' * 60);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.width < 320;
    final isSmallScreen = screenSize.width < 380;

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: Loadingwidget(),
      child: Directionality(
        textDirection: material.TextDirection.rtl,
        child: Container(
          color: backgroundColor,
          child: Column(
            children: [
              _buildFilterSection(),
              if (isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'جاري التحميل...'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (selectedBranch == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined,
                            size: isVerySmallScreen ? 45 : isSmallScreen ? 55 : 65,
                            color: secondaryColor),
                        SizedBox(height: isVerySmallScreen ? 8 : isSmallScreen ? 12 : 16),
                        Text('الرجاء اختيار فرع من القائمة'.tr(),
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 14 : isSmallScreen ? 16 : 18,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                )
              else if (!_hasRequestsForCurrentBranch && !_hasAdditionalProductsForCurrentBranch)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.production_quantity_limits,
                            size: isVerySmallScreen ? 45 : isSmallScreen ? 55 : 65,
                            color: secondaryColor),
                        SizedBox(height: isVerySmallScreen ? 8 : isSmallScreen ? 12 : 16),
                        Text('${"لا توجد طلبات توريد لفرع".tr()} ${selectedBranch!.name}',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 14 : isSmallScreen ? 16 : 18,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 6),
                        Text(
                          'يمكنك إضافة منتجات إضافية إذا كانت متاحة'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: lightTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (!isSmallScreen)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 6.0 : isSmallScreen ? 8.0 : 10.0,
                      vertical: 6,
                    ),
                    child: _buildHeaderRow(),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 6.0 : isSmallScreen ? 8.0 : 10.0,
                    ),
                    child: ListView(
                      children: [
                        if (_hasRequestsForCurrentBranch)
                          ...filteredItems
                              .where((item) => !item.isBranchHeader)
                              .map((item) => _buildSendSupplyItemRow(item, filteredItems.indexOf(item)))
                              .toList(),

                        if (showAdditionalProducts && _hasAdditionalProductsForCurrentBranch && !_isQadiBranch)
                          _buildAdditionalProductsGrouped(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isVerySmallScreen ? 8.0 : isSmallScreen ? 10.0 : 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isVerySmallScreen ? 12 : isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send,
                              size: isVerySmallScreen ? 18 : isSmallScreen ? 20 : 22),
                          SizedBox(width: isVerySmallScreen ? 4 : isSmallScreen ? 6 : 8),
                          Text("الارسال".tr(),
                              style: TextStyle(
                                fontSize: isVerySmallScreen ? 14 : isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      onPressed: selectedBranch == null ? null : _showConfirmationDialog,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SendSupplyItem {
  String id;
  String productId;
  String name;
  String package;
  String packageUnitname;
  double requestedQty;
  String branch;
  String orderName;
  String mainProductId;
  String mainProductName;
  int mainProductOrder;
  bool isMainProduct;
  bool isBranchHeader;

  SendSupplyItem({
    required this.id,
    required this.productId,
    required this.name,
    required String package,
    String? packageUnitname,
    required this.requestedQty,
    required this.branch,
    required this.orderName,
    this.mainProductId = '',
    this.mainProductName = '',
    this.mainProductOrder = 0,
    this.isMainProduct = false,
    this.isBranchHeader = false,
  }) : package = (package == "لم يحدد") ? "" : package,
       packageUnitname = packageUnitname ?? "";
}

class AdditionalProduct {
  String id;
  String name;
  String package;
  String packageUnitname;
  String mainProductId;
  String mainProductName;
  int mainProductOrder;
  String branchId;
  String branchName;

  AdditionalProduct({
    required this.id,
    required this.name,
    required String package,
    String? packageUnitname,
    this.mainProductId = '',
    this.mainProductName = '',
    this.mainProductOrder = 0,
    this.branchId = '',
    this.branchName = '',
  }) : package = (package == "لم يحدد") ? "" : package,
       packageUnitname = packageUnitname ?? "";
}

class Branch {
  String id;
  String name;

  Branch({
    required this.id,
    required this.name,
  });
}

Future updateOrderIsSended({
  required String orderId,
  bool isSend = true,
}) async {
  final url = Uri.parse("${Apiendpoints.baseUrl}${Apiendpoints.orderSupply.isSend}$orderId");

  print("🔄 جاري تحديث حالة طلب التوريد: $orderId");
  
  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({"isSend": isSend}),
  ).timeout(Duration(minutes: 20));

  if (response.statusCode == 200) {
    print("✅ تم تحديث حالة طلب التوريد $orderId بنجاح");
    return true;
  } else {
    print("⚠️ خطأ في تحديث حالة طلب التوريد $orderId: ${response.statusCode} => ${response.body}");
    throw Exception("Failed to update order: ${response.statusCode}");
  }
}