class UserModel {
  String? name;
  String? lastName;
  String? email;
  String? countryCode;
  String? mobile;
  String? deviceId;
  String? deviceType;
  String? deviceToken;
  String? lang;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? guestId;
  String? token;
  String? profilePic;

  UserModel({
    this.name,
    this.lastName,
    this.email,
    this.countryCode,
    this.mobile,
    this.deviceId,
    this.deviceType,
    this.deviceToken,
    this.lang,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.guestId,
    this.token,
    this.profilePic,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lastName = json['last_name'];
    email = json['email'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
    deviceId = json['device_id'];
    deviceType = json['device_type'];
    deviceToken = json['device_token'];
    lang = json['lang'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    guestId = json['guest_id'];
    token = json['token'];
    profilePic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['last_name'] = lastName;
    data['email'] = email;
    data['country_code'] = countryCode;
    data['mobile'] = mobile;
    data['device_id'] = deviceId;
    data['device_type'] = deviceType;
    data['device_token'] = deviceToken;
    data['lang'] = lang;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['guest_id'] = guestId;
    data['token'] = token;
    data['profile_pic'] = profilePic;
    return data;
  }
}
