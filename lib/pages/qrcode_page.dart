import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QRCodePage extends StatelessWidget {
  final String url;
  final String nome;

  const QRCodePage({
    super.key,
    required this.url,
    required this.nome,
  });

  Future<void> compartilharQR() async {
    try {
      final qrPainter = QrPainter(
        data: url,
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      final picData = await qrPainter.toImageData(800);

      if (picData == null) return;

      final bytes = picData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_$nome.png');

      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Contato de $nome',
      );
    } catch (e) {
      debugPrint("Erro QR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartão Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: compartilharQR,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: QrImageView(
                data: url,
                size: 260,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Escaneie para salvar contato automaticamente",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}