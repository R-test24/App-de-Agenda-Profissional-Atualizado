import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';



class NovoClienteScreen extends StatefulWidget {


  const NovoClienteScreen({super.key});



  @override
  State<NovoClienteScreen> createState() =>
      _NovoClienteScreenState();


}





class _NovoClienteScreenState extends State<NovoClienteScreen> {


  final nomeController =
  TextEditingController();


  final telefoneController =
  TextEditingController();


  final observacaoController =
  TextEditingController();



  final ClienteRepository repository =
      ClienteRepository();






  Future<void> salvar() async {



    if(nomeController.text.trim().isEmpty){



      ScaffoldMessenger.of(context)
          .showSnackBar(



        const SnackBar(

          content:
          Text(
              "Digite o nome do cliente"
          ),

        ),



      );



      return;


    }







    final cliente = Cliente(


      nome:
      nomeController.text.trim(),



      telefone:
      telefoneController.text.trim(),



      observacao:
      observacaoController.text.trim(),



    );







    await repository.salvarCliente(cliente);





    if(!mounted) return;




    Navigator.pop(context);



  }








  @override
  Widget build(BuildContext context){



    return Scaffold(




      appBar: AppBar(



        title:
        const Text(

            "Novo Cliente"

        ),



      ),







      body:
      SingleChildScrollView(



        padding:
        const EdgeInsets.all(20),





        child:
        Column(



          children: [





            TextField(



              controller:
              nomeController,



              decoration:
              InputDecoration(



                labelText:
                "Nome do cliente",



                prefixIcon:
                const Icon(

                    Icons.person

                ),



                filled:
                true,



                fillColor:
                Colors.white,



                border:
                OutlineInputBorder(



                  borderRadius:
                  BorderRadius.circular(15),



                ),



              ),



            ),







            const SizedBox(height:15),







            TextField(



              controller:
              telefoneController,



              keyboardType:
              TextInputType.phone,



              decoration:
              InputDecoration(



                labelText:
                "Telefone",



                prefixIcon:
                const Icon(

                    Icons.phone

                ),



                filled:
                true,



                fillColor:
                Colors.white,



                border:
                OutlineInputBorder(



                  borderRadius:
                  BorderRadius.circular(15),



                ),



              ),



            ),







            const SizedBox(height:15),







            TextField(



              controller:
              observacaoController,



              maxLines:
              3,



              decoration:
              InputDecoration(



                labelText:
                "Observações",



                prefixIcon:
                const Icon(

                    Icons.notes

                ),



                filled:
                true,



                fillColor:
                Colors.white,



                border:
                OutlineInputBorder(



                  borderRadius:
                  BorderRadius.circular(15),



                ),



              ),



            ),







            const SizedBox(height:25),








            SizedBox(


              width:
              double.infinity,



              height:
              55,



              child:
              ElevatedButton.icon(



                onPressed:
                salvar,



                icon:
                const Icon(

                    Icons.save

                ),



                label:
                const Text(

                    "Salvar Cliente"

                ),



              ),



            )



          ],



        ),



      ),



    );



  }



}