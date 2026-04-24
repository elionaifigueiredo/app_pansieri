import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import 'detalhe_advogado_page.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ListaAdvogadosPage extends StatefulWidget {
  const ListaAdvogadosPage({super.key});

  @override
  State<ListaAdvogadosPage> createState() => _ListaAdvogadosPageState();
}

class _ListaAdvogadosPageState extends State<ListaAdvogadosPage> {
  late Future<List> advogados;

  @override
  void initState() {
    super.initState();
    advogados = carregarDados();
  }

  Future<void> refresh() async {
    setState(() {
      advogados = carregarDados();
    });
  }

  // 🔥 FOTO
  Future<String?> baixarImagem(String? url, int id) async {
    try {
      if (url == null || url.isEmpty) return null;

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/adv_$id.jpg');

      await file.writeAsBytes(res.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // 🔥 VCARD FILE
  Future<String?> baixarVcard(String? url, int id) async {
    try {
      if (url == null || url.isEmpty) return null;

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/contato_$id.vcf');

      await file.writeAsBytes(res.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // 🔥 SYNC COMPLETO
  Future<List> carregarDados() async {
    final db = await DBService.getDB();

    try {
      final apiData = await ApiService.getAdvogados();

      if (apiData.isNotEmpty) {
        List<Map<String, dynamic>> novos = [];

        for (var adv in apiData) {
          final fotoLocal = await baixarImagem(adv['foto'], adv['id']);
          final vcardLocal = await baixarVcard(adv['vcard'], adv['id']);

          novos.add({
            'id': adv['id'],
            'nome': adv['nome'] ?? '',
            'especialidade': adv['especialidade'] ?? '',

            // 🔥 FOTO ROBUSTA
            'foto': fotoLocal ?? adv['foto'] ?? '',

            'vcard': vcardLocal ?? '',

            // 🔥 NOVO MODELO SEGURO
            'telefones': jsonEncode(adv['telefones'] ?? []),
            'emails': jsonEncode(adv['emails'] ?? []),
            'enderecos': jsonEncode(adv['enderecos'] ?? []),
            'site': adv['site'] ?? '',
          });
        }

        await db.delete('advogados');

        for (var item in novos) {
          await db.insert('advogados', item);
        }
      }
    } catch (e) {
      debugPrint("SYNC ERROR: $e");
    }

    return await db.query('advogados');
  }

  // 🔥 FOTO BUILDER (ÚNICO E CORRIGIDO)
  Widget buildFoto(String? foto) {
    if (foto == null || foto.isEmpty) {
      return const Icon(Icons.person);
    }

    if (foto.startsWith('http')) {
      return Image.network(foto, fit: BoxFit.cover);
    }

    return Image.file(File(foto), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advogados')),

      body: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<List>(
          future: advogados,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final lista = snapshot.data ?? [];

            if (lista.isEmpty) {
              return const Center(child: Text('Nenhum advogado encontrado'));
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final adv = lista[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalheAdvogadoPage(adv: adv),
                        ),
                      );
                    },

                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: buildFoto(adv['foto']),
                      ),
                    ),

                    title: Text(
                      adv['nome'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(adv['especialidade'] ?? ''),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}