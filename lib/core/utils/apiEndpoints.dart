class Apiendpoints {
//  static String host ="http://192.168.1.7:8000";
//  static String baseUrl = "$host/api/";
  //static String baseUrl ="https://6304f295-cc81-4d4d-8c41-308d95791113-00-39g1jxagegtcf.spock.replit.dev/api/";
  //real
     //test
     static String baseUrl ="https://v1110-production.up.railway.app/api/";
    //  static String baseUrl ="https://saladfactorybackendv211testblockeddev-production.up.railway.app/api/";
  static Auth auth = Auth();
  static Product product = Product();
  static Unit unit = Unit();
  static Supplier supplier = Supplier();
  static Transaction transaction = Transaction();
  static User user = User();
  static Department department = Department();
  static Email email = Email();
  static MainProduct mainProduct = MainProduct();
  static Fatwra fatwra = Fatwra();
  static Branch branch = Branch();
  static ProductOP productOP =ProductOP();
  static OrderProduction orderProduction = OrderProduction();
  static OrderSupply orderSupply = OrderSupply();
  static MainProductOP mainProductOP = MainProductOP();
  static Production  production =Production();
  static ProductionSupply  productionSupply =ProductionSupply();
  static Send  send =Send();
  static Settings  settings =Settings();
  static SendProcess  sendprocess =SendProcess();
static Tawalf tawalf =Tawalf();
static BlockDevice blockdevice =BlockDevice();
static CaherRezo rezoCasher =CaherRezo();
static RezoProductCasher rezoProductCasher= RezoProductCasher();
static DeliveryApp deliveryApp =DeliveryApp();
static MixProduct mixproduct =MixProduct();
static Mix mix =Mix();
static FinalMix finalMix =FinalMix();
static Level level =Level();
static Mission mission =Mission();
static Rewards rewards =Rewards();
static Category category =Category();
static WalaaHistory walaaHistory =WalaaHistory();
}

class Auth {
  String login = "auth/login";
  String userData = "auth/user";
  String createuser = "users/create";
  String userDep = "auth/user/department";
  String userBranchOP = "auth/user/BranchOP";
  String userBranchOS = "auth/user/BranchOS";
    String userBranchTawalf="auth/user/BranchTawalf";
String userBranchRezoCasher ="auth/user/BranchRezoCasher";

String sendEmailOTP ="auth/user/send-email-otp";
String verifyEmailOTP ="auth/user/verify-email-otp";
}

class Product {
  String getByBarcode = "product/barcode";
  String add = "product/add";
  String getAll="product/getAll";
  String updateByid ="product/";
  String getByid="product/";
  String dowunloadXls="product/download/excel/";
  String updateminQty="product/minQty/";
  String deleteByid="product/";
  String downloadAll="product/downloadAll";
  String addqtyAndexpired="product/addqtyAndexpiredByBarcode";
  String outproduct="product/outproduct";
  String relatedOrderProduction="product/relatedOrderProduction";

}

class Unit {
  String getall = "unit/getAll";
    String getByid = "unit/";
  String addunit= "unit/addunit";
  String delete = "unit/";
    String updateByid = "unit/";

}

class Supplier {
  String add = "supplier/addSupplier";
  String getall = "supplier/getAll";
  String updateByid = "supplier/";
  String delete = "supplier/";
}

class Transaction {
  String add = "transaction/add";
  String Byid="transaction/";
  String getAll = "transaction/getAll";
  String addwhenaddnoProduct = "transaction/addwhenaddNewProduct";
  String downloadTrancByid="transaction/export/";
  String downloadAllTranc="transaction/exports/all";
}

class User {
  String getAll = "users/getAll";
  String delete = "users/";
  String update = "users/";
  String updateUserdep = "users/updateUserdep/";
  String verfiy = "users/activeAcouunt/";
  String canRemoveProduct = "users/perToremove/";
  String canAddProduct = "users/perToadd/";
    String canAddProductIN = "users/canAddProductIN/";
    
    String canReceiveProduct = "users/canReceiveProduct/";
    String canProduction = "users/canProduction/";
    String canOrderProduction = "users/canOrderProduction/";

    String  canEditLastOrderProduction= "users/canEditLastOrderProductionProduct/";
    String canEditLastSupply  = "users/canEditLastSupplyProduct/";


