import 'package:flutter/material.dart';
import 'package:paycar/service/grupo_service.dart';
import 'package:paycar/presentation/screen/home_screen.dart'; // Importar la pantalla de inicio

class AddGroupScreen extends StatelessWidget {
  final GrupoService grupoService = GrupoService();

  AddGroupScreen({Key? key}) : super(key: key);

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController consumoGasolinaController = TextEditingController();
  final TextEditingController kilometrosRecorridosController = TextEditingController();
  final TextEditingController dineroGasolinaController = TextEditingController();

  void _crearGrupo(BuildContext context) async {
    if (tituloController.text.isEmpty || descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El título y la descripción no pueden estar vacíos')),
      );
      return;
    }

    final result = await grupoService.createGroup(
      tituloController.text,
      descripcionController.text,
      double.tryParse(consumoGasolinaController.text) ?? 0.0,
      double.tryParse(kilometrosRecorridosController.text) ?? 0.0,
      double.tryParse(dineroGasolinaController.text) ?? 0.0,
    );

    if (result == 'grupo-creado') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result!)),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Grupo'),
        backgroundColor: Colors.green, // Fondo negro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _crearGrupo(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF2F3640), backgroundColor: Colors.green, // Texto negro para el botón
              ),
              child: Text('Crear Grupo'),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF2F3640), // Fondo negro
    );
  }
}
