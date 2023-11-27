import 'package:flutter/material.dart';
import 'package:device_meta/device_meta.dart';

void main() async {
  DeviceMeta deviceMeta = await DeviceMeta.init(storageKey: "storageKey2");
  print(['deviceMeta.toJson', deviceMeta.toJson()]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This is a simple example of how to use device meta.
  @override
  Widget build(BuildContext context) {
    DeviceMeta deviceMeta = DeviceMeta.instance;
    return Scaffold(
      appBar: AppBar(title: Text("Device Meta")),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text("Device meta",
                  style: Theme.of(context).textTheme.displaySmall),
              Divider(),
              Text("Model: ${deviceMeta.model}"),
              Text("Version: ${deviceMeta.version}"),
              Text("Brand: ${deviceMeta.brand}"),
              Text("Manufacturer: ${deviceMeta.manufacturer}"),
              Text("Platform Type: ${deviceMeta.platformType}"),
              Text("UUID: ${deviceMeta.uuid}"),
              Text("UserAgent: ${deviceMeta.userAgent}"),
              Text("toJson: ${DeviceMeta.instance.toJson().toString()}"),
            ],
          ),
        ),
      ),
    );
  }
}
