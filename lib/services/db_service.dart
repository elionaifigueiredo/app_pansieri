import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DBService {
  static const _dbName = 'advogados.db';
  static const _dbVersion = 3;

  static Future<Database> getDB() async {
    final path = join(await getDatabasesPath(), _dbName);

    return openDatabase(
      path,
      version: _dbVersion,

      onCreate: (db, version) async {
        await _createTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE advogados ADD COLUMN telefones TEXT');
          await db.execute('ALTER TABLE advogados ADD COLUMN emails TEXT');
          await db.execute('ALTER TABLE advogados ADD COLUMN enderecos TEXT');
        }

        if (oldVersion < 3) {
          await db.execute('ALTER TABLE advogados ADD COLUMN site TEXT');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE advogados(
        id INTEGER PRIMARY KEY,
        nome TEXT,
        especialidade TEXT,
        foto TEXT,
        vcard TEXT,

        telefone TEXT,
        site TEXT,

        telefones TEXT,
        emails TEXT,
        enderecos TEXT
      )
    ''');
  }

  static Future<void> salvarLocal(List lista) async {
    final db = await getDB();

    await db.delete('advogados');

    for (var adv in lista) {
      await db.insert('advogados', {
        'id': adv['id'],
        'nome': adv['nome'],
        'especialidade': adv['especialidade'],
        'foto': adv['foto'],
        'vcard': adv['vcard'],

        'telefone': adv['telefone'],
        'site': adv['site'],

        'telefones': jsonEncode(adv['telefones'] ?? []),
        'emails': jsonEncode(adv['emails'] ?? []),
        'enderecos': jsonEncode(adv['enderecos'] ?? []),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> carregarLocal() async {
    final db = await getDB();
    return await db.query('advogados');
  }
}