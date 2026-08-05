import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {

  final FirebaseFirestore db =
      FirebaseFirestore.instance;


  Future<void> cadastrarCliente({

    required String nome,

    required String telefone,

  }) async {


    await db.collection("clientes").add({

      "nome": nome,

      "telefone": telefone,

      "dataCadastro": Timestamp.now(),

    });


  }

}