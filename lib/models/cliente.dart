class Cliente {

  final int? id;

  final String nome;

  final String? telefone;

  final String? observacao;


  Cliente({

    this.id,

    required this.nome,

    this.telefone,

    this.observacao,

  });



  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'nome': nome,

      'telefone': telefone,

      'observacao': observacao,

    };

  }



  factory Cliente.fromMap(Map<String, dynamic> map) {

    return Cliente(

      id: map['id'],

      nome: map['nome'],

      telefone: map['telefone'],

      observacao: map['observacao'],

    );

  }

}