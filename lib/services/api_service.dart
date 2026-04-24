import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://ductile-josie-nonburdensomely.ngrok-free.dev/api/advogados/';
  

static Future<List> getAdvogados() async {
  final response = await http.get(Uri.parse(baseUrl));

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Erro ao carregar dados: ${response.statusCode}');
  }
}
}