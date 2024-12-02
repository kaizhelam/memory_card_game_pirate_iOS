import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:memory_card_game/homeWidget/web_screen.dart';
import 'package:memory_card_game/gameWidget/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String? url;

  @override
  void initState() {
    super.initState();

    // Lock orientation to portrait when this screen is displayed
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    fetchIsOn();
  }

  @override
  void dispose() {
    // Unlock orientation when leaving this screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> fetchIsOn() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://6703907dab8a8f892730a6d2.mockapi.io/api/v1/memorycardgame'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final bool isOn = data[0]['is_on'] ?? false;
          final String urlLink = data[0]['url'] ?? '';

          log("isOn : $isOn");

          if (isOn && await isValidUrl(urlLink)) {
            url = urlLink;
          } else {
            url = "";
          }
        }
      } else {
        url = "";
      }
    } catch (e) {
      url = "";
    }

    setState(() {});
  }

  Future<bool> isValidUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !['http', 'https'].contains(uri.scheme)) {
        return false;
      }

      final response = await http.get(uri);
      return response.statusCode == 200;
    } on TimeoutException {
      return false;
    } on Exception {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: url == null
            ? Center(
                child: Container(
                  width: 150,
                  height: 150,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset("assets/images/logo.png"),
                ),
              )
            : url!.isEmpty
                ? const MenuScreen()
                : WebViewScreen(
                    backgroundColor: Colors.black,
                    url: url!,
                  ),
      ),
    );
  }
}
