import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/firebase_options.dart';
import 'package:pos/pages/home_page.dart';
import 'package:window_manager/window_manager.dart';

Color backgroundColor = const Color.fromARGB(255, 18, 18, 18);
Color containerColor = const Color.fromARGB(255, 28, 28, 28);
Color textColor = const Color.fromARGB(255, 237, 237, 237);
Color secondaryTextColor = const Color.fromARGB(255, 176, 176, 176);

Color primaryAccent = const Color.fromARGB(255, 0, 191, 166);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      center: true,
      title: 'POS App',
      minimumSize: Size(800, 600),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize(); //Maximizes the window
      await windowManager.show();
    });
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1440, 900),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: MyHomePage(),
      ),
    );
  }
}
