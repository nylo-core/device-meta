# Device Meta

[![pub package](https://img.shields.io/pub/v/device_meta.svg)](https://pub.dartlang.org/packages/device_meta)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Handle device info in Flutter. 

This package will allow you to get the device name, model, brand, manufacturer, uuid, version, platform type and user agent.

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

``` yaml
dependencies:
  device_meta: ^1.1.22
```

or with Dart:

``` bash
dart pub add device_meta
```

### Usage

``` dart
import 'package:device_meta/device_meta.dart';

DeviceMeta deviceMeta = await DeviceMeta.init(storageKey: "exampleapp");

deviceMeta.name // iPhone
deviceMeta.model // iPhone 15 Pro
deviceMeta.brand // Apple
deviceMeta.uuid // 00000000-0000-0000-0000-000000000000
deviceMeta.version // 1.0.0
deviceMeta.platformType // iOS
deviceMeta.toJson() // { "model": "iPhone", "brand": "Apple", "manufacturer": "Apple", "uuid": "00000000-0000-0000-0000-000000000000", "version": "1.0.0", "platformType": "iOS", "userAgent": "n/a" }
```

You can also attach `metaData` to the object:

``` dart
DeviceMeta deviceMeta = await DeviceMeta.init(
    storageKey: "exampleapp",
    metaData: {
        "user_id": 1,
        "app_version": "1.0.0"
    }
);

deviceMeta.metaData; // { "user_id": 1, "app_version": "1.0.0"}
```

Get a specific meta data value

``` dart
deviceMeta.getMetaData("app_version"); // "1.0.0"

deviceMeta.getMetaData("user_id") // 1
```

Try the [example](/example) app to see how it works.

## Changelog
Please see [CHANGELOG](https://github.com/nylo-core/device_meta/blob/master/CHANGELOG.md) for more information what has changed recently.

## Social
* [Twitter](https://twitter.com/nylo_dev)

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/device_meta/blob/main/LICENSE) File for more information.
