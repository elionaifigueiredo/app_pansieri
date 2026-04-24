// import 'package:app_escritorio/splash_page.dart';
import 'package:flutter/material.dart';
import 'pages/lista_advogados_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escritório',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D1B2A),
        ),
      ),

      // 🔥 PONTO DE ENTRADA DIRETO
      // home: const ListaAdvogadosPage(),
      // home: const SplashPage(),
      home: const ListaAdvogadosPage(),
    );
  }
}