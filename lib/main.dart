import 'dart:async';
import 'dart:ui';

import 'package:HFSPL/firebase_options.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:HFSPL/splash_screen.dart';
import 'package:HFSPL/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/my_home_page.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'utils/local_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // print("WidgetsFlutterBinding.ensureInitialized()");
 
  
  runApp(const MyApp());

  // print("runApp(const MyApp())");
  // Position position = await LocationUtil.getCurrentLocation();

}

//Required for iOS background tasks
//@pragma('vm:entry-point')
// bool onIosBackground(ServiceInstance service) {
//   return true;
// }


// Future<void> showNotification(
//     FlutterLocalNotificationsPlugin notificationsPlugin, Position position) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     notificationChannelId,
//     'Location Updates',
//     channelDescription: 'Tracks your location in background',
//     importance: Importance.high,
//     priority: Priority.high,
//   //  ticker: 'ticker',
//     icon: 'ic_bg_service_small',
//     ongoing: true
//   );

//   const NotificationDetails notificationDetails =
//       NotificationDetails(android: androidDetails);

//   await notificationsPlugin.show(
//     notificationId,
//     'Location Update',
//     'Lat: ${position.latitude}, Long: ${position.longitude}',
//     notificationDetails,
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to check if the user is logged in
  Future<bool> isLoggedIn() async {
 // Position position = await getCurrentLocation();

  await SharedPreferencesHelper.init();
  var prefs = SharedPreferencesHelper();

  var isLoggedIn = prefs.getBool('isLoggedIn', defaultValue: false);
  if (!isLoggedIn) return false;

  // Retrieve token and expiration time
  Global_token = prefs.getString('token', defaultValue: '');
  String expirationTimeStr = prefs.getString('token_expiry', defaultValue: '');

  if (expirationTimeStr.isEmpty) {
    return false;
  }

  // Parse the expiration time
  DateTime expirationTime = DateTime.parse(expirationTimeStr);
  DateTime currentTime = DateTime.now();

  // Check if the token is expired
  if (currentTime.isAfter(expirationTime)) {
    prefs.setBool('isLoggedIn', false);  // Clear login state
    prefs.setString('token', '');        // Clear token
    prefs.setString('token_expiry', ''); // Clear expiry
    return false;
  }

  // If token is still valid, load user details
  Global_uid = prefs.getString('id', defaultValue: '');
  Global_designationName = prefs.getString('designationName', defaultValue: '');
  Global_name = prefs.getString('name', defaultValue: '');
  Global_LoginId = prefs.getString('loginId', defaultValue: '');
  Global_Password = prefs.getString('password', defaultValue: '');

  IsGRTEnable = prefs.getBool('IsGRTEnable', defaultValue: false);
  IsFE = prefs.getString('IsFE', defaultValue: '0') == '1'; // true if '1', else false
  CanDoGRT = prefs.getBool('CanDoGRT', defaultValue: false);

  // print("designationName: $Global_designationName");

  // print("GLoabal_uid: $Global_uid");
  // print("GLoabal_designationName: $Global_designationName");
  // print("GLoabal_name: $Global_name");
  // print("GLoabal_LoginId: $Global_LoginId");
  // print("GLoabal_Password: $Global_Password");
  
  // print("GRT main page: $IsGRTEnable");
  Global_uid = "1262";
  return true;
}


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
        
        overlayWidgetBuilder: (_) { //ignored progress for the moment
          return const Center(
            child: SpinKitRotatingCircle(
              color: Colors.red,
              size: 50.0,
            ),
          );
        },
      child: MaterialApp(
        title: 'HFSPL',
        theme: updatedTheme,
        home: const SplashScreen(),
        
      ),
    );
  }
}
