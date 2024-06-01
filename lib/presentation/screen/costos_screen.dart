import 'package:flutter/material.dart';
import 'package:paycar/model/grupo_modelo.dart';
import 'package:paycar/service/datosVehiculos_service.dart';
import 'package:paycar/service/grupo_service.dart';

class CalcularCostosScreen extends StatefulWidget {
  final int grupoId;

  CalcularCostosScreen({Key? key, required this.grupoId}) : super(key: key);

  @override
  _CalcularCostosScreenState createState() => _CalcularCostosScreenState();
}

class _CalcularCostosScreenState extends State<CalcularCostosScreen> {
  final GrupoService grupoService = GrupoService();
  final DatosVehiculosService datosVehiculosService = DatosVehiculosService();
  Grupo? grupo;
  bool isLoading = true;
  bool hasError = false;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _kilometrosController;
  late TextEditingController _consumoController;
  late TextEditingController _dineroController;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    try {
      Grupo? fetchedGrupo = await grupoService.obtenerGrupo(widget.grupoId);
      if (fetchedGrupo != null) {
        setState(() {
          grupo = fetchedGrupo;
          _kilometrosController = TextEditingController(text: grupo!.kilometrosRecorridos.toString());
          _consumoController = TextEditingController(text: grupo!.consumoGasolina.toString());
          _dineroController = TextEditingController(text: grupo!.dineroGasolina.toString());
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      double consumoGasolina = double.parse(_consumoController.text);
      int kilometrosRecorridos = int.parse(_kilometrosController.text);
      double dineroGasolina = double.parse(_dineroController.text);

      // Editar el grupo
      String? result = await grupoService.editarGrupo(widget.grupoId, consumoGasolina, kilometrosRecorridos, dineroGasolina);

      if (result != null && result.contains('exitosamente')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Grupo actualizado exitosamente')));

        // Calcular el costo del viaje
        Map<String, dynamic>? costoResult = await grupoService.calcularCostoViaje(widget.grupoId);
        if (costoResult != null) {
          double costoViaje = costoResult['costoViaje'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Costo del viaje calculado: $costoViaje')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al calcular el costo del viaje')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el grupo')));
      }
    }
  }

  Future<void> _showMarcasDialog() async {
    try {
      List<String> marcas = await datosVehiculosService.getMarcas();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2F3640),
            title: Text(
              'Selecciona una Marca',
              style: TextStyle(color: Colors.green),
            ),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: marcas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(marcas[index], style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAniosDialog(marcas[index]);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cerrar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener marcas')));
    }
  }

  Future<void> _showAniosDialog(String marca) async {
    try {
      List<int> anios = await datosVehiculosService.getAniosPorMarca(marca);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2F3640),
            title: Text(
              'Selecciona un Año',
              style: TextStyle(color: Colors.green),
            ),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: anios.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(anios[index].toString(), style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showModelosDialog(marca, anios[index]);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cerrar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener años')));
    }
  }

  Future<void> _showModelosDialog(String marca, int anio) async {
    try {
      List<String> modelos = await datosVehiculosService.getModelosPorMarcaYAnio(marca, anio);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2F3640),
            title: Text(
              'Selecciona un Modelo',
              style: TextStyle(color: Colors.green),
            ),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: modelos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(modelos[index], style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showVersionesDialog(marca, anio, modelos[index]);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cerrar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener modelos')));
    }
  }

  Future<void> _showVersionesDialog(String marca, int anio, String modelo) async {
    try {
      List<String> versiones = await datosVehiculosService.getVersionesPorMarcaAnioYModelo(marca, anio, modelo);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2F3640),
            title: Text(
              'Selecciona una Versión',
              style: TextStyle(color: Colors.green),
            ),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: versiones.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(versiones[index], style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      double consumo = await datosVehiculosService.getMixtoPorMarcaAnioModeloVersion(marca, anio, modelo, versiones[index]);
                      setState(() {
                        _consumoController.text = consumo.toString();
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cerrar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener versiones')));
    }
  }

  @override
  void dispose() {
    _kilometrosController.dispose();
    _consumoController.dispose();
    _dineroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calcular Costos",
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Color(0xFF2F3640),
      ),
      backgroundColor: Color(0xFF2F3640),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Error al cargar los detalles del grupo.', style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kilómetros Recorridos:',
                          style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _kilometrosController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingresa los kilómetros recorridos',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese los kilómetros recorridos';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Consumo de Gasolina:',
                          style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _consumoController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingresa el consumo de gasolina',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el consumo de gasolina';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Dinero de Gasolina:',
                          style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _dineroController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingresa el dinero de gasolina',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el dinero de gasolina';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveChanges,
                          child: Text('Guardar Cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: _showMarcasDialog,
                          child: Text(
                            '¿No sabes el consumo de gasolina?',
                            style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
