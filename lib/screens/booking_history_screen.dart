import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingBox = Hive.box('bookings');
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 95, 21, 21),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: bookingBox.listenable(),
            builder: (context, box, _) {
              // Filter only current user's bookings
              final userBookings = box.values.where((booking) {
                return booking is Map &&
                    booking['userEmail'] == currentUserEmail;
              }).toList();

              if (userBookings.isEmpty) {
                return const Center(
                  child: Text(
                    'No bookings yet.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: userBookings.length,
                itemBuilder: (context, index) {
                  final booking = userBookings[index] as Map;

                  final title =
                      booking['title'] ?? booking['movie'] ?? 'Unknown Movie';
                  final showtime = booking['showtime'] ?? 'Unknown Time';
                  final seats =
                      (booking['seats'] as List?)?.join(', ') ?? 'None';
                  final timestampStr =
                      booking['timestamp'] ?? booking['bookingTime'];
                  final userEmail = booking['userEmail'] ?? 'Unknown User';

                  String formattedTime = 'Unknown Date';
                  if (timestampStr != null && timestampStr is String) {
                    try {
                      formattedTime = DateTime.parse(
                        timestampStr,
                      ).toLocal().toString().split('.')[0];
                    } catch (_) {
                      formattedTime = 'Invalid Date';
                    }
                  }

                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Showtime: $showtime'),
                          Text('Seats: $seats'),
                          Text('Booked at: $formattedTime'),
                          Text('User: $userEmail'),
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
