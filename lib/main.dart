import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: "assets/dotenv.env");
  await Hive.initFlutter();
  await Hive.openBox('bookings');

  runApp(CineBookRoot());
}

class CineBookRoot extends StatelessWidget {
  const CineBookRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              return MaterialApp.router(
                routerConfig: router,
                title: 'CineBook',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.deepPurple,
                ),
                themeMode: themeProvider.themeMode,
              );
            },
          );
        },
      ),
    );
  }
}
