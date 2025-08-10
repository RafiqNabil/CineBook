import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintTicket({
  required String movieTitle,
  required String showtime,
  required List<String> seats,
  required String bookingTime,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  final userEmail = user?.email ?? 'Unknown User';

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CineBook Ticket',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'User: $userEmail',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Movie: $movieTitle', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Showtime: $showtime', style: pw.TextStyle(fontSize: 18)),
            pw.Text(
              'Seats: ${seats.join(', ')}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Booking Time: $bookingTime',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('Enjoy your movie!', style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
