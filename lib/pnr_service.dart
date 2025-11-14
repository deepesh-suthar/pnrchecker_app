import 'package:http/http.dart' as http;
import 'dart:convert';

class PnrService {
  static const String baseUrl =
      "https://pnrchecker-production.up.railway.app/api/pnr/";

  Future<Map<String, dynamic>> fetchPnrStatus(String pnr) async {
    final url = Uri.parse(baseUrl + pnr);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load PNR data");
    }
  }
}
