import 'package:device_meta/device_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceMeta', () {
    group('Singleton', () {
      test('instance returns the same object', () {
        final instance1 = DeviceMeta.instance;
        final instance2 = DeviceMeta.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('fromJson', () {
      test('parses all device properties correctly', () {
        final deviceMeta = DeviceMeta.instance;
        final jsonData = {
          'name': 'Test Device',
          'model': 'Model X',
          'brand': 'TestBrand',
          'manufacturer': 'TestManufacturer',
          'version': '1.0.0',
          'uuid': 'abc123-uuid',
          'platform_type': 'android',
          'user_agent': 'TestAgent/1.0',
          'country_code': 'US',
        };

        deviceMeta.fromJson(jsonData);

        expect(deviceMeta.name, equals('Test Device'));
        expect(deviceMeta.model, equals('Model X'));
        expect(deviceMeta.brand, equals('TestBrand'));
        expect(deviceMeta.manufacturer, equals('TestManufacturer'));
        expect(deviceMeta.version, equals('1.0.0'));
        expect(deviceMeta.uuid, equals('abc123-uuid'));
        expect(deviceMeta.platformType, equals('android'));
        expect(deviceMeta.userAgent, equals('TestAgent/1.0'));
        expect(deviceMeta.countryCode, equals('US'));
      });

      test('handles null values gracefully', () {
        final deviceMeta = DeviceMeta.instance;
        final jsonData = <String, dynamic>{};

        deviceMeta.fromJson(jsonData);

        expect(deviceMeta.name, isNull);
        expect(deviceMeta.model, isNull);
        expect(deviceMeta.brand, isNull);
        expect(deviceMeta.manufacturer, isNull);
        expect(deviceMeta.version, isNull);
        expect(deviceMeta.uuid, isNull);
        expect(deviceMeta.platformType, isNull);
        expect(deviceMeta.userAgent, isNull);
        expect(deviceMeta.countryCode, isNull);
      });

      test('extracts custom metadata excluding reserved keys', () {
        final deviceMeta = DeviceMeta.instance;
        final jsonData = {
          'name': 'Test Device',
          'model': 'Model X',
          'brand': 'TestBrand',
          'manufacturer': 'TestManufacturer',
          'version': '1.0.0',
          'uuid': 'abc123-uuid',
          'platform_type': 'android',
          'user_agent': 'TestAgent/1.0',
          'country_code': 'US',
          'custom_field': 'custom_value',
          'another_field': 123,
          'nested_data': {'key': 'value'},
        };

        deviceMeta.fromJson(jsonData);

        expect(deviceMeta.metaData, isNotEmpty);
        expect(deviceMeta.metaData['custom_field'], equals('custom_value'));
        expect(deviceMeta.metaData['another_field'], equals(123));
        expect(deviceMeta.metaData['nested_data'], equals({'key': 'value'}));

        // Reserved keys should NOT be in metaData
        expect(deviceMeta.metaData.containsKey('name'), isFalse);
        expect(deviceMeta.metaData.containsKey('model'), isFalse);
        expect(deviceMeta.metaData.containsKey('brand'), isFalse);
        expect(deviceMeta.metaData.containsKey('manufacturer'), isFalse);
        expect(deviceMeta.metaData.containsKey('version'), isFalse);
        expect(deviceMeta.metaData.containsKey('uuid'), isFalse);
        expect(deviceMeta.metaData.containsKey('platform_type'), isFalse);
        expect(deviceMeta.metaData.containsKey('user_agent'), isFalse);
        expect(deviceMeta.metaData.containsKey('country_code'), isFalse);
      });
    });

    group('toJson', () {
      test('serializes all device properties correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'name': 'Test Device',
          'model': 'Model X',
          'brand': 'TestBrand',
          'manufacturer': 'TestManufacturer',
          'version': '1.0.0',
          'uuid': 'abc123-uuid',
          'platform_type': 'ios',
          'user_agent': 'Safari/1.0',
          'country_code': 'GB',
        });

        final json = deviceMeta.toJson();

        expect(json['name'], equals('Test Device'));
        expect(json['model'], equals('Model X'));
        expect(json['brand'], equals('TestBrand'));
        expect(json['manufacturer'], equals('TestManufacturer'));
        expect(json['version'], equals('1.0.0'));
        expect(json['uuid'], equals('abc123-uuid'));
        expect(json['platform_type'], equals('ios'));
        expect(json['user_agent'], equals('Safari/1.0'));
        expect(json['country_code'], equals('GB'));
      });

      test('includes custom metadata in output', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'name': 'Test Device',
          'model': 'Model X',
          'brand': 'TestBrand',
          'manufacturer': 'TestManufacturer',
          'version': '1.0.0',
          'uuid': 'abc123-uuid',
          'platform_type': 'android',
          'user_agent': null,
          'country_code': 'US',
          'app_version': '2.0.0',
          'user_id': 'user_12345',
        });

        final json = deviceMeta.toJson();

        expect(json['app_version'], equals('2.0.0'));
        expect(json['user_id'], equals('user_12345'));
      });

      test('handles null values in output', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson(<String, dynamic>{});

        final json = deviceMeta.toJson();

        expect(json.containsKey('name'), isTrue);
        expect(json.containsKey('model'), isTrue);
        expect(json.containsKey('brand'), isTrue);
        expect(json.containsKey('manufacturer'), isTrue);
        expect(json.containsKey('version'), isTrue);
        expect(json.containsKey('uuid'), isTrue);
        expect(json.containsKey('platform_type'), isTrue);
        expect(json.containsKey('user_agent'), isTrue);
        expect(json.containsKey('country_code'), isTrue);
      });
    });

    group('fromJson and toJson roundtrip', () {
      test('data survives serialization roundtrip', () {
        final deviceMeta = DeviceMeta.instance;
        final originalData = {
          'name': 'Roundtrip Device',
          'model': 'RT-100',
          'brand': 'RoundTrip',
          'manufacturer': 'RoundTrip Inc',
          'version': '3.2.1',
          'uuid': 'roundtrip-uuid-123',
          'platform_type': 'web',
          'user_agent': 'Mozilla/5.0',
          'country_code': 'DE',
          'custom_meta': 'preserved',
        };

        deviceMeta.fromJson(originalData);
        final json = deviceMeta.toJson();

        expect(json['name'], equals(originalData['name']));
        expect(json['model'], equals(originalData['model']));
        expect(json['brand'], equals(originalData['brand']));
        expect(json['manufacturer'], equals(originalData['manufacturer']));
        expect(json['version'], equals(originalData['version']));
        expect(json['uuid'], equals(originalData['uuid']));
        expect(json['platform_type'], equals(originalData['platform_type']));
        expect(json['user_agent'], equals(originalData['user_agent']));
        expect(json['country_code'], equals(originalData['country_code']));
        expect(json['custom_meta'], equals(originalData['custom_meta']));
      });
    });

    group('getMetaData', () {
      test('returns value for existing key', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'custom_string': 'hello',
          'custom_int': 42,
          'custom_bool': true,
          'custom_list': [1, 2, 3],
          'custom_map': {'nested': 'value'},
        });

        expect(
            deviceMeta.getMetaData<String>('custom_string'), equals('hello'));
        expect(deviceMeta.getMetaData<int>('custom_int'), equals(42));
        expect(deviceMeta.getMetaData<bool>('custom_bool'), equals(true));
        expect(deviceMeta.getMetaData<List>('custom_list'), equals([1, 2, 3]));
        expect(deviceMeta.getMetaData<Map>('custom_map'),
            equals({'nested': 'value'}));
      });

      test('returns null for non-existing key', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'existing_key': 'value'});

        expect(deviceMeta.getMetaData<String>('non_existing_key'), isNull);
      });

      test('returns null when metaData is empty', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson(<String, dynamic>{});

        expect(deviceMeta.getMetaData<String>('any_key'), isNull);
      });

      test('does not return reserved keys via getMetaData', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'name': 'Device Name',
          'model': 'Model',
          'brand': 'Brand',
          'manufacturer': 'Manufacturer',
          'version': '1.0',
          'uuid': 'uuid-123',
          'platform_type': 'android',
          'user_agent': 'Agent',
          'country_code': 'US',
        });

        // Reserved keys should not be accessible via getMetaData
        expect(deviceMeta.getMetaData<String>('name'), isNull);
        expect(deviceMeta.getMetaData<String>('model'), isNull);
        expect(deviceMeta.getMetaData<String>('brand'), isNull);
        expect(deviceMeta.getMetaData<String>('manufacturer'), isNull);
        expect(deviceMeta.getMetaData<String>('version'), isNull);
        expect(deviceMeta.getMetaData<String>('uuid'), isNull);
        expect(deviceMeta.getMetaData<String>('platform_type'), isNull);
        expect(deviceMeta.getMetaData<String>('user_agent'), isNull);
        expect(deviceMeta.getMetaData<String>('country_code'), isNull);
      });
    });

    group('Reserved keys', () {
      test('all reserved keys are properly filtered from metaData', () {
        final deviceMeta = DeviceMeta.instance;
        final reservedKeys = [
          'name',
          'model',
          'brand',
          'manufacturer',
          'version',
          'uuid',
          'platform_type',
          'user_agent',
          'country_code',
        ];

        final jsonData = <String, dynamic>{};
        for (final key in reservedKeys) {
          jsonData[key] = 'value_for_$key';
        }
        jsonData['custom_key'] = 'custom_value';

        deviceMeta.fromJson(jsonData);

        for (final key in reservedKeys) {
          expect(deviceMeta.metaData.containsKey(key), isFalse,
              reason: 'Reserved key "$key" should not be in metaData');
        }
        expect(deviceMeta.metaData['custom_key'], equals('custom_value'));
      });
    });

    group('metaData property', () {
      test('can be directly modified', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson(<String, dynamic>{});

        deviceMeta.metaData['new_key'] = 'new_value';

        expect(deviceMeta.metaData['new_key'], equals('new_value'));
      });

      test('direct modifications appear in toJson output', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson(<String, dynamic>{});

        deviceMeta.metaData['added_key'] = 'added_value';

        final json = deviceMeta.toJson();
        expect(json['added_key'], equals('added_value'));
      });
    });

    group('Platform type values', () {
      test('android platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'android'});

        expect(deviceMeta.platformType, equals('android'));
      });

      test('ios platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'ios'});

        expect(deviceMeta.platformType, equals('ios'));
      });

      test('web platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'web'});

        expect(deviceMeta.platformType, equals('web'));
      });

      test('macos platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'macos'});

        expect(deviceMeta.platformType, equals('macos'));
      });

      test('windows platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'windows'});

        expect(deviceMeta.platformType, equals('windows'));
      });

      test('linux platform type is parsed correctly', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({'platform_type': 'linux'});

        expect(deviceMeta.platformType, equals('linux'));
      });
    });

    group('Edge cases', () {
      test('handles special characters in values', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'name': 'Device™ with émojis 🎉',
          'model': 'Model "Special" <Edition>',
          'brand': "Brand's & Co.",
        });

        expect(deviceMeta.name, equals('Device™ with émojis 🎉'));
        expect(deviceMeta.model, equals('Model "Special" <Edition>'));
        expect(deviceMeta.brand, equals("Brand's & Co."));
      });

      test('handles empty string values', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'name': '',
          'model': '',
          'brand': '',
        });

        expect(deviceMeta.name, equals(''));
        expect(deviceMeta.model, equals(''));
        expect(deviceMeta.brand, equals(''));
      });

      test('handles very long string values', () {
        final deviceMeta = DeviceMeta.instance;
        final longString = 'a' * 10000;
        deviceMeta.fromJson({
          'name': longString,
        });

        expect(deviceMeta.name, equals(longString));
        expect(deviceMeta.name!.length, equals(10000));
      });

      test('handles numeric string values', () {
        final deviceMeta = DeviceMeta.instance;
        deviceMeta.fromJson({
          'version': '123',
          'custom_number': 456,
        });

        expect(deviceMeta.version, equals('123'));
        expect(deviceMeta.getMetaData<int>('custom_number'), equals(456));
      });
    });
  });
}
