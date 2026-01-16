import 'dart:ui';

import 'package:HFSPL/firebase_options.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

@pragma('vm:entry-point')
class LocationUtil {

static const String notificationChannelId = "location_channel";
static const int notificationId = 888;
Timer? myTimer;

  //   await createNotificationChannel();

  // await initializeService();
  // print("initializeService");

static void stopBackgroundService() {
 // DartPluginRegistrant.ensureInitialized();
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

// Service Entry Point
@pragma('vm:entry-point')
static void onStart(ServiceInstance service) async {
    print("@pragma('vm:entry-point')");

  DartPluginRegistrant.ensureInitialized();

    await SharedPreferencesHelper.init();
  var prefs = SharedPreferencesHelper();

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   print("Firebase.initializeApp");

  // if (service is AndroidServiceInstance) {
  //   service.setAsForegroundService();
  // }

  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {
     print("background process is now started");
  });


 // Initialize local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

   await flutterLocalNotificationsPlugin.initialize(initSettings);
  // if (myTimer?.isActive == true) {
  //   myTimer?.cancel();
  //   return;
  // }
 Timer.periodic(const Duration(minutes: 5), (timer) async {

    DateTime now = DateTime.now(); // Get current time
    DateTime targetTime = DateTime(now.year, now.month, now.day, 21, 30); // 21:30 today

    if (now.isAfter(targetTime)) {
      service.stopSelf();
      print("background process is now stopped");
      return;
    }
    Position position = await getCurrentLocation();
    var uid = prefs.getString('id', defaultValue: '');
   // print("timer hit:"+uid);
    await saveLocationToFirebase(uid,position);
    //await showNotification(flutterLocalNotificationsPlugin, position);
  });
}


// Initialize background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Check if service is already running
  if (await service.isRunning()) {
    return;
  }

  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
       notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
      initialNotificationTitle: 'HFSPL',
      initialNotificationContent: 'Active',
      foregroundServiceNotificationId: notificationId,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      onBackground: null,
      onForeground: null,
    ),
  );
  await service.startService();
  
}

Future<void> createNotificationChannel() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);


  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    notificationChannelId,
    'Location Updates',
    channelDescription: 'Tracks your location in background',
    importance: Importance.none,
    priority: Priority.min,
    //ticker: 'ticker',
    icon: 'ic_bg_service_small',
    ongoing: true
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Location Update',
    'Lat: , Long: ',
    notificationDetails,
  );

  initializeService();
}


// Get current location
static Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return Future.error('Location service disabled');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}



// Save location to Firebase
static Future<void> saveLocationToFirebase(String userId,Position position) async {


  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  var fmt  = DateFormat('dd-MMM-yyyy');
  String formattedDate = fmt.format(now);

  // print("FirebaseFirestore db = FirebaseFirestore.instance");

  Map<String, dynamic> locObj = {
    "lat": position.latitude,
    "lng": position.longitude,
    "time": now
  };

  await db.collection(userId)
      .doc(formattedDate)
      .update({
        "locations": FieldValue.arrayUnion([locObj])
      }).catchError((error) async {
        // If the document does not exist, create it first
        await db.collection(userId).doc(formattedDate).set({
          "locations": [locObj]
        });
      });

}
}

 Future<void> saveLoginToFirebase(String userId) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  var fmt = DateFormat('dd-MMM-yyyy');
  String formattedDate = fmt.format(now);

  DocumentReference docRef = db.collection(userId).doc(formattedDate);

  await docRef.set({
    "lastlogin": now,
    "logins": FieldValue.arrayUnion([now])
  }, SetOptions(merge: true));
}

 Future<void> saveLogoutToFirebase(String userId) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  var fmt = DateFormat('dd-MMM-yyyy');
  String formattedDate = fmt.format(now);

  DocumentReference docRef = db.collection(userId).doc(formattedDate);

  await docRef.set({
    "logouts": FieldValue.arrayUnion([now])
  }, SetOptions(merge: true));
}