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

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load environment variables from .env file
  await dotenv.load(fileName: "assets/dotenv.env");
  await Hive.initFlutter();
  await Hive.openBox('bookings');
  // Once all necessary services are initialized, run the main application widget.
  runApp(CineBookRoot());
}

/// The root widget of the CineBook application.
/// It sets up the theme provider and handles user authentication state
/// to navigate between login and home screens.
class CineBookRoot extends StatelessWidget {
  const CineBookRoot({
    super.key,
  }); // Added const constructor for better performance

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // We don’t need to do anything with snapshot.data directly here.
              // Just listening is enough to rebuild the widget tree on auth changes.
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
              );
            },
          );
        },
      ),
    );
  }
}
