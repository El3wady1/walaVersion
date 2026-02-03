import 'package:dio/dio.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';


Future getDailyProductionAndSupplyExist() async {
  try {
    final results = await Future.wait([
      checkIfBranchesorderProductionZero(),
      checkIfBranchesorderSupplyZero(),
    ]);

    final isProductionZero = results[0];
    final isSupplyZero = results[1];

    if (isProductionZero ==true&& isSupplyZero==true) {
      return 2; 
    } else if (isProductionZero ==true|| isSupplyZero==true) {
      return 1; 
    } else {
      return 0;
    }
  } catch (e) {
    print("getDailyProductionAndSupplyExist error: $e");
    return 0; 
  }
}


Future<bool> checkIfBranchesorderProductionZero() {
  return _checkIfBranchesZero(
    Apiendpoints.baseUrl +
        Apiendpoints.orderProduction.getOrderPof2Days,
  );
}


Future<bool> checkIfBranchesorderSupplyZero() {
  return _checkIfBranchesZero(
    Apiendpoints.baseUrl +
        Apiendpoints.orderSupply.getOrderSof2Days,
  );
}

Future<bool> _checkIfBranchesZero(String url) async {
  final dio = Dio();

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final branchesNumber = response.data['branchesnumber'] ?? 0;
      if( branchesNumber != 0){
        return true;
      }else{
        return false;
      };
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  } catch (e) {
    print("_checkIfBranchesZero error: $e");
    rethrow;
  }
}
