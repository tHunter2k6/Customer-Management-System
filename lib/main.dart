import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/firebase_options.dart';
import 'package:pos/pages/home_page.dart';
import 'package:pos/pages/new_Invoice.dart';

Color backgroundColor = const Color.fromARGB(255, 18, 18, 18);
Color containerColor = const Color.fromARGB(255, 28, 28, 28);
Color altColumn1 = const Color.fromARGB(255, 79, 79, 79);
Color altColumn2 = const Color.fromARGB(255, 30, 30, 30);
Color textColor = const Color.fromARGB(255, 237, 237, 237);
Color secondaryTextColor = const Color.fromARGB(255, 176, 176, 176);

Color primaryAccent = const Color.fromARGB(255, 0, 191, 166);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          fontFamily: 'Montserrat',
        ),
        home: NewInvoice(),
      ),
    );
  }
}
