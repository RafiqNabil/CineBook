import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDbService _tmdbService = TMDbService();
  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final results = await _tmdbService.fetchPopularMovies();
      setState(() {
        _movies = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 95, 21, 21),
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
                  context.go('/');
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
        titleTextStyle: const TextStyle(fontSize: 24, color: Colors.white),
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
                image: AssetImage("assets/bg_image_8.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double aspectRatio = 0.6;

                    if (constraints.maxWidth >= 900) {
                      crossAxisCount = 4;
                      aspectRatio = 0.7;
                    } else if (constraints.maxWidth >= 600) {
                      crossAxisCount = 3;
                      aspectRatio = 0.65;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return InkWell(
                          onTap: () =>
                              context.pushNamed('movie_detail', extra: movie),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            color: const Color.fromARGB(
                              255,
                              95,
                              21,
                              21,
                            ).withOpacity(0.90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      movie.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
