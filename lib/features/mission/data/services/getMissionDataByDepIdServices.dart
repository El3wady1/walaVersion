import 'package:dio/dio.dart';
import 'package:saladafactory/features/mission/data/model/missionModel.dart';
import 'package:saladafactory/features/mission/data/services/getUserID.dart';
import '../../../../core/utils/apiEndpoints.dart';
import '../../../../core/utils/localls.dart';
Future<List<MissionModel>> getMissionDataByDepIdServices() async {
  try {
    final dio = Dio();
        var departmentId;

await getUserDepartmentId().then((v)=>departmentId=v);
    print("Department ID: $departmentId");

    final response = await dio.get(
      Apiendpoints.baseUrl + Apiendpoints.mission.getByDepId + departmentId,
    );

    print("Response: ${response.data}");

    if (response.data["status"] == 200) {
      final list = response.data["data"] as List;
      return list.map((e) => MissionModel.fromJson(e)).toList();
    } else {
      print("Server returned status: ${response.data["status"]}");
      return [];
    }
  } catch (e) {
    print("Mission Service Error: $e");
    return [];
  }
}
