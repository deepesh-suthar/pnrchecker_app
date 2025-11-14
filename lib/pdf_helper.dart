import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';



/// Create PDF from pnrData map
Future<Uint8List> createPnrPdf(Map<String, dynamic> pnrData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("PNR Ticket",
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // TRAIN DETAILS
            pw.Text(
              "${pnrData['trainName']} (${pnrData['trainNumber']})",
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 5),
            pw.Text("Journey Date: ${pnrData['dateOfJourney']}"),
            pw.Text("From: ${pnrData['sourceStation']}"),
            pw.Text("To: ${pnrData['destinationStation']}"),
            pw.Text("Class: ${pnrData['journeyClass']}"),
            pw.Text("Chart: ${pnrData['chartStatus']}"),

            pw.SizedBox(height: 20),
            pw.Text("Passenger Details:",
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ['No', 'Status', 'Coach', 'Berth'],
              data: (pnrData['passengerList'] as List).map((p) {
                return [
                  p['passengerSerialNumber'].toString(),
                  p['bookingStatus'],
                  p['bookingCoachId'],
                  p['bookingBerthNo'].toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

/// Save PDF to device
Future<String> savePdf(Uint8List bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/$fileName");
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Share the PDF using Android share sheet
Future<void> sharePdf(Map<String, dynamic> pnrData) async {
  final bytes = await createPnrPdf(pnrData);

  await Printing.sharePdf(
    bytes: bytes,
    filename:
    "pnr_${pnrData['pnrNumber'] ?? DateTime.now().millisecondsSinceEpoch}.pdf",
  );
}
