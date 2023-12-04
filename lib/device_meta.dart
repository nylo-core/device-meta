library device_meta;

import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';

/// DeviceMeta - Model for the device meta
class DeviceMeta {
  DeviceMeta._privateConstructor();

  static final DeviceMeta instance = DeviceMeta._privateConstructor();

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
  fromJson(Map<String, dynamic> data) {
    name = data['name'];
    model = data['model'];
    brand = data['brand'];
    manufacturer = data['manufacturer'];
    version = data['version'];
    uuid = data['uuid'];
    platformType = data['platform_type'];
    userAgent = data['user_agent'];
    countryCode = data['country_code'];
    metaData = data.entries.where((info) {
      return ![
        'name',
        'model',
        'brand',
        'manufacturer',
        'version',
        'uuid',
        'platform_type',
        'user_agent',
        'country_code'
      ].contains(info.key);
    }).toMap();
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
      "user_agent": userAgent
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

    String? uuid = await getUUID(storageKey);

    String? countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;

    if (UniversalPlatform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceMeta = {
        "name": androidDeviceInfo.device,
        "model": androidDeviceInfo.model,
        "brand":
            androidDeviceInfo.brand.replaceAll(RegExp('[^\u0001-\u007F]'), '_'),
        "manufacturer": androidDeviceInfo.manufacturer,
        "version": androidDeviceInfo.version.sdkInt.toString(),
        "uuid": uuid,
        "platform_type": "android",
        "country_code": countryCode
      };
    }

    if (UniversalPlatform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceMeta = {
        "name": iosDeviceInfo.name.replaceAll(RegExp('[^\u0001-\u007F]'), '_'),
        "model": iosDeviceInfo.model,
        "brand": "Apple",
        "manufacturer": "Apple",
        "version": iosDeviceInfo.systemVersion,
        "uuid": uuid,
        "platform_type": "ios",
        "country_code": countryCode
      };
    }

    if (UniversalPlatform.isWeb) {
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
}

/// Get the device uuid
Future<String?> getUUID(String storageKey) async {
  String? uuid = await NyStorage.read(storageKey);
  if (uuid == null) {
    String uuId = _buildUUID();
    await _storeUUID(uuId, storageKey);
    return uuId;
  }
  return uuid;
}

/// Store the device uuid
_storeUUID(String uuid, String storageKey) async {
  await NyStorage.store(storageKey, uuid);
}

/// Build the device uuid
String _buildUUID() {
  var uuid = const Uuid();
  String idD = uuid.v1();
  return "${idD}_${_randomStr(4)}";
}

/// Generate a random string
String _randomStr(int strLen) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < strLen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}
