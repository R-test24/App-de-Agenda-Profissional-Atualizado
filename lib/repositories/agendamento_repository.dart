import '../database/database_helper.dart';
import '../models/agendamento.dart';


class AgendamentoRepository {


  final DatabaseHelper databaseHelper =
      DatabaseHelper.instance;



  // ==========================
  // SALVAR AGENDAMENTO
  // ==========================

  Future<int> salvarAgendamento(
      Agendamento agendamento) async {


    final db =
        await databaseHelper.database;


    return await db.insert(

      'agendamentos',

      agendamento.toMap(),

    );


  }


  // ==========================
  // LISTAR AGENDAMENTOS
  // ==========================


  Future<List<Map<String, dynamic>>>
  listarAgendamentosComCliente() async {



    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT

        agendamentos.*,

        clientes.nome AS clienteNome


      FROM agendamentos


      INNER JOIN clientes


      ON clientes.id = agendamentos.clienteId


      ORDER BY data ASC, horario ASC


    ''');



    return resultado;


  }







  // ==========================
  // ATUALIZAR
  // ==========================


  Future<int> atualizarAgendamento(
      Agendamento agendamento) async {


    final db =
        await databaseHelper.database;



    return await db.update(


      'agendamentos',


      agendamento.toMap(),


      where: 'id = ?',


      whereArgs: [

        agendamento.id

      ],


    );


  }








  // ==========================
  // EXCLUIR
  // ==========================


  Future<int> excluirAgendamento(int id) async {



    final db =
        await databaseHelper.database;



    return await db.delete(


      'agendamentos',


      where: 'id = ?',


      whereArgs: [

        id

      ],


    );


  }







  // ==========================
  // RELATÓRIOS DIA
  // ==========================



  Future<int> totalAtendimentosDia(
      String data) async {



    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT COUNT(*) AS total


      FROM agendamentos


      WHERE data = ?


    ''',

    [

      data

    ]);



    return (resultado.first['total'] as int?) ?? 0;


  }







  Future<double> faturamentoDia(
      String data) async {



    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT SUM(valor) AS total


      FROM agendamentos


      WHERE data = ?


    ''',

    [

      data

    ]);



    final total =
        resultado.first['total'];



    if(total == null){

      return 0;

    }



    return (total as num).toDouble();


  }







  // ==========================
  // RELATÓRIO SEMANAL
  // ==========================



  Future<int> totalAtendimentosSemana(
      DateTime inicio,
      DateTime fim) async {



    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT COUNT(*) AS total


      FROM agendamentos


      WHERE substr(data,7,4) || '-' ||
            substr(data,4,2) || '-' ||
            substr(data,1,2)

      BETWEEN ? AND ?



    ''',

    [

      formatarDataSQL(inicio),

      formatarDataSQL(fim),


    ]);



    return (resultado.first['total'] as int?) ?? 0;


  }







  Future<double> faturamentoSemana(
      DateTime inicio,
      DateTime fim) async {



    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT SUM(valor) AS total


      FROM agendamentos


      WHERE substr(data,7,4) || '-' ||
            substr(data,4,2) || '-' ||
            substr(data,1,2)

      BETWEEN ? AND ?



    ''',

    [

      formatarDataSQL(inicio),

      formatarDataSQL(fim),


    ]);



    final total =
        resultado.first['total'];



    if(total == null){

      return 0;

    }



    return (total as num).toDouble();


  }







  String formatarDataSQL(DateTime data){


    return "${data.year}-"
        "${data.month.toString().padLeft(2,'0')}-"
        "${data.day.toString().padLeft(2,'0')}";


  }
  // ==========================
  // RELATÓRIO MENSAL
  // ==========================



  Future<int> totalAtendimentosMes(
      String mes) async {



    final db =
        await databaseHelper.database;



    final partes =
        mes.split('/');



    final mesNumero =
        partes[0];



    final ano =
        partes[1];





    final resultado =
    await db.rawQuery('''


      SELECT COUNT(*) AS total


      FROM agendamentos


      WHERE substr(data,7,4) = ?

      AND substr(data,4,2) = ?



    ''',

    [

      ano,

      mesNumero,


    ]);




    return (resultado.first['total'] as int?) ?? 0;



  }









  Future<double> faturamentoMes(
      String mes) async {



    final db =
        await databaseHelper.database;



    final partes =
        mes.split('/');



    final mesNumero =
        partes[0];



    final ano =
        partes[1];





    final resultado =
    await db.rawQuery('''


      SELECT SUM(valor) AS total


      FROM agendamentos


      WHERE substr(data,7,4) = ?

      AND substr(data,4,2) = ?



    ''',

    [

      ano,

      mesNumero,


    ]);





    final total =
        resultado.first['total'];





    if(total == null){

      return 0;

    }





    return (total as num).toDouble();



  }

  // ==========================
  // GRÁFICO FATURAMENTO ÚLTIMOS 12 MESES
  // ==========================


  Future<List<Map<String, dynamic>>> faturamentoUltimosMeses() async {


    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT

        substr(data,4,2) AS mes,

        substr(data,7,4) AS ano,

        SUM(valor) AS total



      FROM agendamentos



      GROUP BY

        substr(data,7,4),

        substr(data,4,2)



      ORDER BY

        substr(data,7,4),

        substr(data,4,2)



    ''');



    return resultado;


  }




  // ==========================
  // FATURAMENTO TOTAL DO ANO
  // ==========================


  Future<double> faturamentoAno(
      String ano) async {


    final db =
        await databaseHelper.database;



    final resultado =
    await db.rawQuery('''


      SELECT

        SUM(valor) AS total



      FROM agendamentos



      WHERE substr(data,7,4) = ?



    ''',

    [

      ano

    ]);



    final total =
        resultado.first['total'];



    if(total == null){

      return 0;

    }



    return (total as num).toDouble();


  }
      // ==========================
  // LISTAR CLIENTES
  // ==========================

  Future<List<Map<String, dynamic>>> listarClientes() async {


    final db =
        await databaseHelper.database;



    final resultado =
    await db.query(

      'clientes',

      orderBy: 'nome ASC',

    );



    return resultado;


  }


}