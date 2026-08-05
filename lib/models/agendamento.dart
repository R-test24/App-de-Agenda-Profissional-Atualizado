class Agendamento {


  final int? id;

  final int clienteId;

  final String data;

  final String horario;

  final String servico;

  final double valor;

  final String? observacao;





  Agendamento({

    this.id,

    required this.clienteId,

    required this.data,

    required this.horario,

    required this.servico,

    required this.valor,

    this.observacao,

  });








  // ==========================
  // CONVERTER PARA BANCO
  // ==========================

  Map<String, dynamic> toMap() {


    return {


      'id': id,

      'clienteId': clienteId,

      'data': data,

      'horario': horario,

      'servico': servico,

      'valor': valor,

      'observacao': observacao,


    };


  }








  // ==========================
  // PEGAR DO BANCO
  // ==========================

  factory Agendamento.fromMap(
      Map<String,dynamic> map) {


    return Agendamento(


      id: map['id'] as int?,



      clienteId:
      map['clienteId'] as int,



      data:
      map['data']?.toString() ?? "",



      horario:
      map['horario']?.toString() ?? "",



      servico:
      map['servico']?.toString() ?? "",




      valor:

      map['valor'] == null

          ? 0

          :

      (map['valor'] as num).toDouble(),




      observacao:
      map['observacao']?.toString(),



    );


  }



}