    String canSendProduct = "users/canSendProduct/";
    String canSupplyProduct = "users/canSupplyProduct/";
    String canDamagedProduct = "users/canDamagedProduct/";
    String add_branchOP = "users/add-branchOP";
    String remove_branchOP = "users/remove-branchOP"; 
     String add_branchOS = "users/add-branchOS";
    String remove_branchOS = "users/remove-branchOS";
    //tawalf
    String add_branchTawalf = "users/add-branchTawalf";
    String remove_branchTawalf  = "users/remove-branchTawalf";
    String add_branchCasher ="users/add-branchRezoCasher";
        String remove_branchCasher ="users/remove-branchRezoCasher";
        String showaddRZOCasher ="users/showaddRZOCasher/";
        String canShowTawalf ="users/showTawalf/";
    String canaddRezoCahser="users/showaddRZOCasher/";
    String  canshowCahserRezoPhoto ="users/showRZOPhotoCasher/";
    String canshowRezoCahser ="users/showRZOCasher/";
}

class Department {
  String getAll = "department/getAll";
  String getByid = "department/";
  String addDepartment = "department/addDepartment";
  String delete = "department/";
}
class Email {
  String getByid = "email/";
  String update = "email/";
}
class MainProduct {
  String add = "mainProduct/addmainProduct";
  String getAll = "mainProduct/getAll";
  String update = "mainProduct/";
  String delete= "mainProduct/";
}
class MainProductOP {
  String add = "mainProductOP/addmainProductOP";
  String getAll = "mainProductOP/getAll";
  String update = "mainProductOP/";
  String updateOrder="mainProductOP/updateProductsOrder";
  String delete= "mainProductOP/";
}
class Fatwra {
  String add = "fatwra/addfatwra";
  String getAll = "fatwra/getAll";
  String update = "fatwra/";
  String delete= "fatwra/";
}
class Branch{
  String getall="branch/getAll";
  String updateTawalfProductsTobranch="branch/updateTawalfProductsTobranch/";
  String getById= "branch/";
}
class OrderProduction{
    String add = "orderProduction/add";
    String getAll = "orderProduction/getAll";
    String update ="orderProduction/" ;
    String delete= "orderProduction/";
    String isSend= "orderProduction/isSended/";
    String getOrderPof2Days = "orderProduction/getOrderPof2Days";

}

class ProductOP{
    String add = "productOP/add";
  String getAll = "productOP/getAll";
  String getrelatedMainproductOP= "/getrelatedMainproductOP";
  String main= "productOP/";
  String update = "productOP/";
  String Issupply = "productOP/Issupply/";
  String IsTawalf = "productOP/IsTawalf/";
  String delete= "productOP/";
}

class Production {
      String request = "production/request";
      String getPending = "production/requests/pending";
String approve = "production/approve";
String refusePendingRequest = "production/refusePendingRequest/";
String updateQty = "production/updateQty/";
String Qtyproduction = "production/Qtyproduction/";
String approved = "production/approved";
String delete= "production/refuseacceptedRequest/";

String history= "production//history";
String updatehistory= "production//history/";
String deletehistory= "production/deletehistory/";
String download= "production/downloadHistoryS_Excel";

}      
class OrderSupply{
     String add = "orderSupply/add";
    String getAll = "orderSupply/getAll";
    String getOrderSof2Days = "orderSupply/getOrderSof2Days";
    String update ="orderSupply/" ;
    String delete= "orderSupply/";
 String isSend= "orderSupply/isSended/";
}   


class Send{
      String getAll = "production/send/getAllSendHistory";
    String update ="production/send/updateHistorysend/" ;
    String delete= "production/send/deleteHistorysend/";
}

class ProductionSupply {
    String request = "ProductionSupply/request";
      String getPending = "ProductionSupply/requests/pending";
String approve = "ProductionSupply/approve";
String refusePendingRequest = "ProductionSupply/refusePendingRequest/";
String updateQty = "ProductionSupply/updateQty/";
String Qtyproduction = "ProductionSupply/QtyProductionSupply/";
String approved = "ProductionSupply/approved";
String delete= "ProductionSupply/refuseacceptedRequest/";

String history= "ProductionSupply//history";
String updatehistory= "ProductionSupply//history/";
String deletehistory= "ProductionSupply/deletehistory/";
String download= "ProductionSupply/downloadHistoryS_Excel";

}


