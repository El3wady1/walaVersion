import 'package:dio/dio.dart';
import 'package:saladafactory/core/utils/apiEndpoints.dart';

Future GetnumberofBranchsSPOrder({required String endpointsSorP}) async {
  final dio = Dio();

  try {
    final response = await dio.get(Apiendpoints.baseUrl+endpointsSorP);

    if (response.statusCode == 200) {
      final branchesNumber = response.data['branchesnumber'] ?? 0;
      print("hh++++"+branchesNumber.toString());
        return response.data['branchesnumber'].toString();
   
    } else {
     return null;
    }
  } catch (e) {
    print("GetnumberofBranchsSPOrder error: $e");
    return null ;
  }
}