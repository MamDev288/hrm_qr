import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:base32/base32.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
Random _rnd = Random();
String hashJson = "";
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
Map<String, dynamic> mapData = {};
Future<void> setData() async {
  var prefs = await SharedPreferences.getInstance();
  String secret = prefs.getString("secret") ?? "";
  if (secret == "") {
    String key = getRandomString(20);
    secret = base32.encodeString(key);
    prefs.setString('secret', secret);
  }
  mapData = {
    "deviceName": await _getName(),
    "scerect": secret,
    "uniqId": await _getId()
  };
  final bytes = utf8.encode(jsonEncode(mapData));
  hashJson = base64.encode(bytes);
  print(hashJson);
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    setData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CONNECT DEVICE'.toUpperCase())),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrettyQr(
              // image: AssetImage('images/twitter.png'),
              typeNumber: 10,
              size: 300,
              data: hashJson,
              errorCorrectLevel: QrErrorCorrectLevel.M,
              roundEdges: true,
            ),
            Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  'Vui lòng liên hệ HR đăng kí & cập nhật thiết bị trước khi sử dụng',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}

Future<String?> _getName() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.utsname.machine; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.model; // unique ID on Android
  }
}
