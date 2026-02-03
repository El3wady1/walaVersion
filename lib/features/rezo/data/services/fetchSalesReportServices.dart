import 'dart:convert';

import 'package:saladafactory/core/utils/apiEndpoints.dart';

import '../model/salesReportModel.dart';
import 'package:http/http.dart' as http;
Future<SalesReport> fetchSalesReport() async {

  final response = await http.get(Uri.parse(Apiendpoints.baseUrl+Apiendpoints.rezoCasher.gettotalsReport));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return SalesReport.fromJson(data);
  } else {
    throw Exception("Failed to load sales report");
  }
}
