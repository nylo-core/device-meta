import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';

/// DeviceMeta - Model for the device meta
class DeviceMeta {
  DeviceMeta._privateConstructor();

  static final DeviceMeta instance = DeviceMeta._privateConstructor();

  /// Secure storage instance for UUID persistence
  static const _storage = FlutterSecureStorage();

  /// Regex to remove non-ASCII characters
  static final _nonAsciiRegex = RegExp('[^\u0001-\u007F]');

  /// Reserved keys for device meta properties
  static const _reservedKeys = [
    'name',
    'model',
    'brand',
    'manufacturer',
    'version',
    'uuid',
    'platform_type',
    'user_agent',
    'country_code'
  ];

  String? name;
  String? model;
  String? brand;
  String? manufacturer;
  String? version;
  String? uuid;
  String? platformType;
  Map<String, dynamic> metaData = {};
  String? userAgent;
  String? countryCode;

  /// Initialize the device meta
  static Future<DeviceMeta> init(
      {required String storageKey,
      Map<String, dynamic> metaData = const {}}) async {
    dynamic data = await getData(
        storageKey: "device_meta_$storageKey", metaData: metaData);
    DeviceMeta deviceMeta = DeviceMeta.instance;
    deviceMeta.fromJson(data);
    return deviceMeta;
  }

  /// Set the device meta from a [data] json map
  void fromJson(Map<String, dynamic> data) {
    name = data['name'];
    model = data['model'];
    brand = data['brand'];
    manufacturer = data['manufacturer'];
    version = data['version'];
    uuid = data['uuid'];
    platformType = data['platform_type'];
    userAgent = data['user_agent'];
    countryCode = data['country_code'];
    metaData = Map.fromEntries(data.entries.where((info) {
      return !_reservedKeys.contains(info.key);
    }));
  }

  /// to json map
  Map<String, dynamic> toJson() {
    Map<String, dynamic> deviceMeta = {
      "name": name,
      "model": model,
      "brand": brand,
      "manufacturer": manufacturer,
      "version": version,
      "uuid": uuid,
      "platform_type": platformType,
      "user_agent": userAgent,
      "country_code": countryCode
    };

    deviceMeta.addAll(metaData);

    return deviceMeta;
  }

  /// Get the device meta
  static Future<Map<String, dynamic>> getData(
      {String storageKey = "device_meta",
      Map<String, dynamic> metaData = const {}}) async {
    Map<String, dynamic> deviceMeta = {};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String? uuid = await _getUUID(storageKey);

    String? countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;

    if (UniversalPlatform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceMeta = {
        "name": androidDeviceInfo.device,
        "model": androidDeviceInfo.model,
        "brand": androidDeviceInfo.brand.replaceAll(_nonAsciiRegex, '_'),
        "manufacturer": androidDeviceInfo.manufacturer,
        "version": androidDeviceInfo.version.sdkInt.toString(),
        "uuid": uuid,
        "platform_type": "android",
        "country_code": countryCode
      };
    } else if (UniversalPlatform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceMeta = {
        "name": iosDeviceInfo.name.replaceAll(_nonAsciiRegex, '_'),
        "model": iosDeviceInfo.modelName.replaceAll(_nonAsciiRegex, '_'),
        "brand": "Apple",
        "manufacturer": "Apple",
        "version": iosDeviceInfo.systemVersion,
        "uuid": uuid,
        "platform_type": "ios",
        "country_code": countryCode
      };
    } else if (UniversalPlatform.isWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

      deviceMeta = {
        "name": webBrowserInfo.appName,
        "model": webBrowserInfo.browserName.name,
        "brand": webBrowserInfo.vendor,
        "manufacturer": "n/a",
        "version": "n/a",
        "uuid": uuid,
        "user_agent": webBrowserInfo.userAgent,
        "platform_type": "web",
        "country_code": countryCode
      };
    } else if (UniversalPlatform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      deviceMeta = {
        "name": macOsDeviceInfo.computerName,
        "model": macOsDeviceInfo.model,
        "brand": "Apple",
        "manufacturer": "Apple",
        "version": macOsDeviceInfo.osRelease,
        "uuid": uuid,
        "platform_type": "macos",
        "country_code": countryCode
      };
    } else if (UniversalPlatform.isWindows) {
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      deviceMeta = {
        "name": windowsDeviceInfo.computerName,
        "model": windowsDeviceInfo.productName,
        "brand": "Microsoft",
        "manufacturer": "n/a",
        "version": windowsDeviceInfo.displayVersion,
        "uuid": uuid,
        "platform_type": "windows",
        "country_code": countryCode
      };
    } else if (UniversalPlatform.isLinux) {
      LinuxDeviceInfo linuxDeviceInfo = await deviceInfo.linuxInfo;
      deviceMeta = {
        "name": linuxDeviceInfo.name,
        "model": linuxDeviceInfo.prettyName,
        "brand": "n/a",
        "manufacturer": "n/a",
        "version": linuxDeviceInfo.version ?? "n/a",
        "uuid": uuid,
        "platform_type": "linux",
        "country_code": countryCode
      };
    }

    deviceMeta.addAll(metaData);

    return deviceMeta;
  }

  /// Get a [key] from device meta
  T? getMetaData<T>(String key) {
    if (!metaData.containsKey(key)) {
      return null;
    }
    return metaData[key];
  }

  /// Get the device uuid
  static Future<String?> _getUUID(String storageKey) async {
    String? uuid = await _storage.read(key: storageKey);
    if (uuid == null) {
      String newUuid = _buildUUID();
      await _storeUUID(newUuid, storageKey);
      return newUuid;
    }
    return uuid;
  }

  /// Store the device uuid
  static Future<void> _storeUUID(String uuid, String storageKey) async {
    await _storage.write(key: storageKey, value: uuid);
  }

  /// Build the device uuid
  static String _buildUUID() {
    var uuid = const Uuid();
    String id = uuid.v1();
    return "${id}_${_randomStr(4)}";
  }

  /// Generate a random string
  static String _randomStr(int strLen) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = Random.secure();
    StringBuffer result = StringBuffer();
    for (var i = 0; i < strLen; i++) {
      result.write(chars[rnd.nextInt(chars.length)]);
    }
    return result.toString();
  }
}
