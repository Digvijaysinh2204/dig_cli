import 'dart:async';

import '../../../model/user_model.dart';
import '../../../utils/import.dart';

class UserService extends GetxService {
  static UserService get instance => Get.find<UserService>();

  final isLoading = false.obs;
  final user = Rx<UserModel?>(null);

  bool get isGuest => user.value?.guestId != null && user.value!.guestId! > 0;

  @override
  void onInit() {
    super.onInit();
    _listenUserChanges();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await loadLocalUser();

    if (!isGuest && user.value != null) {
      unawaited(getUserProfile());
    } else {
      kLog(
        content: 'Skipping API — guest user detected',
        title: 'USER PROFILE',
      );
    }
  }

  Future<void> getUserProfile() async {
    if (isGuest) {
      kLog(
        content: 'Guest user — profile fetch skipped',
        title: 'USER PROFILE',
      );
      return;
    }

    isLoading(true);
    try {
      /* final result = await ApiService.request<StatusModel<UserModel>>(
        url: Endpoints.userProfile,
        method: RequestMethod.get,
        fromJson: (data) => StatusModel.fromJson(data, UserModel.fromJson),
      );

      if (result.isSuccess) {
        final userData = result.data?.data ?? UserModel();
        await StoreData.setData(StoreKey.userData, userData.toJson());
        user.value = userData;
        kLog(content: '✅ User profile updated', title: 'USER PROFILE');
      } */
    } catch (e) {
      kLog(content: '❌ $e', title: 'Get User Data Failed');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadLocalUser() async {
    final stored = await StoreData.readData(StoreKey.userData);
    if (stored != null) {
      user.value = UserModel.fromJson(Map<String, dynamic>.from(stored));
      kLog(content: 'User loaded locally', title: 'USER PROFILE');
    }
  }

  Future<void> clearUser() async {
    await StoreData.removeData(StoreKey.userData);
    user.value = null;
  }

  void updateUser(UserModel updated) {
    user.value = updated;
    StoreData.setData(StoreKey.userData, updated.toJson());
  }

  void _listenUserChanges() {
    StoreData.listen<UserModel>(
      StoreKey.userData,
      (value) => user.value = value,
      fromJson: UserModel.fromJson,
    );
  }
}
