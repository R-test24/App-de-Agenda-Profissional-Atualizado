import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;


  DatabaseHelper._init();


  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('agenda_nails.db');

    return _database!;

  }



  Future<Database> _initDB(String fileName) async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);


    return await openDatabase(

      path,

      version: 1,

      onCreate: _createDB,

    );

  }



  Future<void> _createDB(
      Database db,
      int version,
      ) async {

        print("CRIANDO BANCO DE DADOS");


    await db.execute('''

      CREATE TABLE clientes (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        nome TEXT NOT NULL,

        telefone TEXT,

        observacao TEXT

      )

    ''');



    await db.execute('''

      CREATE TABLE agendamentos (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        clienteId INTEGER,

        data TEXT,

        horario TEXT,

        servico TEXT,

        valor REAL,

        observacao TEXT

      )

    ''');


  }

}