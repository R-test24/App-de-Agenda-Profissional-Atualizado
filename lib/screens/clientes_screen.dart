import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';
import 'novo_cliente_screen.dart';



class ClientesScreen extends StatefulWidget {

  const ClientesScreen({super.key});


  @override
  State<ClientesScreen> createState() =>
      _ClientesScreenState();

}




class _ClientesScreenState extends State<ClientesScreen> {


  final ClienteRepository repository =
      ClienteRepository();



  List<Cliente> clientes = [];

  List<Cliente> clientesFiltrados = [];



  final TextEditingController buscaController =
      TextEditingController();





  @override
  void initState(){

    super.initState();

    carregarClientes();


    buscaController.addListener((){

      filtrarClientes();

    });

  }





  Future<void> carregarClientes() async {


    final lista =
        await repository.listarClientes();



    if(!mounted) return;



    setState((){


      clientes = lista;

      clientesFiltrados = lista;


    });


  }







  void filtrarClientes(){


    final texto =
        buscaController.text.toLowerCase();



    setState((){


      clientesFiltrados =
          clientes.where((cliente){


            return cliente.nome
                .toLowerCase()
                .contains(texto);


          }).toList();


    });


  }







  Future<void> excluirCliente(Cliente cliente) async {



    final confirmar =
    await showDialog<bool>(


      context: context,


      builder:(context){


        return AlertDialog(


          title:
          const Text(
              "Excluir cliente"
          ),



          content:
          Text(
              "Deseja excluir ${cliente.nome}?"
          ),



          actions:[



            TextButton(

              onPressed:(){

                Navigator.pop(
                    context,
                    false
                );

              },


              child:
              const Text(
                  "Cancelar"
              ),

            ),





            ElevatedButton(


              onPressed:(){


                Navigator.pop(
                    context,
                    true
                );


              },


              child:
              const Text(
                  "Excluir"
              ),


            ),



          ],



        );


      },

    );





    if(confirmar == true){


      await repository.excluirCliente(
          cliente.id!
      );



      carregarClientes();




      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(

          content:
          Text(
              "Cliente excluído com sucesso"
          ),

        ),

      );

    }


  }







  @override
  void dispose(){

    buscaController.dispose();

    super.dispose();

  }








  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar: AppBar(

        title:
        const Text(
            "Clientes"
        ),

      ),





      floatingActionButton:
      FloatingActionButton.extended(



        backgroundColor:
        const Color(0xFF374151),



        foregroundColor:
        Colors.white,



        icon:
        const Icon(
            Icons.person_add
        ),



        label:
        const Text(
            "Novo Cliente"
        ),




        onPressed:() async {



          await Navigator.push(


              context,


              MaterialPageRoute(


                  builder:(_)=>
                  const NovoClienteScreen()


              )


          );



          carregarClientes();


        },


      ),






      body:
      Column(



        children:[




          Padding(


            padding:
            const EdgeInsets.all(15),



            child:
            TextField(



              controller:
              buscaController,



              decoration:
              InputDecoration(



                labelText:
                "Buscar cliente",



                hintText:
                "Digite o nome",



                prefixIcon:
                const Icon(
                    Icons.search
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



          ),






          Text(


            "Total de clientes: ${clientesFiltrados.length}",


            style:
            const TextStyle(


              fontSize:18,


              fontWeight:
              FontWeight.bold,


            ),


          ),





          const SizedBox(height:10),






          Expanded(



            child:
            clientesFiltrados.isEmpty


                ?

            const Center(


              child:
              Text(
                  "Nenhum cliente encontrado"
              ),


            )



                :



            ListView.builder(



              itemCount:
              clientesFiltrados.length,



              itemBuilder:(context,index){



                final cliente =
                clientesFiltrados[index];




                return Card(


                  margin:
                  const EdgeInsets.symmetric(

                      horizontal:12,

                      vertical:6

                  ),




                  child:
                  ListTile(



                    leading:
                    const CircleAvatar(


                      backgroundColor:
                      Color(0xFFE5E7EB),



                      child:
                      Icon(


                        Icons.person,


                        color:
                        Color(0xFF374151),


                      ),



                    ),





                    title:
                    Text(


                      cliente.nome,


                      style:
                      const TextStyle(


                          fontWeight:
                          FontWeight.bold


                      ),


                    ),





                    subtitle:
                    Text(

                        cliente.telefone ??
                            "Sem telefone"

                    ),






                    trailing:
                    IconButton(


                      icon:
                      const Icon(

                        Icons.delete,

                        color:
                        Colors.red,

                      ),



                      onPressed:(){


                        excluirCliente(cliente);


                      },



                    ),



                  ),



                );



              },



            ),



          ),



        ],



      ),



    );


  }


}