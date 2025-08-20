import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movie.dart';
import '../services/pdf_ticket.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final String showtime;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> selectedSeats = [];
  final int seatPrice = 200;

  void toggleSeat(String seat) {
    setState(() {
      selectedSeats.contains(seat)
          ? selectedSeats.remove(seat)
          : selectedSeats.add(seat);
    });
  }

  void confirmBooking() async {
    final bookingBox = Hive.box('bookings');
    final bookingTime = DateTime.now().toIso8601String();

    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';

    final booking = {
      'title': widget.movie.title,
      'showtime': widget.showtime,
      'seats': selectedSeats,
      'timestamp': bookingTime,
      'userEmail': userEmail,
    };

    await bookingBox.add(booking);

    await generateAndPrintTicket(
      movieTitle: widget.movie.title,
      showtime: widget.showtime,
      seats: selectedSeats,
      bookingTime: bookingTime,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Confirmed & Ticket Generated')),
    );
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('bookings').add({
      'movieTitle': widget.movie.title,
      'showtime': widget.showtime,
      'seats': selectedSeats,
      'timestamp': bookingTime,
      'userEmail': userEmail,
    });
    if (!mounted) return;
    context.go('/booking_history');
  }

  List<String> bookedSeats = [];

  @override
  void initState() {
    super.initState();
    fetchBookedSeats();
  }

  void fetchBookedSeats() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('movieTitle', isEqualTo: widget.movie.title)
        .where('showtime', isEqualTo: widget.showtime)
        .get();

    final List<String> seats = [];
    for (var doc in snapshot.docs) {
      final seatList = List<String>.from(doc['seats']);
      seats.addAll(seatList);
    }

    setState(() {
      bookedSeats = seats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> seatNumbers = List.generate(
      20,
      (index) => 'S${index + 1}',
    );

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 95, 21, 21)),
              child: Text(
                'CineBook',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(title: Text('Home'), onTap: () => context.push('/')),
            ListTile(
              title: const Text('Showtimes'),
              onTap: () => context.push('/showtime'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
                context.pushReplacement('/login');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 95, 21, 21),
        title: const Text('CineBook'),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 24, color: Colors.white),
        actions: [
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
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg_image_11.jpg"),
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
                        widget.movie.imageUrl,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 300,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Please Select Your Seats',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Selected: ${selectedSeats.length} | Total: ${selectedSeats.length * seatPrice} Tk',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.5,
                          ),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            shrinkWrap: true,
                            children: seatNumbers.map((seat) {
                              final isSelected = selectedSeats.contains(seat);
                              final isBooked = bookedSeats.contains(seat);

                              return GestureDetector(
                                onTap: isBooked ? null : () => toggleSeat(seat),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? Colors.red
                                        : isSelected
                                        ? Colors.green
                                        : Colors.grey[300], //default
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      seat,
                                      style: TextStyle(
                                        color: isBooked
                                            ? Colors.white
                                            : isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: selectedSeats.isEmpty ? null : confirmBooking,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        backgroundColor: const Color.fromARGB(255, 95, 21, 21),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm Booking'),
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
