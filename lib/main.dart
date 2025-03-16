import 'package:aarohan_app/firebase_options.dart';
import 'package:aarohan_app/models/event.dart';
import 'package:aarohan_app/resources/firestore_provider.dart';
import 'package:aarohan_app/screens/dashboard.dart';
import 'package:aarohan_app/screens/login.dart';
import 'package:aarohan_app/screens/splash.dart';
import 'package:aarohan_app/services/firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:aarohan_app/screens/event_screen.dart';
import 'package:aarohan_app/models/schedule.dart';
import 'package:aarohan_app/screens/timeline.dart';
import 'package:aarohan_app/screens/about_us.dart';
import 'package:aarohan_app/screens/leaderboard.dart';
import 'package:aarohan_app/screens/contributors.dart';
import 'package:aarohan_app/models/contributor.dart';
import 'package:aarohan_app/models/sponsor.dart';
import 'package:aarohan_app/screens/sponsors.dart';
import 'package:aarohan_app/screens/transaction.dart';
import 'package:aarohan_app/screens/eurekoin_home.dart';
import 'package:aarohan_app/models/contact_us.dart';
import 'package:aarohan_app/screens/contact.dart';
import 'package:aarohan_app/screens/coming_soon.dart';
import 'package:aarohan_app/models/coming_soon.dart';
import 'package:aarohan_app/screens/prelims.dart';
import 'package:aarohan_app/models/prelim.dart';
import 'package:flutter/services.dart';

// Plugin and Initialization Variables

final FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

dynamic _localNotificationsPlugin = localNotificationsPlugin;
const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel("Notification Channel", "Notifications",
        importance: Importance.high, playSound: true);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print("A bg message recieved ${message.messageId}");
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  // await Flame.device.fullScreen();

  // // Initialize hive.
  // await initHive();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler); // For Handling Background Messages

  // Firebase Local Messaging plugin Implementation
  await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  await FirebaseApi().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;
      if (remoteNotification != null && androidNotification != null) {
        _localNotificationsPlugin.show(
          remoteNotification.hashCode,
          remoteNotification.title,
          remoteNotification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannel.id,
              notificationChannel.name,
              icon: 'aarhn_logo2k25',
              color: Colors.blue,
              playSound: true,
            ),
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;
      if (remoteNotification != null && androidNotification != null) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser);
    return MultiProvider(
      providers: [
        StreamProvider<List<EventItem>>(
          create: (_) => FirebaseService().eventListStream(),
          initialData: [],
        ),
        StreamProvider<List<DayItem>>(
          create: (_) => FirebaseService().scheduleListStream(),
          initialData: [],
        ),
        StreamProvider<List<ContributorItem>>(
          create: (_) => FirebaseService().contributorStream(),
          initialData: [],
        ),
        StreamProvider<List<SponsorItem>>(
          create: (_) => FirebaseService().sponsorStream(),
          initialData: [],
        ),
        StreamProvider<List<ContactItem>>(
          create: (_) => FirebaseService().contactStream(),
          initialData: [],
        ),
        StreamProvider<List<ComingItem>>(
          create: (_) => FirebaseService().comingListStream(),
          initialData: [],
        ),
        StreamProvider<List<PrelimItem>>(
          create: (_) => FirebaseService().prelimStream(),
          initialData: [],
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirebaseAuth.instance.currentUser == null ? Login() : Splash(),
        routes: {
          '/eventpage': (context) => Event_Detail(),
          '/login': (context) => Login(),
          // '/game': (context) => gamerunner(),
          '/timeline': (context) => Timeline(),
          '/home': (context) => Dashboard(),
          '/leaderboard': (context) => Leaderboard(),
          '/about': (context) => About(),
          '/contributor': (context) => Contributors(),
          '/sponsor': (context) => Sponsors(),
          '/eurekoin': (context) => Eurekoin_Home(),
          '/contact': (context) => Contact(),
          '/coming': (context) => Coming(),
          // '/journo': (context) => Interfecio(),
          '/transaction': (context) => Transaction(),
          '/prelims': (context) => Prelims(),
        },
      ),
    );
  }
}
