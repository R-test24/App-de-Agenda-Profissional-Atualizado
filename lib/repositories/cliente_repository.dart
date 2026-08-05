

import '../database/database_helper.dart';
import '../models/cliente.dart';



class ClienteRepository {


  final DatabaseHelper databaseHelper =
      DatabaseHelper.instance;



  Future<int> salvarCliente(Cliente cliente) async {


    final db = await databaseHelper.database;


    return await db.insert(

      'clientes',

      cliente.toMap(),

    );


  }



  Future<List<Cliente>> listarClientes() async {


    final db = await databaseHelper.database;


    final resultado = await db.query(

      'clientes',

      orderBy: 'nome ASC',

    );


    return resultado

        .map((map) => Cliente.fromMap(map))

        .toList();


  }



  Future<int> atualizarCliente(Cliente cliente) async {


    final db = await databaseHelper.database;


    return await db.update(

      'clientes',

      cliente.toMap(),

      where: 'id = ?',

      whereArgs: [cliente.id],

    );


  }



  Future<int> excluirCliente(int id) async {


    final db = await databaseHelper.database;


    return await db.delete(

      'clientes',

      where: 'id = ?',

      whereArgs: [id],

    );


  }


}