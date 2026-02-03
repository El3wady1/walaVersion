import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'dart:convert';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:intl/intl.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LastsendproductionSupplyview extends StatefulWidget {
  LastsendproductionSupplyview({super.key});

  @override
  State<LastsendproductionSupplyview> createState() =>
      _LastsendproductionSupplyviewState();
}

class _LastsendproductionSupplyviewState
    extends State<LastsendproductionSupplyview> {
  List<dynamic> historyData = [];
  List<dynamic> filteredHistoryData = [];
  List<dynamic> allProducts = []; // قائمة جميع المنتجات من API
  Map<String, dynamic> lastOrderByBranch = {};
  bool isLoading = true;
  bool isFilterVisible = false;
  String errorMessage = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // الألوان المحددة من الصورة
  final Color primaryColor = Color(0xFF74826A); // الأخضر الداكن
  final Color accentColor = Color(0xFFEDBE2C); // الأصفر الذهبي
  final Color secondaryColor = Color(0xFFCDBCA2); // البيج الفاتح
  final Color backgroundColor = Color(0xFFF3F4EF); // الأبيض المائل للأخضر

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${Apiendpoints.baseUrl}${Apiendpoints.productOP.getAll}'),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          allProducts = data['data'];
        });
      } else {
        print('فشل في جلب المنتجات: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب المنتجات: $e');
    }
  }

  Future<void> fetchHistoryData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          Apiendpoints.baseUrl + Apiendpoints.productionSupply.history)).timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          historyData = data['data'];

          // استخراج آخر طلب من كل فرع
          extractLastOrderByBranch();

          // عند تحميل البيانات لأول مرة، عرض بيانات اليوم الحالي فقط
          final today = DateTime.now();
          selectedStartDate = DateTime(today.year, today.month, today.day);
          selectedEndDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);

          filterDataByDate();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل في جلب البيانات: ${response.statusCode}'.tr();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ: $e'.tr();
      });
    }
  }

  // دالة لاستخراج آخر طلب من كل فرع
  void extractLastOrderByBranch() {
    lastOrderByBranch.clear();

    for (var item in historyData) {
      final branchId = item['branchId'] ?? item['branch']?['_id'] ?? 'unknown';

      // إذا كان الفرع غير موجود أو إذا كان الطلب الحالي أحدث
      if (!lastOrderByBranch.containsKey(branchId) ||
          DateTime.parse(item['createdAt']).isAfter(
              DateTime.parse(lastOrderByBranch[branchId]['createdAt']))) {
        lastOrderByBranch[branchId] = item;
      }
    }
  }

  bool isloadingg = false;

  Future<void> updateHistoryItem(
      String id, List<Map<String, dynamic>> items) async {
    var userID;
    await Localls.getUserID().then((v) => userID = v);
    setState(() {
      isloadingg = true;
    });

    try {
      // تحويل items إلى الصيغة المطلوبة لل API
      List<Map<String, dynamic>> formattedItems = items.map((item) {
        return {
          "product": item['product']['_id'],
          "qty": item['qty']
        };
      }).toList();

      final response = await http.put(
        Uri.parse(
            '${Apiendpoints.baseUrl}${Apiendpoints.productionSupply.updatehistory}$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userID.toString(),
          "note": "تم تعديل كميات في الارسال",
          "locationProcess": "اخر عملية توريد",
          'items': formattedItems
        }),
      ).timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        // نجاح التحديث، إعادة تحميل البيانات
        await fetchHistoryData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التحديث بنجاح').tr(),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في التحديث: ${response.body}'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isloadingg = false;
      });
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${Apiendpoints.baseUrl}${Apiendpoints.productionSupply.deletehistory}$id'),
      ).timeout(Duration(minutes: 20));

      if (response.statusCode == 200) {
        // نجاح الحذف، إعادة تحميل البيانات
        fetchHistoryData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الحذف بنجاح').tr(),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحذف: ${response.statusCode}'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showEditDialog(Map<String, dynamic> item) {
    // نسخ المنتجات الحالية
    List<Map<String, dynamic>> currentItems = List.from(item['items']);
    final List<TextEditingController> currentItemControllers = [];

    // جمع IDs المنتجات الحالية
    List<String> existingProductIds = currentItems.map((existingItem) {
      return existingItem['product']['_id']?.toString() ?? '';
    }).where((id) => id.isNotEmpty).toList();

    // تهيئة الـ controllers للمنتجات الحالية
    for (var productItem in currentItems) {
      currentItemControllers.add(TextEditingController(text: productItem['qty'].toString()));
    }

    // قائمة للمنتجات الجديدة
    List<Map<String, dynamic>> newItems = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;

            return StatefulBuilder(
              builder: (context, setState) {
                // دالة لإنشاء قائمة المنتجات المتاحة
                List<dynamic> getAvailableProducts(int currentIndex) {
                  return allProducts.where((product) {
                    String productId = product['_id'].toString();
                    
                    // استبعاد المنتجات الحالية
                    if (existingProductIds.contains(productId)) {
                      return false;
                    }
                    
                    // استبعاد المنتجات الجديدة الأخرى المختارة بالفعل
                    for (int i = 0; i < newItems.length; i++) {
                      if (i != currentIndex && 
                          newItems[i]['product']['_id'].toString() == productId) {
                        return false;
                      }
                    }
                    
                    return true;
                  }).toList();
                }

                return Dialog(
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: isWide ? 100 : 20,
                    vertical: isWide ? 40 : 10,
                  ),
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isWide ? 30.0 : 16.0),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              (isWide ? 0.8 : 0.7),
                          maxWidth: isWide ? 700 : double.infinity,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'تعديل الكميات'.tr(),
                                style: GoogleFonts.cairo(
                                  fontSize: isWide ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // المنتجات الحالية
                            Text(
                              'المنتجات الحالية'.tr(),
                              style: GoogleFonts.cairo(
                                fontSize: isWide ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 10),

                            Container(
                              height: MediaQuery.of(context).size.height *
                                  (isWide ? 0.25 : 0.2),
                              child: currentItems.isEmpty
                                  ? Center(
                                child: Text(
                                  'لا توجد منتجات حالية'.tr(),
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                itemCount: currentItems.length,
                                itemBuilder: (context, index) {
                                  final productName = currentItems[index]['product']['name'] ?? 'غير محدد';
                                  final productId = currentItems[index]['product']['_id']?.toString() ?? '';

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: secondaryColor.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productName,
                                                style: GoogleFonts.cairo(
                                                  fontSize: isWide ? 14 : 12,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                            
                                            ],
                                          ),
                                        ),

                                        SizedBox(width: 10),
                                        SizedBox(
                                          width: isWide ? 120 : 80,
                                          child: TextField(
                                            controller: currentItemControllers[index],
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              labelText: 'الكمية'.tr(),
                                              labelStyle: GoogleFonts.cairo(
                                                fontSize: isWide ? 13 : 11,
                                                color: primaryColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: primaryColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: primaryColor),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              final newQty = double.tryParse(value) ?? 0;
                                              currentItems[index]['qty'] = newQty;
                                            },
                                          ),
                                        ),

                                        // زر حذف للمنتج الحالي
                                        // IconButton(
                                        //   icon: Icon(Icons.delete, color: Colors.red),
                                        //   onPressed: () {
                                        //     setState(() {
                                        //       existingProductIds.remove(currentItems[index]['product']['_id']);
                                        //       currentItems.removeAt(index);
                                        //       currentItemControllers.removeAt(index);
                                        //     });
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 20),

                            // قسم إضافة منتجات جديدة
                            Text(
                              'إضافة منتجات جديدة'.tr(),
                              style: GoogleFonts.cairo(
                                fontSize: isWide ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            SizedBox(height: 10),

                            // المنتجات الجديدة المضافة
                            Container(
                              height: MediaQuery.of(context).size.height *
                                  (isWide ? 0.2 : 0.15),
                              child: newItems.isEmpty
                                  ? Center(
                                child: Text(
                                  'لم تتم إضافة منتجات جديدة'.tr(),
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                itemCount: newItems.length,
                                itemBuilder: (context, index) {
                                  final newItem = newItems[index];
                                  final newItemController = TextEditingController(text: newItem['qty'].toString());

                                  // الحصول على المنتجات المتاحة للاختيار باستخدام الدالة المساعدة
                                  List<dynamic> availableProducts = getAvailableProducts(index);

                                  // إنشاء قائمة القائمة المنسدلة مع قيم فريدة
                                  List<DropdownMenuItem<String>> dropdownItems = [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'اختر منتج'.tr(),
                                        style: GoogleFonts.cairo(
                                          fontSize: isWide ? 13 : 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ];

                                  // إضافة المنتجات المتاحة مع ضمان عدم وجود تكرار
                                  for (var product in availableProducts) {
                                    dropdownItems.add(
                                      DropdownMenuItem<String>(
                                        value: product['_id'].toString(),
                                        child: Text(
                                          '${product['name']} ${product['packSize'] != null ? '(${product['packSize']})' : ''}',
                                          style: GoogleFonts.cairo(
                                            fontSize: isWide ? 13 : 11,
                                            color: primaryColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }

                                  // إضافة المنتج المختار حاليًا إذا لم يكن في القائمة المتاحة (للعرض فقط)
                                  if (newItem['product']['_id']?.toString().isNotEmpty == true) {
                                    bool isProductInList = availableProducts.any((p) => p['_id'].toString() == newItem['product']['_id']);
                                    if (!isProductInList) {
                                      dropdownItems.add(
                                        DropdownMenuItem<String>(
                                          value: newItem['product']['_id'],
                                          child: Text(
                                            "${newItem['product']['name']}"+ " (تم اختياره)".tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: isWide ? 13 : 11,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: accentColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            value: newItem['product']['_id']?.toString().isNotEmpty == true
                                                ? newItem['product']['_id'].toString()
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: 'اختر منتج جديد'.tr(),
                                              labelStyle: GoogleFonts.cairo(
                                                fontSize: isWide ? 13 : 11,
                                                color: accentColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: accentColor),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: accentColor),
                                              ),
                                            ),
                                            items: dropdownItems,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                if (newValue != null && newValue.isNotEmpty) {
                                                  try {
                                                    final selectedProduct = allProducts
                                                        .firstWhere((prod) => prod['_id'].toString() == newValue);
                                                    newItem['product'] = {
                                                      '_id': selectedProduct['_id'],
                                                      'name': selectedProduct['name']
                                                    };
                                                    // تحديث قائمة المنتجات الحالية مؤقتاً
                                                    if (!existingProductIds.contains(selectedProduct['_id'].toString())) {
                                                      existingProductIds.add(selectedProduct['_id'].toString());
                                                    }
                                                  } catch (e) {
                                                    print('Error finding product: $e');
                                                    // في حالة عدم العثور على المنتج، اتركه فارغاً
                                                    newItem['product'] = {'_id': '', 'name': ''};
                                                  }
                                                } else {
                                                  // إذا تم اختيار "اختر منتج"، أزل المنتج من القائمة الحالية
                                                  if (newItem['product']['_id']?.toString().isNotEmpty == true) {
                                                    existingProductIds.remove(newItem['product']['_id'].toString());
                                                  }
                                                  newItem['product'] = {'_id': '', 'name': ''};
                                                }
                                              });
                                            },
                                            isExpanded: true,
                                          ),
                                        ),

                                        SizedBox(width: 10),
                                        SizedBox(
                                          width: isWide ? 100 : 70,
                                          child: TextField(
                                            controller: newItemController,
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            textAlign: TextAlign.center,
                                            onChanged: (value) {
                                              final newQty = double.tryParse(value) ?? 0;
                                              newItem['qty'] = newQty;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'الكمية'.tr(),
                                              labelStyle: GoogleFonts.cairo(
                                                fontSize: isWide ? 13 : 11,
                                                color: accentColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: accentColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: accentColor),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // زر حذف للمنتج الجديد
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              if (newItem['product']['_id']?.toString().isNotEmpty == true) {
                                                existingProductIds.remove(newItem['product']['_id'].toString());
                                              }
                                              newItems.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            // زر إضافة منتج جديد
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    newItems.add({
                                      'product': {'_id': '', 'name': ''},
                                      'qty': 0,
                                      'isNew': true
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWide ? 30 : 15,
                                    vertical: isWide ? 12 : 8,
                                  ),
                                ),
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  'إضافة منتج جديد'.tr(),
                                  style: GoogleFonts.cairo(color: Colors.white),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // التحقق من صحة البيانات وإعداد القائمة النهائية
                                    final List<Map<String, dynamic>> finalItems = [];

                                    // إضافة المنتجات الحالية
                                    for (int i = 0; i < currentItems.length; i++) {
                                      final itemData = currentItems[i];
                                      final productId = itemData['product']['_id']?.toString() ?? '';
                                      final productName = itemData['product']['name']?.toString() ?? '';
                                      final qty = double.tryParse(currentItemControllers[i].text) ?? 0;

                                      // التحقق من القيمة السالبة
                                      if (qty < 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('الكمية لا يمكن أن تكون سالبة'.tr()),
                                          ),
                                        );
                                        return;
                                      }

                                      finalItems.add({
                                        'product': {
                                          '_id': productId,
                                          'name': productName
                                        },
                                        'qty': qty
                                      });
                                    }

                                    // إضافة المنتجات الجديدة
                                    for (var newItem in newItems) {
                                      final productId = newItem['product']['_id']?.toString() ?? '';
                                      final productName = newItem['product']['name']?.toString() ?? '';
                                      final qty = newItem['qty'];

                                      // تخطي المنتجات الجديدة الفارغة
                                      if (productId.isEmpty || qty == 0) {
                                        continue;
                                      }

                                      // التحقق من القيمة السالبة
                                      if (qty < 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('الكمية لا يمكن أن تكون سالبة'.tr()),
                                          ),
                                        );
                                        return;
                                      }

                                      finalItems.add({
                                        'product': {
                                          '_id': productId,
                                          'name': productName
                                        },
                                        'qty': qty
                                      });
                                    }

                                    // التحقق من وجود منتجات على الأقل
                                    if (finalItems.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('يجب إضافة منتج واحد على الأقل'.tr()),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(context).pop();
                                    updateHistoryItem(item['_id'], finalItems);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isWide ? 40 : 20,
                                      vertical: isWide ? 16 : 10,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'حفظ'.tr(),
                                        style: GoogleFonts.cairo(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.close,
                                        color: primaryColor,
                                        size: isWide ? 26 : 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'إلغاء'.tr(),
                                        style: GoogleFonts.cairo(color: primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'تأكيد الحذف'.tr(),
            style: GoogleFonts.cairo(
                color: primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذه العملية؟ لا يمكن التراجع عن هذا الإجراء.'
                .tr(),
            style: GoogleFonts.cairo(color: primaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'.tr(),
                  style: GoogleFonts.cairo(color: primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteHistoryItem(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('حذف'.tr(),
                  style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // دالة لفلترة البيانات حسب التاريخ
  void filterDataByDate() {
    if (selectedStartDate == null && selectedEndDate == null) {
      setState(() {
        filteredHistoryData = historyData;
      });
      return;
    }

    setState(() {
      filteredHistoryData = historyData.where((item) {
        final DateTime createdAt = DateTime.parse(item['createdAt']);

        bool isAfterStartDate = true;
        bool isBeforeEndDate = true;

        if (selectedStartDate != null) {
          isAfterStartDate = createdAt.isAfter(DateTime(selectedStartDate!.year,
                  selectedStartDate!.month, selectedStartDate!.day, 0, 0, 0)
              .subtract(Duration(seconds: 1)));
        }

        if (selectedEndDate != null) {
          isBeforeEndDate = createdAt.isBefore(DateTime(selectedEndDate!.year,
              selectedEndDate!.month, selectedEndDate!.day, 23, 59, 59));
        }

        return isAfterStartDate && isBeforeEndDate;
      }).toList();
    });
  }

  // دالة لعرض منتقي التاريخ
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (selectedStartDate ?? DateTime.now())
          : (selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: backgroundColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
      filterDataByDate();
    }
  }

  // دالة لإعادة تعيين الفلتر
  void resetFilter() {
    setState(() {
      selectedStartDate = null;
      selectedEndDate = null;
      filteredHistoryData = historyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isloadingg,
      opacity: 0.6,
      color: Colors.black,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          title: Text(
            'سجل العمليات',
            style: GoogleFonts.cairo(color: Colors.white),
          ).tr(),
          centerTitle: true,
          actions: [
            // IconButton(
            //   icon: Icon(
            //       isFilterVisible ? Icons.filter_alt_off : Icons.filter_alt,
            //       color: Colors.white),
            //   onPressed: () {
            //     setState(() {
            //       isFilterVisible = !isFilterVisible;
            //     });
            //   },
            // ),
          ],
        ),
        body: isLoading
            ? Center(child: Loadingwidget())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          style: GoogleFonts.cairo(
                              color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchHistoryData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: Text('إعادة المحاولة').tr(),
                        ),
                      ],
                    ),
                  )
                : historyData.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد بيانات متاحة'.tr(),
                          style: GoogleFonts.cairo(
                              fontSize: 18, color: primaryColor),
                        ),
                      )
                    : Column(
                        children: [
                          // قسم الفلترة (يظهر فقط عند الضغط على زر الفلتر)
                          if (isFilterVisible)
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تصفية حسب التاريخ'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'من تاريخ'.tr(),
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                color: primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            InkWell(
                                              onTap: () =>
                                                  _selectDate(context, true),
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: secondaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      selectedStartDate != null
                                                          ? DateFormat(
                                                                  'yyyy/MM/dd')
                                                              .format(
                                                                  selectedStartDate!)
                                                          : 'اختر التاريخ'.tr(),
                                                      style: GoogleFonts.cairo(
                                                        color:
                                                            selectedStartDate !=
                                                                    null
                                                                ? primaryColor
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                    Icon(Icons.calendar_today,
                                                        size: 20,
                                                        color: primaryColor),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'إلى تاريخ'.tr(),
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                color: primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            InkWell(
                                              onTap: () =>
                                                  _selectDate(context, false),
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: secondaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      selectedEndDate != null
                                                          ? DateFormat(
                                                                  'yyyy/MM/dd')
                                                              .format(
                                                                  selectedEndDate!)
                                                          : 'اختر التاريخ'.tr(),
                                                      style: GoogleFonts.cairo(
                                                        color:
                                                            selectedEndDate !=
                                                                    null
                                                                ? primaryColor
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                    Icon(Icons.calendar_today,
                                                        size: 20,
                                                        color: primaryColor),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: resetFilter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            foregroundColor: Colors.grey[800],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text('إعادة التعيين'.tr()),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: filterDataByDate,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text('تطبيق الفلتر'.tr(),
                                              style: GoogleFonts.cairo(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedStartDate != null ||
                                      selectedEndDate != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Text(
                                        'عدد النتائج'.tr() +
                                            " :" +
                                            '${filteredHistoryData.length}'
                                                .tr(),
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          // معلومات الفلتر الحالي (تظهر دائمًا)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedStartDate != null ||
                                                selectedEndDate != null
                                            ? 'عرض البيانات من ${selectedStartDate != null ? DateFormat('yyyy/MM/dd').format(selectedStartDate!) : 'البداية'.tr()} إلى ${selectedEndDate != null ? DateFormat('yyyy/MM/dd').format(selectedEndDate!) : 'النهاية'.tr()}'
                                                .tr()
                                            : 'عرض جميع البيانات'.tr(),
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          color: primaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'النتائج'.tr() +
                                          " : " +
                                          '${filteredHistoryData.length}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(height: 8),
                          // زر لعرض آخر طلب من كل فرع
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // عند الضغط على الزر، نعرض فقط آخر طلب من كل فرع
                                  filteredHistoryData =
                                      lastOrderByBranch.values.toList();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'عرض آخر طلب من كل فرع'.tr(),
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: filteredHistoryData.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.search_off,
                                                size: 50,
                                                color: primaryColor
                                                    .withOpacity(0.5)),
                                            SizedBox(height: 16),
                                            Text(
                                              'لا توجد نتائج للعرض'.tr(),
                                              style: GoogleFonts.cairo(
                                                fontSize: 16,
                                                color: primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'جرب نطاق تواريخ مختلف'.tr(),
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredHistoryData.length,
                                        itemBuilder: (context, index) {
                                          final item =
                                              filteredHistoryData[index];
                                          final branchName = item['branch']
                                                  ?['name'] ??
                                              'غير محدد'.tr();

                                          return Container(
                                            margin: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: secondaryColor
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: ExpansionTile(
                                              initiallyExpanded: index == 0,
                                              collapsedBackgroundColor:
                                                  Colors.white,
                                              backgroundColor: Colors.white,
                                              iconColor: primaryColor,
                                              collapsedIconColor: primaryColor,
                                              title: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: _getActionColor(
                                                              item['action'])
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: _getActionColor(
                                                              item['action'])),
                                                    ),
                                                    child: Text(
                                                      _getActionText(
                                                          item['action']),
                                                      style: GoogleFonts.cairo(
                                                        color: _getActionColor(
                                                            item['action']),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'الفرع: $branchName'
                                                              .tr(),
                                                          style:
                                                              GoogleFonts.cairo(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Colors
                                                                .green[650],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Column(
                                                children: [
                                                  Text(
                                                    'تاريخ التحديث: ${formatDate(item['updatedAt'])}'
                                                        .tr(),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                      'تاريخ الإنشاء: ${formatDate(item['createdAt'])}'
                                                          .tr(),
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // جدول المنتجات
                                                      Text(
                                                        'المنتجات'.tr() + " : ",
                                                        style:
                                                            GoogleFonts.cairo(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Table(
                                                        columnWidths: {
                                                          0: FlexColumnWidth(3),
                                                          1: FlexColumnWidth(1),
                                                        },
                                                        border: TableBorder(
                                                          horizontalInside:
                                                              BorderSide(
                                                            color: secondaryColor
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1,
                                                          ),
                                                          bottom: BorderSide(
                                                            color: secondaryColor
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1,
                                                          ),
                                                          top: BorderSide(
                                                            color: secondaryColor
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        children: [
                                                          // رأس الجدول
                                                          TableRow(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                      0.1),
                                                            ),
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                child: Text(
                                                                  'اسم المنتج'
                                                                      .tr(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .cairo(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                child: Text(
                                                                  'الكمية'.tr(),
                                                                  style:
                                                                      GoogleFonts
                                                                          .cairo(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // بيانات الجدول
                                                          ...item['items'].map<
                                                                  TableRow>(
                                                              (productItem) {
                                                            return TableRow(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10.0),
                                                                  child: Text(
                                                                    productItem[
                                                                            'product']
                                                                        [
                                                                        'name'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts
                                                                        .cairo(
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10.0),
                                                                  child: Text(
                                                                    productItem[
                                                                            'qty']
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts
                                                                        .cairo(
                                                                      color:
                                                                          primaryColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ],
                                                      ),
                                                      SizedBox(height: 16),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              if (item[
                                                                      'action'] !=
                                                                  'delete')
                                                                ElevatedButton(
                                                                  onPressed: () =>
                                                                      showEditDialog(
                                                                          item),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        accentColor,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'تعديل'
                                                                        .tr(),
                                                                    style: GoogleFonts.cairo(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              SizedBox(
                                                                  width: 8),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // دالة للحصول على لون الحالة
  Color _getActionColor(String action) {
    switch (action) {
      case 'update':
        return Colors.green;
      case 'create':
      case 'approve':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // دالة للحصول على نص الحالة
  String _getActionText(String action) {
    switch (action) {
      case 'update':
        return 'تحديث'.tr();
      case 'create':
      case 'approve':
        return 'إضافة جديدة'.tr();
      case 'delete':
        return 'حذف'.tr();
      default:
        return action;
    }
  }
}