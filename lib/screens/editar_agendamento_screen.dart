import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../repositories/agendamento_repository.dart';

class EditarAgendamentoScreen extends StatefulWidget {
  final Map<String, dynamic> agendamento;

  const EditarAgendamentoScreen({
    super.key,
    required this.agendamento,
  });

  @override
  State<EditarAgendamentoScreen> createState() =>
      _EditarAgendamentoScreenState();
}

class _EditarAgendamentoScreenState
    extends State<EditarAgendamentoScreen> {
  final AgendamentoRepository repository =
      AgendamentoRepository();

  // Cor principal do aplicativo
  static const Color corPrincipal = Color(0xFF374151);

  late TextEditingController dataController;
  late TextEditingController horarioController;
  late TextEditingController servicoController;
  late TextEditingController valorController;
  late TextEditingController observacaoController;

  @override
  void initState() {
    super.initState();

    dataController = TextEditingController(
      text: widget.agendamento['data']?.toString() ?? '',
    );

    horarioController = TextEditingController(
      text: widget.agendamento['horario']?.toString() ?? '',
    );

    servicoController = TextEditingController(
      text: widget.agendamento['servico']?.toString() ?? '',
    );

    valorController = TextEditingController(
      text: widget.agendamento['valor']?.toString() ?? '',
    );

    observacaoController = TextEditingController(
      text: widget.agendamento['observacao']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    dataController.dispose();
    horarioController.dispose();
    servicoController.dispose();
    valorController.dispose();
    observacaoController.dispose();

    super.dispose();
  }

  Future<void> salvarAlteracao() async {
    final agendamento = Agendamento(
      id: widget.agendamento['id'],
      clienteId: widget.agendamento['clienteId'],
      data: dataController.text,
      horario: horarioController.text,
      servico: servicoController.text,
      valor: double.tryParse(
            valorController.text.replaceAll(',', '.'),
          ) ??
          0,
      observacao: observacaoController.text,
    );

    await repository.atualizarAgendamento(
      agendamento,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Agendamento atualizado!",
        ),
        backgroundColor: corPrincipal,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // CABEÇALHO
      appBar: AppBar(
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Editar Agendamento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // CONTEÚDO
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // DATA
            TextField(
              controller: dataController,
              decoration: InputDecoration(
                labelText: "Data",
                floatingLabelStyle: const TextStyle(
                  color: corPrincipal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: corPrincipal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // HORÁRIO
            TextField(
              controller: horarioController,
              decoration: InputDecoration(
                labelText: "Horário",
                floatingLabelStyle: const TextStyle(
                  color: corPrincipal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: corPrincipal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SERVIÇO
            TextField(
              controller: servicoController,
              decoration: InputDecoration(
                labelText: "Serviço",
                floatingLabelStyle: const TextStyle(
                  color: corPrincipal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: corPrincipal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // VALOR
            TextField(
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Valor",
                prefixText: "R\$ ",
                floatingLabelStyle: const TextStyle(
                  color: corPrincipal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: corPrincipal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // OBSERVAÇÃO
            TextField(
              controller: observacaoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Observação",
                alignLabelWithHint: true,
                floatingLabelStyle: const TextStyle(
                  color: corPrincipal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: corPrincipal,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: salvarAlteracao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrincipal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Salvar Alteração",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}