import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router.dart';

late final bool isPaidGlobal;

Future<void> mainCommon({required bool isPaid}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  isPaidGlobal = isPaid;

  if (kDebugMode) {
    print(dotenv.env);
    print('IS PAID: $isPaid');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Story App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
