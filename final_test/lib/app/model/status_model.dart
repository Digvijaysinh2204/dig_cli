class StatusModel<T> {
  final int? statusCode;
  final String? message;
  final T? data;

  StatusModel({this.statusCode, this.message, this.data});

  factory StatusModel.fromJson(
    Map<String, dynamic> json, [
    T Function(Map<String, dynamic> json)? fromJsonT,
  ]) {
    final rawData = json['data'];
    T? parsedData;

    if (rawData == null) {
      parsedData = null;
    } else if (rawData is Map<String, dynamic> && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData is List && fromJsonT != null) {
      parsedData = rawData.map((e) => fromJsonT(e)).toList() as T;
    } else {
      parsedData = rawData as T?;
    }

    return StatusModel<T>(
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson([
    Map<String, dynamic> Function(T value)? toJsonT,
  ]) {
    final rawData = data;
    Object? jsonData;

    if (rawData == null) {
      jsonData = null;
    } else if (rawData is List && toJsonT != null) {
      jsonData = rawData.map((e) => toJsonT(e)).toList();
    } else if (toJsonT != null) {
      jsonData = toJsonT(rawData);
    } else {
      jsonData = rawData;
    }

    return {'statusCode': statusCode, 'message': message, 'data': jsonData};
  }
}
