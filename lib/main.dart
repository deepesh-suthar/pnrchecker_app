import 'package:flutter/material.dart';
import 'pnr_service.dart';
import 'pdf_helper.dart';


void main() {
  runApp(PnrCheckerApp());
}

class PnrCheckerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // AMOLED BLACK
        primaryColor: Colors.tealAccent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController pnrController = TextEditingController();
  final PnrService service = PnrService();
  Map<String, dynamic>? pnrData;
  bool loading = false;

  Future<void> getPnrData() async {
    final pnr = pnrController.text.trim();

    if (pnr.length != 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter a valid 10-digit PNR")));
      return;
    }

    setState(() => loading = true);

    try {
      final data = await service.fetchPnrStatus(pnr);
      setState(() => pnrData = data['data']);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching PNR")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PNR Checker"),
        centerTitle: true,
        backgroundColor: Colors.tealAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: pnrController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter PNR Number",
                labelStyle: TextStyle(color: Colors.tealAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: getPnrData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: StadiumBorder(),
              ),
              child: Text("Check PNR", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            if (loading) CircularProgressIndicator(color: Colors.tealAccent),

            if (pnrData != null) Expanded(child: buildResultUI())
          ],
        ),
      ),
    );
  }

  Widget buildResultUI() {
    final passengers = pnrData!["passengerList"];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ------------------ TRAIN INFO CARD ------------------
          Card(
            color: Colors.grey[900],
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Train: ${pnrData!['trainName']} (${pnrData!['trainNumber']})",
                      style: TextStyle(fontSize: 18, color: Colors.tealAccent)),
                  SizedBox(height: 8),
                  Text("Journey: ${pnrData!['dateOfJourney']}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("From: ${pnrData!['sourceStation']} → To: ${pnrData!['destinationStation']}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("Class: ${pnrData!['journeyClass']}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("Chart Status: ${pnrData!['chartStatus']}",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // ------------------ PASSENGER TABLE ------------------
          Text(
            "Passenger Details",
            style: TextStyle(
                fontSize: 18,
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          Table(
            border: TableBorder.all(color: Colors.white54),
            children: [
              TableRow(
                decoration:
                BoxDecoration(color: Colors.tealAccent.shade700),
                children: [
                  tableHeader("No"),
                  tableHeader("Status"),
                  tableHeader("Coach"),
                  tableHeader("Berth"),
                ],
              ),
              ...passengers.map<TableRow>((p) {
                return TableRow(children: [
                  tableCell("${p['passengerSerialNumber']}"),
                  tableCell("${p['bookingStatus']}"),
                  tableCell("${p['bookingCoachId']}"),
                  tableCell("${p['bookingBerthNo']}"),
                ]);
              }).toList(),
            ],
          ),

          SizedBox(height: 30),

          // ------------------ PDF BUTTON ------------------
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                await sharePdf(pnrData!);
              },
              icon: Icon(Icons.picture_as_pdf, color: Colors.black),
              label: Text("Generate PDF",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                padding:
                EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: StadiumBorder(),
              ),
            ),
          ),

          SizedBox(height: 30),

        ],
      ),
    );
  }


  Widget tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
