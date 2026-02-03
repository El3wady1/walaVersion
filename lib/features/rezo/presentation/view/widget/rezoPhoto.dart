import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'dart:convert';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart' as f;
import 'package:saladafactory/core/utils/ryalSar.dart';

class RezophotoMain extends StatefulWidget {
  @override
  State<RezophotoMain> createState() => _RezophotoMainState();
}

class _RezophotoMainState extends State<RezophotoMain> {
  // الألوان الجديدة
  final Color primaryColor = Color(0xFF74826A);
  final Color secondaryColor = Color(0xFFEDBE2C);
  final Color accentColor = Color(0xFFCDBCA2);
  final Color backgroundColor = Color(0xFFF3F4EF);

  List<dynamic> tawalfData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTawalfData();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchTawalfData() async {
    try {
      final response = await http.get(
        Uri.parse(Apiendpoints.baseUrl + Apiendpoints.rezoCasher.getAll),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 200) {
          _safeSetState(() {
            tawalfData = responseData['data'] ?? [];
            isLoading = false;
          });
        } else {
          _safeSetState(() {
            errorMessage = 'فشل في جلب البيانات'.tr();
            isLoading = false;
          });
        }
      } else {
        _safeSetState(() {
          errorMessage = 'خطأ في الاتصال'.tr();
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() {
        errorMessage = 'حدث خطأ'.tr();
        isLoading = false;
      });
    }
  }

  // دالة لتحويل الوقت إلى توقيت السعودية
  DateTime _toSaudiTime(DateTime utcTime) {
    return utcTime.add(Duration(hours: 3));
  }

  // دالة لتحويل التاريخ إلى توقيت السعودية
  String _formatDateToSaudi(String dateString) {
    try {
      DateTime utcDate = DateTime.parse(dateString);
      DateTime saudiDate = _toSaudiTime(utcDate);
      return "${saudiDate.year}-${saudiDate.month.toString().padLeft(2, '0')}-${saudiDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "تاريخ غير معروف".tr();
    }
  }

  // دالة لتحويل الوقت إلى توقيت السعودية
  String _formatTimeToSaudi(String dateString) {
    try {
      DateTime utcDate = DateTime.parse(dateString);
      DateTime saudiDate = _toSaudiTime(utcDate);
      return "${saudiDate.hour.toString().padLeft(2, '0')}:${saudiDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "وقت غير معروف".tr();
    }
  }

  // دالة للحصول على التاريخ والوقت الكامل بتوقيت السعودية
  String _formatFullDateTimeToSaudi(String dateString) {
    try {
      DateTime utcDate = DateTime.parse(dateString);
      DateTime saudiDate = _toSaudiTime(utcDate);
      return "${saudiDate.year}-${saudiDate.month.toString().padLeft(2, '0')}-${saudiDate.day.toString().padLeft(2, '0')} ${saudiDate.hour.toString().padLeft(2, '0')}:${saudiDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "تاريخ ووقت غير معروف".tr();
    }
  }

  // دالة جديدة: تجميع المنتجات حسب الفاتورة مع الفرز من الأحدث إلى الأقدم
  List<Map<String, dynamic>> _getGroupedByInvoice() {
    List<Map<String, dynamic>> groupedInvoices = [];
    
    for (var mainItem in tawalfData) {
      List<Map<String, dynamic>> invoiceProducts = [];
      double totalInvoicePrice = 0;
      
      for (var subItem in mainItem['item'] ?? []) {
        double productPrice = (subItem['product']?['price'] ?? 0).toDouble();
        int quantity = subItem['qty'] ?? 1;
        double totalProductPrice = productPrice * quantity;
        
        invoiceProducts.add({
          'subItem': subItem,
          'productPrice': productPrice,
          'quantity': quantity,
          'totalProductPrice': totalProductPrice,
        });
        
        totalInvoicePrice += totalProductPrice;
      }
      
      DateTime utcDate = DateTime.parse(mainItem['createdAt']);
      DateTime saudiDate = _toSaudiTime(utcDate);
      
      groupedInvoices.add({
        'invoice': mainItem,
        'products': invoiceProducts,
        'totalPrice': totalInvoicePrice,
        'date': _formatDateToSaudi(mainItem['createdAt']),
        'time': _formatTimeToSaudi(mainItem['createdAt']),
        'fullDateTime': _formatFullDateTimeToSaudi(mainItem['createdAt']),
        'sortDateTime': saudiDate, // إضافة هذا للحصول على الوقت الحقيقي للفرز
      });
    }
    
    // ترتيب الفواتير من الأحدث إلى الأقدم
    groupedInvoices.sort((a, b) => b['sortDateTime'].compareTo(a['sortDateTime']));
    
    return groupedInvoices;
  }

  void _showImageGalleryWithData(List<Map<String, dynamic>> invoices, int initialIndex) {
    if (!mounted) return;
    
    int currentIndex = initialIndex;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // الصورة في الخلفية
                    Container(
                      height: MediaQuery.of(context).size.height*0.75,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black.withOpacity(0.9),
                      child: PhotoViewGallery.builder(
                        scrollPhysics: BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          var invoice = invoices[index]['invoice'];
                          bool hasImage = invoice['image'] != null && invoice['image'].isNotEmpty;
                          
                          return PhotoViewGalleryPageOptions(
                            imageProvider: hasImage 
                                ? NetworkImage(invoice['image'] ?? '')
                                : AssetImage('assets/images/no_image.png') as ImageProvider,
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            heroAttributes: PhotoViewHeroAttributes(tag: invoice['_id']),
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 80,
                                      color: accentColor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'لا توجد صورة للفاتورة'.tr(),
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        itemCount: invoices.length,
                        loadingBuilder: (context, event) => Center(
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                            ),
                          ),
                        ),
                        backgroundDecoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        pageController: PageController(initialPage: currentIndex),
                        onPageChanged: (int index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                    ),
                    
                    // جدول البيانات في الأعلى
                    Positioned(
                      bottom: 0,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(12), // تصغير الحشوة
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            // عنوان الفاتورة والمبلغ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${  "فاتورة".tr()} ${currentIndex + 1} ${"من".tr() } ${invoices.length}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 14, // تصغير الخط
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // تصغير الحشوة
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${invoices[currentIndex]['totalPrice'].toStringAsFixed(2)}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.black,
                                          fontSize: 12, // تصغير الخط
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Ryalsar()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8), // تقليل المسافة
                            
                            // جدول المعلومات الأساسية
                            Table(
                              columnWidths: {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1.5),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1.5),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                // رأس الجدول
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
                                  ),
                                  children: [
                                    _buildTableHeader("", fontSize: 0),
                                    _buildTableHeader("", fontSize: 0),
                                    _buildTableHeader("", fontSize: 0),
                                    _buildTableHeader("", fontSize: 0),
                                  ],
                                ),
                                
                                TableRow(
                                  children: [
                                    _buildTableCell(invoices[currentIndex]['invoice']['userID']?['name'] ?? 'غير محدد'.tr(), fontSize: 10),
                                    _buildTableCell(invoices[currentIndex]['invoice']['branch']?['name'] ?? 'غير محدد'.tr(), fontSize: 10),
                                    _buildTableCell(invoices[currentIndex]['date'], fontSize: 10),
                                    _buildTableCell(invoices[currentIndex]['time'], fontSize: 10),
                                  ],
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 12), 
                            
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (invoices[currentIndex]['products'].isNotEmpty)
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(1), 
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(1), // السعر
                                          3: FlexColumnWidth(1.5), // الإجمالي
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        border: TableBorder(
                                          horizontalInside: BorderSide(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        children: [
                                          // رأس جدول المنتجات
                                          TableRow(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.3),
                                            ),
                                            children: [
                                              _buildProductTableHeader("", fontSize: 0),
                                              _buildProductTableHeader("", fontSize: 0),
                                              _buildProductTableHeader("", fontSize: 0),
                                              _buildProductTableHeader("", fontSize: 0),
                                            ],
                                          ),
                                          
                                          // بيانات المنتجات (نعرض أول 5 منتجات فقط)
                                          ...invoices[currentIndex]['products'].take(5).map<TableRow>((product) {
                                            double quantity = double.parse(product['quantity']?.toString() ?? '0');
                                            double price = double.parse(product['productPrice']?.toString() ?? '0');
                                            double total = quantity * price;
                                            
                                            return TableRow(
                                              
                                              decoration: BoxDecoration(
                                                
                                                color: Colors.transparent,
                                              ),
                                              children: [
                                                _buildProductTableCell(
                                                  product['subItem']['product']?['name'] ?? 'غير محدد'.tr(),
                                                  textAlign: TextAlign.right,
                                                  fontSize: 9,
                                                ),
                                                _buildProductTableCell('${quantity.toInt()}', fontSize: 9),
                                                _buildProductTableCell(price.toStringAsFixed(2), fontSize: 9),
                                                _buildProductTableCell(
                                                  total.toStringAsFixed(2),
                                                  isTotal: true,
                                                  fontSize: 9,
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    
                                    // إذا كان هناك أكثر من 5 منتجات
                                    if (invoices[currentIndex]['products'].length > 5)
                                      Container(
                                        padding: EdgeInsets.all(8), // تصغير الحشوة
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+ ${invoices[currentIndex]['products'].length - 5} منتجات إضافية'.tr(),
                                            style: GoogleFonts.cairo(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 10, // تصغير الخط
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // زر الإغلاق
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white, size: 20), // تصغير حجم الأيقونة
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),

                    // مؤشر الصور
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // تصغير الحشوة
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${invoices.length}',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12, // تصغير الخط
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // أزرار التنقل
                  
                      
                        
                      
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // دالة مساعدة لبناء رأس الجدول مع إمكانية تحديد حجم الخط
  Widget _buildTableHeader(String text, {double fontSize = 10}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0), // تقليل الحشوة
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
    );
    
  }

  // دالة مساعدة لبناء خلية الجدول مع إمكانية تحديد حجم الخط
  Widget _buildTableCell(String text, {double fontSize = 10}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3), // تقليل الحشوة
      child: Text(
               text,
        style: GoogleFonts.cairo(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w900
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  // دالة مساعدة لبناء رأس جدول المنتجات مع إمكانية تحديد حجم الخط
  Widget _buildProductTableHeader(String text, {double fontSize = 10}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0), // تقليل الحشوة
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // دالة مساعدة لبناء خلية جدول المنتجات مع إمكانية تحديد حجم الخط
  Widget _buildProductTableCell(String text, {
    bool isTotal = false,
    TextAlign textAlign = TextAlign.center,
    double fontSize = 10
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3), // تقليل الحشوة
      child: Text(
        
        text,
        style: GoogleFonts.cairo(
          color: isTotal ? Colors.green : Colors.black,
          fontSize: 12,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // دالة جديدة: عرض الفاتورة الكاملة مع البيانات والجدول
  void _showFullInvoiceDetails(Map<String, dynamic> invoiceData) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: primaryColor),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          'فاتورة كاشير ريزو'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // صورة الفاتورة مع إمكانية التكبير المباشر
                    GestureDetector(
                      onTap: () {
                        List<Map<String, dynamic>> allInvoices = _getGroupedByInvoice();
                        int currentIndex = allInvoices.indexWhere((inv) => inv['invoice']['_id'] == invoiceData['invoice']['_id']);
                        if (currentIndex != -1) {
                          Navigator.of(context).pop();
                          _showImageGalleryWithData(allInvoices, currentIndex);
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: backgroundColor,
                                image: invoiceData['invoice']['image'] != null && invoiceData['invoice']['image'].isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(invoiceData['invoice']['image']),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                              ),
                              child: invoiceData['invoice']['image'] == null || invoiceData['invoice']['image'].isEmpty
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 60,
                                          color: accentColor,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'لا توجد صورة للفاتورة'.tr(),
                                          style: GoogleFonts.cairo(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'يمكنك عرض تفاصيل الفاتورة أدناه'.tr(),
                                          style: GoogleFonts.cairo(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          
                          if (invoiceData['invoice']['image'] != null && invoiceData['invoice']['image'].isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ),
                          
                          // مؤشر أن الصورة قابلة للتكبير
                          if (invoiceData['invoice']['image'] != null && invoiceData['invoice']['image'].isNotEmpty)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.zoom_in, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'انقر للتكبير'.tr(),
                                      style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // معلومات الفاتورة الأساسية
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات الفاتورة'.tr(),
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildDetailChip(Icons.person, invoiceData['invoice']['userID']?['name'] ?? 'غير محدد'.tr(), primaryColor, false),
                              _buildDetailChip(Icons.store, invoiceData['invoice']['branch']?['name'] ?? 'غير محدد'.tr(), secondaryColor, false),
                              _buildDetailChip(Icons.delivery_dining, invoiceData['invoice']['deliveryApp']?['name'] ?? 'غير محدد'.tr(), accentColor, false),
                              _buildDetailChip(Icons.calendar_today, invoiceData['date'], accentColor, false),
                              _buildDetailChip(Icons.access_time, invoiceData['time'], Colors.blue, false),
                              _buildDetailChip(Icons.receipt_long, '${invoiceData['products'].length} منتج'.tr(), Colors.green, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // جدول المنتجات
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المنتجات'.tr(),
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'الإجمالي: ${invoiceData['totalPrice'].toStringAsFixed(2)}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Ryalsar()
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12),
                          
                          // رأس الجدول
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'اسم المنتج'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'الكمية'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'السعر'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'المجموع'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // قائمة المنتجات
                          ...invoiceData['products'].asMap().entries.map<Widget>((entry) {
                            int index = entry.key;
                            var product = entry.value;
                            bool isEven = index % 2 == 0;
                            
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isEven ? backgroundColor.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['subItem']['product']?['name'] ?? 'غير محدد'.tr(),
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (product['subItem']['product']?['description'] != null)
                                          SizedBox(height: 2),
                                        if (product['subItem']['product']?['description'] != null)
                                          Text(
                                            product['subItem']['product']?['description'] ?? '',
                                            style: GoogleFonts.cairo(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${product['quantity']}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${product['productPrice'].toStringAsFixed(2)}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Ryalsar(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${product['totalProductPrice'].toStringAsFixed(2)}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: secondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Ryalsar(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          
                          // المجموع النهائي
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المجموع الكلي:'.tr(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${invoiceData['totalPrice'].toStringAsFixed(2)}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Ryalsar()
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // معلومات إضافية
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات إضافية'.tr(),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'تاريخ ووقت الإنشاء: ${invoiceData['fullDateTime']}'.tr(),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'معرف الفاتورة: ${invoiceData['invoice']['_id'] ?? 'غير متوفر'}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // أزرار الإجراءات
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'إغلاق'.tr(),
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        if (invoiceData['invoice']['image'] != null && invoiceData['invoice']['image'].isNotEmpty)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                List<Map<String, dynamic>> allInvoices = _getGroupedByInvoice();
                                int currentIndex = allInvoices.indexWhere((inv) => inv['invoice']['_id'] == invoiceData['invoice']['_id']);
                                if (currentIndex != -1) {
                                  Navigator.of(context).pop();
                                  _showImageGalleryWithData(allInvoices, currentIndex);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.zoom_in, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'تكبير الصورة'.tr(),
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
  }

  Widget _buildInvoiceSlider(List<Map<String, dynamic>> invoicesForDate, String date, {bool isLatest = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLatest 
              ? [secondaryColor.withOpacity(0.1), Colors.white]
              : [backgroundColor, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLatest
            ? [
                BoxShadow(
                  color: secondaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
        border: isLatest
            ? Border.all(color: secondaryColor.withOpacity(0.3), width: 2)
            : null,
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isLatest
                    ? [secondaryColor, primaryColor]
                    : [primaryColor, accentColor],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isLatest ? Icons.new_releases : Icons.calendar_today, color: Colors.white, size: 16),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isLatest ? '🔥 ' : ''}التاريخ: $date',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${invoicesForDate.length} ' +'فاتورة'.tr(),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoicesForDate.length.toString(),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ), SizedBox(width: 4,), Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [                      Ryalsar(),

                      Text(
                        "${invoicesForDate.fold(
                        0.0,
                        (sum, item) => sum + (item['totalPrice'] ?? 0),
                      )}",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(12),
              itemCount: invoicesForDate.length,
              itemBuilder: (context, index) {
                final invoiceData = invoicesForDate[index];
                final invoice = invoiceData['invoice'];
                bool hasImage = invoice['image'] != null && invoice['image'].isNotEmpty;
                
                return Container(
                  width: 120,
                  margin: EdgeInsets.symmetric(horizontal: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () {
                        if (hasImage) {
                          List<Map<String, dynamic>> allInvoices = _getGroupedByInvoice();
                          int currentIndex = allInvoices.indexWhere((inv) => inv['invoice']['_id'] == invoiceData['invoice']['_id']);
                          if (currentIndex != -1) {
                            _showImageGalleryWithData(allInvoices, currentIndex);
                          }
                        } else {
                          _showFullInvoiceDetails(invoiceData);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة الفاتورة أو الأيقونة
                            Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: hasImage
                                      ? DecorationImage(
                                          image: NetworkImage(invoice['image']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: hasImage
                                      ? Colors.transparent
                                      : backgroundColor,
                                ),
                                child: hasImage
                                    ? null
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long,
                                            color: accentColor,
                                            size: 24,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'فاتورة'.tr(),
                                            style: GoogleFonts.cairo(
                                              fontSize: 8,
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            
                            _buildInvoiceInfo(
                              Icons.list_alt,
                              '${invoiceData['products'].length} '+ "منتج".tr(),
                              primaryColor
                         ,false   ),
                            
                            SizedBox(height: 4),
                            
                            _buildInvoiceInfo(
                              Icons.attach_money_rounded,
                              '${invoiceData['totalPrice'].toStringAsFixed(2)}',
                              secondaryColor
                           ,true ),

                            SizedBox(height: 4),
                            
                            _buildInvoiceInfo(
                              Icons.store_rounded,
                              invoice['branch']?['name'] ?? 'غير محدد'.tr(),
                              accentColor,
                          false  ),

                            SizedBox(height: 4),
                            
                            _buildInvoiceInfo(
                              Icons.access_time,
                              invoiceData['time'],
                              Colors.blue
                           ,false ),
                            
                            
                            // تفاصيل المنتجات
                            Container(
                              width: 150,
                              height: 45,
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                 
                                  ...invoiceData['products'].take(2).map<Widget>((product) {
                                    return Text(
                                      '• ${product['subItem']['product']?['name'].split("\n")[0] ?? 'غير محدد'.tr()}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 8,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }).toList(),
                                  if (invoiceData['products'].length > 2)
                                    Text(
                                      '... +${invoiceData['products'].length - 2}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 8,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            
                        
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfo(IconData icon, String text, Color color ,bool isMoney) {
    return Row(
      children: [
       isMoney==false? Icon(icon, size: 12, color: color):Container(),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (icon == Icons.attach_money_rounded) Ryalsar(),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color, bool ishowSAR) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (ishowSAR) Ryalsar(),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    _safeSetState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchTawalfData();
  }

  // تجميع البيانات حسب التاريخ مع تجميع الفواتير وفرزها من الأحدث إلى الأقدم
  Map<String, List<Map<String, dynamic>>> _getGroupedDataByDate() {
    List<Map<String, dynamic>> groupedInvoices = _getGroupedByInvoice();
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    
    for (var invoice in groupedInvoices) {
      String date = invoice['date'];
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(invoice);
    }

    // ترتيب الفواتير داخل كل تاريخ من الأحدث إلى الأقدم
    groupedData.forEach((date, invoices) {
      invoices.sort((a, b) => b['sortDateTime'].compareTo(a['sortDateTime']));
    });

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedData = _getGroupedDataByDate();

    List<MapEntry<String, List<Map<String, dynamic>>>> sortedEntries = groupedData.entries.toList()
      ..sort((a, b) {
        // الحصول على أحدث فاتورة في كل تاريخ للفرز
        DateTime latestA = a.value.first['sortDateTime'];
        DateTime latestB = b.value.first['sortDateTime'];
        return latestB.compareTo(latestA); // من الأحدث إلى الأقدم
      });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
               "صور كاشير ريزو".tr(),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 22),
            onPressed: _refreshData,
            tooltip: 'تحديث البيانات'.tr(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: isLoading
            ? _buildLoadingState()
            : errorMessage.isNotEmpty
                ? _buildErrorState()
                : sortedEntries.isEmpty
                    ? _buildEmptyState()
                    : _buildDataState(sortedEntries),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Loadingwidget(),
          SizedBox(height: 20),
          Text(
            'جاري تحميل الفواتير...'.tr(),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'حدث خطأ'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                errorMessage,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'إعادة المحاولة'.tr(),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 50,
                color: accentColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد فواتير'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'لم يتم العثور على أي فواتير'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'تحديث'.tr(),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataState(List<MapEntry<String, List<Map<String, dynamic>>>> sortedEntries) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: primaryColor,
      backgroundColor: Colors.white,
      displacement: 20,
      strokeWidth: 2,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 12),
        itemCount: sortedEntries.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          String date = sortedEntries[index].key;
          List<Map<String, dynamic>> invoices = sortedEntries[index].value;
          
          return _buildInvoiceSlider(invoices, date, isLatest: index == 0);
        },
      ),
    );
  }
}