class Settings{
     String add = "settings/create";
    String getAll = "settings/all";
    String update ="settings/" ;
    String delete= "settings/";
    String appstate="settings/68de82e16458107d3e5955d1";
    String getactive_30minOrderProduction="settings/68ec49998834d921a0f7f0ed";
    
        String makeactive_30minOrderProduction="settings/start/68ec49998834d921a0f7f0ed";

 String getactive_30minOrderSupply="settings/68ec40a9eaf3149b05629a9a";
    
        String makeactive_30minOrderSupply="settings/start/68ec40a9eaf3149b05629a9a";

String getUrlPrintPageofSP="settings/693d447faa0c9f8007a14b50";
    }



    class SendProcess{
      String getAll = "sendProcess/all";
    String delete ="sendProcess/" ;
}

class Tawalf {
  String getall="tawalf/getAll";
  String update="tawalf/";
  String add="tawalf/create";
  String delete="tawalf/";
  String removeProductsOPFromUnit(String unitId) {
    return "unit/$unitId/remove-productsOP";
  }
   String addProductsOPFromUnit(String unitId) {
    return "unit/$unitId/add-productsOP";
  }
  String userBranchTawalf="user/BranchTawalf";
}

class BlockDevice{
        String getAll = "failedDevices/getAllblocked-Devices";
    String controldevice ="failedDevices/controldevice/" ;
    String delete="failedDevices/failedlogins/" ;
}
class CaherRezo{
  String add ="rezoCasher/create";
    String getAll = "rezoCasher/getAll";
    String gettotalsReport = "rezoCasher/getSalesReport";
    String delete ="rezoCasher/" ;
        String update ="rezoCasher/" ;

}
class RezoProductCasher{
String add ="productcasherRezo/add";
    String getAll = "productcasherRezo/getAll";
    String delete ="productcasherRezo/delete/" ;
        String update ="productcasherRezo/update/" ;
}
class DeliveryApp {
  String add ="deliveryApp/add";
    String getAll = "deliveryApp/getAll";
    String delete ="deliveryApp/" ;
        String update ="deliveryApp/" ;
}
class MixProduct{
   String add ="mixproduct/create";
    String getAll = "mixproduct/getAllMixproduct";
    String delete ="mixproduct/" ;
        String update ="mixproduct/" ;
}

class Mix{
   String add ="mixed/create";
    String getAll = "mixed/all";
    String delete ="mixed/" ;
        String update ="mixed/" ;
}

class FinalMix{
   String add ="finalMixed/create";
    String getAll = "finalMixed/all";
    String delete ="finalMixed/" ;
        String update ="finalMixed/" ;
}
class Level{
   String add ="level/create";
    String getAll = "level/getAll";
    String delete ="level/" ;
        String update ="level/" ;
}
class Mission{
     String add ="misson/create";
    String getAll = "misson/getAll";
        String getByDepId = "misson/department/";

    String delete ="misson/" ;
        String update ="misson/" ;
}
class Rewards  {
      String add ="rewards/create";
    String getAll = "rewards/getall";
    String delete ="rewards/" ;
        String update ="rewards/" ;
        String showrewardByDepID="rewards/updateShowR/";
        String getAllRewardsByDepIDandShown="rewards/displayedByDepart";
}
class Category {
   String add ="category/add";
    String getAll = "category/getAll";
    String delete ="category/" ;
        String update ="category/" ;
                String getById ="category/" ;

}
class WalaaHistory {
   String add ="walaaHistory/makeRedeem";
   String getAll="walaaHistory/getAll";
   String getAlluserHistory= "walaaHistory/userWHistory";
   String Iscollect="walaaHistory/";
   String getPending="walaaHistory/getWalaaHistoryPending";
   String acceptgift="walaaHistory/accpetRedeem/";
   String refusegift="walaaHistory/redeem/cancelRedeem/";
   String createPointUser="walaaHistory/";
   String getGivenPoint="walaaHistory/getGivenPoint";
   String setPoints="walaaHistory/setPoints";
}