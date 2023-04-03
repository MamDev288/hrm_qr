import 'dart:async';
import 'dart:convert';
import 'package:base32/base32.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:dart_dash_otp/dart_dash_otp.dart';
import 'package:qr_hrm_gen/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
}

const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  TOTP totp = TOTP(secret: "", interval: 60);
  Timer time = Timer(Duration(days: 1), () {});
  int? timeExp = 0;
  Map<String, dynamic> data = {};
  String? _otp;
  String hashJson = "";
  String dateTimeNow = "";
  Future<void> setData() async {
    var prefs = await SharedPreferences.getInstance();
    String secret = prefs.getString("secret") ?? "";
    if (secret == "") {
      String key = getRandomString(20);
      secret = base32.encodeString(key);
      prefs.setString('secret', secret);
    }
    totp = TOTP(secret: secret, interval: 60);
    await ScreenBrightness().setScreenBrightness(1);
    KeepScreenOn.turnOn();
  }

  void genKey() {
    DateTime dNow = DateTime.now();
    dateTimeNow =
        'Bây giờ là : ${dNow.hour}:${dNow.minute} ${dNow.day}/${dNow.month}/${dNow.year}';
    timeExp = totp.interval! - dNow.second;
    _otp = totp.now();
    data = {'devices': "1", 'otp': _otp};
    final bytes = utf8.encode(jsonEncode(data));
    hashJson = base64.encode(bytes);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setData();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    SystemChrome.setEnabledSystemUIOverlays([]);

    time = Timer.periodic(Duration(seconds: 1), (timer) => genKey());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('HRM PACIFIC generate security code'.toUpperCase())),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dateTimeNow, style: TextStyle(fontSize: 20)),
            PrettyQr(
              // image: AssetImage('images/twitter.png'),
              typeNumber: 5,
              size: 300,
              data: hashJson,
              errorCorrectLevel: QrErrorCorrectLevel.M,
              roundEdges: true,
            ),
            Text('Mã sẽ hết hạn sau ${timeExp.toString()}s',
                style: TextStyle(fontSize: 20)),
            TextButton(
              onPressed: () {
                final res = Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyWidget()),
                );
              },
              child: Text(
                'Mã QR không hợp lệ?',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// class MyApp extends StatefulWidget{
//   String _secret= '';
//   Future<void> setData() async {
//     var prefs = await SharedPreferences.getInstance();
//     String?  secret = prefs.getString("secret");
//     if(secret== null && secret!.isEmpty){
//       secret = getRandomString(16).toUpperCase();
//       prefs.setString('secret', secret);
//     }
//   }
//   @override
//   State<StatefulWidget> createState() {
//     return _MyApp();
//   }
// }
// const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
// Random _rnd = Random();
// String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
//     length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
// class _MyApp extends State<MyApp> {
//     _MyApp(){
//       this.totp = TOTP(secret:  widget._secret,interval: 60);
//     }
//     TOTP? totp = null;
//     int idDevice = 1;
//     Map<String,dynamic> data =  {};
//     int? TimeExp = 0;
//     void GenKey(){
     
//       TimeExp = totp!.interval! - DateTime.now().second;
//       _otp = totp!.now();
//        data = {
//         'idDevice':idDevice,
//         'key':_otp
//       };
//       setState(() {
//       });
//     }
//     GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
//     String _otp = '';
//     @override
//     void initState() {
//       super.initState();
//       Timer.periodic(Duration(seconds: 1), (timer) => GenKey());
//     }
//     @override
//     Widget build(BuildContext context) {
//       TimeExp = totp!.interval! - DateTime.now().second;
//       GenKey();
//       return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('HRM PACIFIC generate security code'.toUpperCase())),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               PrettyQr(
//                 // image: AssetImage('images/twitter.png'),
//                 typeNumber: 5,
//                 size: 300,
//                 data: jsonEncode(data),
//                 errorCorrectLevel: QrErrorCorrectLevel.M,
//                 roundEdges: true,
//               ),
//               Text('Reset in ${TimeExp.toString()}s',style: TextStyle(fontSize: 20)),
//             ],
//           ),
//         ),
//       ),
      
//     );
//     }
//   }