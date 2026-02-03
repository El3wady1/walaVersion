import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/core/utils/localls.dart';
import 'package:saladafactory/features/in/data/services/addQtyAndExpiredProductServices.dart';

class MultiBarcodeEntryView extends StatefulWidget {
  @override
  State<MultiBarcodeEntryView> createState() => _MultiBarcodeEntryViewState();
}

class _MultiBarcodeEntryViewState extends State<MultiBarcodeEntryView> {
  final Color primaryColor = const Color(0xFF74826A);
  final Color backgroundColor = const Color(0xFFF3F4EF);

  bool isloading = false;

  final List<ProductEntry> products = [];
  final TextEditingController barcodeController = TextEditingController();

  List<Map<String, dynamic>> suppliers = [];
  String? selectedSupplierId;
  String? selectedSupplierName;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  // ================= SUPPLIERS =================
  Future<void> _fetchSuppliers() async {
    setState(() => isloading = true);
    try {
      final response = await http.get(
        Uri.parse('${Apiendpoints.baseUrl}supplier/getAll'),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        suppliers = List<Map<String, dynamic>>.from(data['data']);
        if (suppliers.isNotEmpty) {
          selectedSupplierId = suppliers.first['_id'];
          selectedSupplierName = suppliers.first['name'];
        }
      }
    } finally {
      setState(() => isloading = false);
    }
  }

  // ================= SCAN BARCODE =================
  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null && result.isNotEmpty) {
      barcodeController.text = result;
      _fetchProductInfo(result);
    }
  }

  // ================= FETCH PRODUCT =================
  Future<void> _fetchProductInfo(String barcode) async {
    setState(() => isloading = true);
    try {
      final response = await http.post(
        Uri.parse('${Apiendpoints.baseUrl}product/barcode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'bracode': barcode}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        _showProductDialog(data['data']);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('المنتج غير موجود')));
      }
    } finally {
      setState(() => isloading = false);
    }
  }

  // ================= PRODUCT DIALOG =================
  Future<void> _showProductDialog(Map<String, dynamic> productData) async {
    final quantityController = TextEditingController(text: "1");
    final expireDateController = TextEditingController();
    final priceController =
        TextEditingController(text: productData['price'].toString());
    final noteController = TextEditingController();

    bool addProduct = false;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: intl.TextDirection.rtl,
          child: AlertDialog(
            title: const Text('معلومات المنتج'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الاسم: ${productData['name']}'),
                  Text('الباركود: ${productData['bracode']}'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'الكمية'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر'),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                        expireDateController.text =
                            "${picked.day}/${picked.month}/${picked.year}";
                        setState(() {});
                      }
                    },
                    child: TextField(
                      controller: expireDateController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'ملاحظات'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  addProduct = true;
                  Navigator.pop(context);
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );

    if (addProduct) {
      setState(() {
        products.add(
          ProductEntry(
            barcode: productData['bracode'],
            productID: productData['_id'],
            productName: productData['name'],
            unitId: productData['unit']['_id'],
            unit: productData['unit']['name'],
            supplierId:
                selectedSupplierId ?? productData['supplierAccepted']['_id'],
            supplierName:
                selectedSupplierName ?? productData['supplierAccepted']['name'],
            quantityController: quantityController,
            expireDateController: expireDateController,
            priceController: priceController,
            noteController: noteController,
            quantity: double.parse(quantityController.text),
            expireDate: selectedDate,
          ),
        );
        barcodeController.clear();
      });
    }
  }

  // ================= SAVE =================
  Future<void> _saveAllProducts() async {
    setState(() => isloading = true);
    try {
      for (var product in products) {
        await addQuantityAndExpiryDate(
          qty: product.quantity,
          bracode: product.barcode,
          expireDate: product.expireDate!.toUtc().toIso8601String(),
          priceIN: double.parse(product.priceController.text),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الحفظ بنجاح'.tr())),
      );
      Navigator.pop(context);
    } finally {
      setState(() => isloading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('إدخال متعدد للباركود'),
          backgroundColor: primaryColor,
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveAllProducts)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'مسح الباركود',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ),
                onSubmitted: _fetchProductInfo,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return ListTile(
                      title: Text(p.productName),
                      subtitle: Text(p.barcode),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            setState(() => products.removeAt(i)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SCANNER PAGE =================
class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الباركود')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
       onDetect: (BarcodeCapture capture) {
  final String? code = capture.barcodes.first.rawValue;
  if (code != null) {
    Navigator.pop(context, code);
  }
},
)
    );
  }
}

// ================= MODEL =================
class ProductEntry {
  final String barcode;
  final String productID;
  final String productName;
  final String unitId;
  final String unit;
  String supplierName;
  String supplierId;
  double quantity;
  DateTime? expireDate;

  TextEditingController quantityController;
  TextEditingController expireDateController;
  TextEditingController priceController;
  TextEditingController noteController;

  ProductEntry({
    required this.barcode,
    required this.productID,
    required this.productName,
    required this.unitId,
    required this.unit,
    required this.supplierName,
    required this.supplierId,
    required this.quantityController,
    required this.expireDateController,
    required this.priceController,
    required this.noteController,
    required this.quantity,
    this.expireDate,
  });
}
