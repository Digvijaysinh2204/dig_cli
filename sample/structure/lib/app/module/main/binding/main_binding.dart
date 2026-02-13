import '../../../utils/import.dart';
import '../controller/main_controller.dart';
import '../services/user_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.put(UserService());
  }
}
