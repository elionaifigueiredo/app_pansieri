import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:qr_flutter/qr_flutter.dart';
import '../pages/foto_full_page.dart';

class DetalheAdvogadoPage extends StatelessWidget {
  final Map adv;

  const DetalheAdvogadoPage({super.key, required this.adv});

  // 🔥 SAFE PARSE JSON
  List _parseList(dynamic data) {
    try {
      if (data == null) return [];
      if (data is List) return data;
      return jsonDecode(data);
    } catch (_) {
      return [];
    }
  }

  // 🔥 GERAR VCARD DINÂMICO
String gerarVcard() {
  final nome = adv['nome'] ?? '';
  // final foto = adv['foto'] ?? '';
  final foto = adv['foto'];
  final site = adv['site'] ?? '';

  final telefones = adv['telefones'] != null
      ? jsonDecode(adv['telefones'])
      : [];

  final emails = adv['emails'] != null
      ? jsonDecode(adv['emails'])
      : [];

  final enderecos = adv['enderecos'] != null
      ? jsonDecode(adv['enderecos'])
      : [];

  String vcard = "BEGIN:VCARD\r\n";
  vcard += "VERSION:3.0\r\n";
  vcard += "FN:$nome\r\n";
  vcard += "N:$nome;;;;\r\n";

  // 🔥 SITE
  if (site.isNotEmpty) {
    vcard += "URL:$site\r\n";
  }

  // 🔥 FOTO (ESSA LINHA RESOLVE SEU PROBLEMA)
  // if (foto.toString().startsWith('http')) {
  //   vcard += "PHOTO;VALUE=URI:$foto\r\n";
  // }


  if (foto != null && foto.toString().startsWith('http')) {
  vcard += "PHOTO;VALUE=URI:$foto\n";
}

  // 📞 TELEFONES
  for (var tel in telefones) {
    var numero = tel['numero'] ?? '';
    if (!numero.startsWith('+')) {
      numero = "+55$numero";
    }
    vcard += "TEL;TYPE=CELL:$numero\r\n";
  }

  // 📧 EMAILS
  for (var email in emails) {
    vcard += "EMAIL:${email['email']}\r\n";
  }

  // 📍 ENDEREÇOS
  for (var end in enderecos) {
    vcard += "ADR:;;${end['rua']} ${end['numero']};"
        "${end['cidade']};${end['estado']};;\r\n";
  }

  vcard += "END:VCARD\r\n";

  return vcard;
}



  @override
  Widget build(BuildContext context) {
    final nome = adv['nome'] ?? '';
    final foto = adv['foto'];

    final vcard = gerarVcard();

    return Scaffold(
      appBar: AppBar(title: Text(nome)),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 📸 FOTO
              GestureDetector(
                onTap: () {
                  if (foto == null || foto.toString().isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FotoFullPage(foto: foto),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: (foto != null && foto.toString().isNotEmpty)
                        ? (foto.toString().startsWith('http')
                            ? Image.network(
                                foto,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(foto),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ))
                        : const Icon(Icons.person, size: 40),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 QR PROFISSIONAL (AUTO)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                    )
                  ],
                ),
                child: QrImageView(
                  data: vcard,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Escaneie para salvar contato automaticamente",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}