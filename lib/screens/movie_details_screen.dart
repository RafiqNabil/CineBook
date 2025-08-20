import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
    return Scaffold(
      drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 95, 21, 21),
                  ),
                  child: Text(
                    'CineBook',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 95, 21, 21),
                  ),
                  accountName: Text('Welcome!'),
                  accountEmail: Text(user?.email ?? 'Guest'),
                  currentAccountPicture: user != null
                      ? CircleAvatar(child: Text(user.email![0].toUpperCase()))
                      : null,
                ),
                if (user != null) ...[
                  ListTile(
                    title: Text("Profile"),
                    onTap: () => context.pushNamed('user_profile'),
                  ),
                  ListTile(title: Text('Home'), onTap: () => context.go('/')),
                  ListTile(
                    title: Text("Booking History"),
                    onTap: () => context.pushNamed('booking_history'),
                  ),
                  ListTile(
                    title: Text('Logout'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      context.go('/'); // Redirect to Home after logout
                    },
                  ),
                ] else ...[
                  ListTile(title: Text('Home'), onTap: () => context.go('/')),
                  ListTile(
                    title: Text('Login/Register'),
                    onTap: () => context.push('/login'),
                  ),
                ],
              ],
            ),
          ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 95, 21, 21),
        title: const Text('CineBook'),

        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    context.go('/login');
                  },
                );
              } else {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        context.push('/booking_history');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        context.go('/');
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg_image_9.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        movie.imageUrl,
                        height: 600,
                        width: 400,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) =>
                            loadingProgress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Genre: ${movie.genre}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rating: ${movie.rating.toStringAsFixed(1)} / 10',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 95, 21, 21),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        context.push('/showtime', extra: movie);
                      },
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
