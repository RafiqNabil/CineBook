import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/movie_details_screen.dart';
import 'models/movie.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/', // This sets HomePage as the starting screen
  debugLogDiagnostics: true,
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/login';
    final signingUp = state.matchedLocation == '/signup';

    // Allow access to these public routes without login
    final publicPaths = ['/', '/login', '/signup'];

    if (!isLoggedIn && !publicPaths.contains(state.matchedLocation)) {
      return '/login';
    }

    // Redirect logged-in users away from login/signup
    if (isLoggedIn && (loggingIn || signingUp)) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(path: '/', name: 'home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/movie_detail',
      name: 'movie_detail',
      builder: (context, state) {
        final movie = state.extra;
        if (movie is! Movie) {
          return Scaffold(
            body: Center(child: Text('Error: Movie data is missing')),
          );
        }
        return MovieDetailsScreen(movie: movie);
      },
    ),
  ],
);
