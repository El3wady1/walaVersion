import 'package:saladafactory/core/utils/apiEndpoints.dart';
import 'package:saladafactory/features/home/data/services/fetchandCacheProducts.dart';
import 'package:saladafactory/features/home/data/services/fetchandCacheSupplier.dart';
import 'package:saladafactory/features/home/data/services/fetchandCacheUnit.dart';
import 'package:saladafactory/features/home/data/services/fetchandCacheUserDep.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Cachehelper {
  static var loadCacheSuppliers;
  static var loadCacheUnits;
  static var loadCacheProducts;
  static var loadCachedUserDep;

  fetchDataandStoreLocaallly() async {
    await SupplierSS.fetchAndCacheSuppliers();
    await Unitss.fetchAndCacheUnits();
    await SupplierSS.loadCachedSuppliers().then((cached) {
      loadCacheSuppliers = cached;
      print(cached);
    });
    await Unitss.loadCachedUnits().then((cached) {
      loadCacheUnits = cached;
      print(cached);
    });

  await  UserDepartment.fetchAndCacheUserDep();
  await  UserDepartment.loadCachedUserDep().then((cached) {
      loadCachedUserDep = cached;
      print("userDep ::::: ${cached}");
    });
    await ProductsS.fetchAndCacheProducts();
        print("=============================fetchProductCachedSucces===================================");

    await ProductsS.loadCachedProducts().then((cached) {
      print("locall product  $cached");
      loadCacheProducts = cached;
    });
    print("=============================fetchDataandCachedSucces===================================");
  }

static Future<String?> fetchVersionDes() async {
  final url = Uri.parse(
    "https://v1110-production.up.railway.app/api/settings/695847665c09b3452ee81766",
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    print(jsonData['data']['des']);
    return jsonData['data']['des']; // V1.3.10
  } else {
    throw Exception('Failed to load data');
  }
}

  
}
