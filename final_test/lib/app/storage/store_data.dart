import '../utils/import.dart';

class StoreData {
  static final GetStorage _box = GetStorage();

  StoreData._();

  static Future<void> init() async {
    await GetStorage.init();
    kLog(content: 'GetStorage initialized', title: 'INIT');
  }

  static Future<void> setData(String key, dynamic value) async {
    final encoded = _encodeValue(value);
    Map<String, String>? encryptedMap;

    final rawValue = _box.read(key);
    bool needsEncrypt = true;

    if (rawValue is Map<String, dynamic> &&
        rawValue.containsKey('iv') &&
        rawValue.containsKey('encrypted')) {
      final decrypted = _decodeValue(
        CryptoHelper.decryptGCM(
          encryptedText: rawValue['encrypted'],
          ivBase64: rawValue['iv'],
        ),
      );
      if (decrypted == value) needsEncrypt = false;
    }

    if (needsEncrypt) {
      encryptedMap = CryptoHelper.encryptGCM(encoded);
      await _box.write(key, encryptedMap);
    } else {
      encryptedMap = Map<String, String>.from(rawValue);
    }

    final decryptedValue = _decodeValue(
      CryptoHelper.decryptGCM(
        encryptedText: encryptedMap['encrypted']!,
        ivBase64: encryptedMap['iv']!,
      ),
    );

    kLog(content: encryptedMap, title: _logTitle('STORED_ENCRYPTED', key));
    kLog(content: decryptedValue, title: _logTitle('STORED_DECRYPTED', key));
  }

  static T? readData<T>(String key) {
    final rawValue = _box.read(key);
    if (rawValue == null) return null;

    dynamic value;
    Map<String, String>? encryptedMap;

    if (rawValue is Map<String, dynamic> &&
        rawValue.containsKey('iv') &&
        rawValue.containsKey('encrypted')) {
      value = _decodeValue(
        CryptoHelper.decryptGCM(
          encryptedText: rawValue['encrypted'],
          ivBase64: rawValue['iv'],
        ),
      );
      encryptedMap = Map<String, String>.from(rawValue);
    } else {
      encryptedMap = CryptoHelper.encryptGCM(_encodeValue(rawValue));
      _box.write(key, encryptedMap);
      value = _decodeValue(
        CryptoHelper.decryptGCM(
          encryptedText: encryptedMap['encrypted']!,
          ivBase64: encryptedMap['iv']!,
        ),
      );
      kLog(content: encryptedMap, title: _logTitle('AUTO_ENCRYPTED', key));
    }

    final castValue = _castTo<T>(value);

    kLog(content: encryptedMap, title: _logTitle('READ_ENCRYPTED', key));
    kLog(content: castValue, title: _logTitle('READ_DECRYPTED', key));

    return castValue;
  }

  static void listen<T>(
    String key,
    void Function(T? value) callback, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    _box.listenKey(key, (rawValue) {
      if (rawValue == null) {
        callback(null);
        return;
      }

      dynamic value;
      if (rawValue is Map<String, dynamic> &&
          rawValue.containsKey('iv') &&
          rawValue.containsKey('encrypted')) {
        value = _decodeValue(
          CryptoHelper.decryptGCM(
            encryptedText: rawValue['encrypted'],
            ivBase64: rawValue['iv'],
          ),
        );
      } else {
        final encrypted = CryptoHelper.encryptGCM(_encodeValue(rawValue));
        _box.write(key, encrypted);
        value = _decodeValue(
          CryptoHelper.decryptGCM(
            encryptedText: encrypted['encrypted']!,
            ivBase64: encrypted['iv']!,
          ),
        );
      }

      T? result;
      if (fromJson != null && value is Map<String, dynamic>) {
        result = fromJson(value);
      } else {
        result = _castTo<T>(value);
      }

      callback(result);
    });
  }

  static Future<void> removeData(String key) async {
    await _box.remove(key);
    kLog(content: 'Removed data for key: ${_formatKey(key)}', title: 'REMOVE');
  }

  static Future<void> clear() async {
    await _box.erase();
    kLog(content: 'Cleared all data', title: 'CLEAN');
  }

  static String _formatKey(String key) {
    final regex = RegExp(r'(?<=[a-z0-9])([A-Z])');
    return key.replaceAllMapped(regex, (m) => '_${m.group(0)}').toUpperCase();
  }

  static String _logTitle(String action, String key) {
    return '${action.replaceAll(' ', '_').toUpperCase()}: ${_formatKey(key)}';
  }

  static String _encodeValue(dynamic value) {
    if (value is String || value is num || value is bool) {
      return value.toString();
    }
    return jsonEncode(value);
  }

  static dynamic _decodeValue(String decrypted) {
    try {
      return jsonDecode(decrypted);
    } catch (_) {
      if (decrypted == 'true') return true;
      if (decrypted == 'false') return false;
      final numValue = num.tryParse(decrypted);
      return numValue ?? decrypted;
    }
  }

  static T? _castTo<T>(dynamic value) {
    if (value is T) return value;
    try {
      return value as T;
    } catch (_) {
      return null;
    }
  }
}
