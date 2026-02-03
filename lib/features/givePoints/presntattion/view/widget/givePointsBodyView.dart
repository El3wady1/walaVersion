import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saladafactory/core/utils/LoadingWidget.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/colors.dart';

import '../../../../../core/utils/getLangState.dart';

class Givepointsbodyview extends StatefulWidget {
  Givepointsbodyview({super.key});

  @override
  State<Givepointsbodyview> createState() => _GivepointsbodyviewState();
}

class _GivepointsbodyviewState extends State<Givepointsbodyview> {
  final Dio _dio = Dio();
  List<dynamic> pointsHistory = [];
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  bool isAddingPoints = false;
  bool isLoadingUsers = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  String? _selectedUserId;
  String _selectedRate = '+';

  @override
  void initState() {
    super.initState();
    _fetchPointsHistory();
    _fetchUsers();
  }

  Future<void> _fetchPointsHistory() async {
    setState(() => isLoading = true);
    try {
      final response = await _dio.get(
        '${Apiendpoints.baseUrl}${Apiendpoints.walaaHistory.getGivenPoint}',
      );
      
      if (response.statusCode == 200) {
        setState(() {
          pointsHistory = response.data['data'];
        });
      }
    } catch (e) {
      print('Error fetching points history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load points history')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoadingUsers = true);
    try {
      final response = await _dio.get(
        '${Apiendpoints.baseUrl}${Apiendpoints.user.getAll}',
      );
      
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data['data']);
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() => isLoadingUsers = false);
    }
  }

  Future<void> _addPoints() async {
    if (_titleController.text.isEmpty || 
        _pointsController.text.isEmpty ||
        _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a user'.tr())),
      );
      return;
    }

    setState(() => isAddingPoints = true);
    try {
          var langState = LocallizationHelper.get(context);

      final response = await _dio.post(
        '${Apiendpoints.baseUrl}${Apiendpoints.walaaHistory.setPoints}',
        data: {
          "title": _titleController.text,
          "status": "collect",
          "points": int.parse(_selectedRate.toString()+_pointsController.text),
          "place": "h", 
          "rate": "+",
          "userId": _selectedUserId,
          "collect": false,
           "language": langState.languageCode
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _titleController.clear();
        _pointsController.clear();
        setState(() {
          _selectedUserId = null;
          _selectedRate = '+';
        });
        
        _fetchPointsHistory();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Points added successfully')),
        );
      }
    } catch (e) {
      print('Error adding points: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add points: ${e.toString()}')),
      );
    } finally {
      setState(() => isAddingPoints = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'collect': return 'جمع'.tr();
      default: return status;
    }
  }

   _getStatusColor(bool status) {
    switch (status) {
      case true: return AppColors.primaryColor;
      case false: return Colors.lightBlue.shade700;
      default: return Colors.grey;
    }
  }

  String _getTitle(dynamic title) {
    if (title is String) return title;
    if (title is Map<String, dynamic>) return title['title'] ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? Center(child: Loadingwidget())
          : Padding(
              padding: const EdgeInsets.all(12.0), // تصغير padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3, // تصغير elevation
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // تصغير border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // تصغير padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'إضافة نقاط جديدة'.tr(),
                                style: GoogleFonts.cairo(
                                  fontSize: 16, // تصغير حجم الخط
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Container(
                                width: 120, // تصغير العرض
                                height: 36, // تصغير الارتفاع
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6), // تصغير border radius
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedRate = '+';
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _selectedRate == '+' 
                                                ? AppColors.primaryColor
                                                : Colors.white,
                                            border: Border.all(
                                              color: AppColors.primaryColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add, 
                                                color: _selectedRate == '+' 
                                                    ? Colors.white 
                                                    : AppColors.primaryColor,
                                                size: 16, // تصغير حجم الأيقونة
                                              ),
                                              SizedBox(width: 3), // تصغير المسافة
                                              Text(
                                                'إضافة'.tr(),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11, // تصغير حجم الخط
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedRate == '+' 
                                                      ? Colors.white 
                                                      : AppColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedRate = '-';
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _selectedRate == '-' 
                                                ? AppColors.accentColor
                                                : Colors.white,
                                            border: Border.all(
                                              color: AppColors.accentColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.remove, 
                                                color: _selectedRate == '-' 
                                                    ? Colors.white 
                                                    : AppColors.accentColor,
                                                size: 16, // تصغير حجم الأيقونة
                                              ),
                                              SizedBox(width: 3), // تصغير المسافة
                                              Text(
                                                'خصم'.tr(),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11, // تصغير حجم الخط
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedRate == '-' 
                                                      ? Colors.white 
                                                      : AppColors.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12), // تصغير المسافة
                          TextField(
                            controller: _titleController,
                            maxLines: 3,
                            style: GoogleFonts.cairo(fontSize: 14), // تصغير حجم الخط
                            decoration: InputDecoration(
                              hintText: "سبب".tr(),
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 14,
                                
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6), // تصغير border radius
                                borderSide: BorderSide(color: AppColors.secondaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5), // تصغير العرض
                              ),
                              prefixIcon: Icon(Icons.title, 
                                color: AppColors.primaryColor,
                                size: 20, // تصغير حجم الأيقونة
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10, // تصغير padding الداخلي
                                horizontal: 12,
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundColor,
                            ),
                          ),
                          
                          SizedBox(height: 10), // تصغير المسافة
                          TextField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cairo(fontSize: 14), // تصغير حجم الخط
                            decoration: InputDecoration(
                              labelText: 'عدد النقاط'.tr(),
                              labelStyle: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6), // تصغير border radius
                                borderSide: BorderSide(color: AppColors.secondaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5), // تصغير العرض
                              ),
                              prefixIcon: Icon(Icons.confirmation_number, 
                                color: AppColors.primaryColor,
                                size: 20, // تصغير حجم الأيقونة
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10, // تصغير padding الداخلي
                                horizontal: 12,
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundColor,
                            ),
                          ),
                          
                          SizedBox(height: 10), // تصغير المسافة
                          isLoadingUsers
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, // تصغير سمك المؤشر
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                    ),
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: _selectedUserId,
                                  style: GoogleFonts.cairo(fontSize: 14), // تصغير حجم الخط
                                  decoration: InputDecoration(
                                    labelText: 'المستخدم'.tr(),
                                    labelStyle: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6), // تصغير border radius
                                      borderSide: BorderSide(color: AppColors.secondaryColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5), // تصغير العرض
                                    ),
                                    prefixIcon: Icon(Icons.person, 
                                      color: AppColors.primaryColor,
                                      size: 20, // تصغير حجم الأيقونة
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, // تصغير padding الداخلي
                                      horizontal: 12,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.backgroundColor,
                                  ),
                                  dropdownColor: Colors.white,
                                  iconSize: 20, // تصغير حجم أيقونة السهم
                                  items: users.map((user) {
                                    return DropdownMenuItem<String>(
                                      value: user['_id'],
                                      child: Text(
                                        '${user['name']}',
                                        style: GoogleFonts.cairo(fontSize: 14,color: Colors.black), // تصغير حجم الخط
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUserId = value;
                                    });
                                  },
                                ),
                          
                          SizedBox(height: 12), // تصغير المسافة
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isAddingPoints ? null : _addPoints,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRate == '+' 
                                    ? AppColors.primaryColor 
                                    : AppColors.accentColor,
                                padding: EdgeInsets.symmetric(vertical: 12), // تصغير padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6), // تصغير border radius
                                ),
                                elevation: 1, // تصغير elevation
                              ),
                              child: isAddingPoints
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2, // تصغير سمك المؤشر
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _selectedRate == '+' 
                                              ? Icons.add 
                                              : Icons.remove,
                                          color: Colors.white,
                                          size: 18, // تصغير حجم الأيقونة
                                        ),
                                        SizedBox(width: 6), // تصغير المسافة
                                        Text(
                                          _selectedRate == '+' 
                                              ? 'إضافة النقاط'.tr() 
                                              : 'خصم النقاط'.tr(),
                                          style: GoogleFonts.cairo(
                                            fontSize: 14, // تصغير حجم الخط
                                            fontWeight: FontWeight.bold,
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
                  ),
                  
                  SizedBox(height: 16), // تصغير المسافة
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سجل النقاط'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 16, // تصغير حجم الخط
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 10), // تصغير المسافة
                        Expanded(
                          child: pointsHistory.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 48, // تصغير حجم الأيقونة
                                        color: AppColors.secondaryColor,
                                      ),
                                      SizedBox(height: 12), // تصغير المسافة
                                      Text(
                                        'لا توجد سجلات للنقاط'.tr(),
                                        style: GoogleFonts.cairo(
                                          fontSize: 14, // تصغير حجم الخط
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: pointsHistory.length,
                                  itemBuilder: (context, index) {
                                    final item = pointsHistory[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 8), // تصغير margin
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8), // تصغير border radius
                                      ),
                                      elevation: 1, // تصغير elevation
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0), // تصغير padding
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _getTitle(item['title']),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 14, // تصغير حجم الخط
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primaryColor,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(width: 6), // تصغير المسافة
                                                Chip(
                                                  labelPadding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 0,
                                                  ),
                                                  label: Text(
                                                   item['points'].toString().contains("-")?"خصم".tr(): item['collect']==true?"جمع".tr():"لم يجمع".tr(),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 11, // تصغير حجم الخط
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: item['points'].toString().contains("-")?Colors.red: _getStatusColor(item['collect']),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12), // تصغير border radius
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity: VisualDensity.compact, // جعل الشيب أكثر إحكاماً
                                                ),
                                              ],
                                            ),
                                            
                                            SizedBox(height: 6), // تصغير المسافة
                                            Divider(
                                              color: AppColors.secondaryColor.withOpacity(0.3),
                                              height: 1, // تصغير ارتفاع الخط
                                            ),
                                            
                                            SizedBox(height: 6), // تصغير المسافة
                                            Text(
                                              'المستخدم:'.tr()+' ${item['userId'] != null ? item['userId']['name'] ?? 'غير معروف' : 'غير معروف'.tr()}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12, // تصغير حجم الخط
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            
                                            SizedBox(height: 4), // تصغير المسافة
                                            Row(
                                              children: [
                                      
                                                Text(
                                                  'النقاط:'.tr()+' ${item['points']}',
                                                  style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14, // تصغير حجم الخط
                                                    color: item['points'].toString().contains("-")
                                                        ? Colors.red
                                                        :  AppColors.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                            SizedBox(height: 6), // تصغير المسافة
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.receipt,
                                                  size: 12, // تصغير حجم الأيقونة
                                                  color: AppColors.secondaryColor,
                                                ),
                                                SizedBox(width: 3), // تصغير المسافة
                                                Expanded(
                                                  child: Text(
                                                    "رقم العملية".tr()+" "+'${item['trxId'] ?? 'غير متوفر'.tr()}',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 11, // تصغير حجم الخط
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                            SizedBox(height: 2), // تصغير المسافة
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12, // تصغير حجم الأيقونة
                                                  color: AppColors.secondaryColor,
                                                ),
                                                SizedBox(width: 3), // تصغير المسافة
                                                Expanded(
                                                  child: Text(
                                                    'التاريخ:'.tr()+' ${item['createdAt'] != null ? DateTime.parse(item['createdAt']).toLocal().toString().split('.')[0] : 'غير معروف'}',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 11, // تصغير حجم الخط
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
}