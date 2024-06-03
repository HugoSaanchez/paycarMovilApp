import 'package:flutter/material.dart';
import 'package:paycar/service/datosVehiculos_service.dart';

class AlquilarScreen extends StatefulWidget {
  @override
  _AlquilarScreenState createState() => _AlquilarScreenState();
}

class _AlquilarScreenState extends State<AlquilarScreen> {
  final DatosVehiculosService datosVehiculosService = DatosVehiculosService();

  String? selectedMarca;
  int? selectedAnio;
  String? selectedModelo;
  String? selectedVersion;
  int? alquiladoStatus;
  String? fechaInicioAlquiler;
  String? fechaFinAlquiler;

  List<String> marcas = [];
  List<int> anios = [];
  List<String> modelos = [];
  List<String> versiones = [];
  List<Map<String, dynamic>> vehiculosAlquilados = [];

  @override
  void initState() {
    super.initState();
    _fetchMarcas();
    _fetchVehiculosAlquilados();
  }

  Future<void> _fetchMarcas() async {
    final marcas = await datosVehiculosService.getMarcas();
    setState(() {
      this.marcas = marcas;
    });
  }

  Future<void> _fetchAnios(String marca) async {
    final anios = await datosVehiculosService.getAniosPorMarca(marca);
    setState(() {
      this.anios = anios;
    });
  }

  Future<void> _fetchModelos(String marca, int anio) async {
    final modelos = await datosVehiculosService.getModelosPorMarcaYAnio(marca, anio);
    setState(() {
      this.modelos = modelos;
    });
  }

  Future<void> _fetchVersiones(String marca, int anio, String modelo) async {
    final versiones = await datosVehiculosService.getVersionesPorMarcaAnioYModelo(marca, anio, modelo);
    setState(() {
      this.versiones = versiones;
    });
  }

  Future<void> _fetchAlquiladoStatus(String marca, int anio, String modelo, String version) async {
    final status = await datosVehiculosService.getAlquiladoStatusPorMarcaAnioModeloVersion(marca, anio, modelo, version);
    setState(() {
      this.alquiladoStatus = status["alquilado"];
      this.fechaInicioAlquiler = status.containsKey("fechaInicio") ? status["fechaInicio"] : null;
      this.fechaFinAlquiler = status.containsKey("fechaFin") ? status["fechaFin"] : null;
    });
  }

  Future<void> _fetchVehiculosAlquilados() async {
    final vehiculos = await datosVehiculosService.getVehiculosAlquilados();
    setState(() {
      this.vehiculosAlquilados = vehiculos;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.black,
              surface: Colors.green,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF2F3640),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaInicioAlquiler = picked.start.toString().split(' ')[0];
        fechaFinAlquiler = picked.end.toString().split(' ')[0];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fecha de inicio: $fechaInicioAlquiler, Fecha de fin: $fechaFinAlquiler')),
      );

      // Llamar al método de alquiler
      final result = await datosVehiculosService.alquilarVehiculo(
        selectedMarca!,
        selectedAnio!,
        selectedModelo!,
        selectedVersion!,
        fechaInicioAlquiler!,
        fechaFinAlquiler!,
      );

      // Mostrar el resultado del alquiler
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );

      // Actualizar el estado del alquiler después de la operación
      _fetchAlquiladoStatus(selectedMarca!, selectedAnio!, selectedModelo!, selectedVersion!);
      _fetchVehiculosAlquilados();  // Actualizar la lista de vehículos alquilados
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alquilar un Coche'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF2F3640),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedMarca,
              hint: Text('Selecciona Marca', style: TextStyle(color: Colors.white)),
              dropdownColor: Color(0xFF2F3640),
              iconEnabledColor: Colors.green,
              items: marcas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMarca = value;
                  selectedAnio = null;
                  selectedModelo = null;
                  selectedVersion = null;
                  alquiladoStatus = null;
                  fechaInicioAlquiler = null;
                  fechaFinAlquiler = null;
                  anios = [];
                  modelos = [];
                  versiones = [];
                });
                if (value != null) {
                  _fetchAnios(value);
                }
              },
            ),
            if (selectedMarca != null)
              DropdownButton<int>(
                value: selectedAnio,
                hint: Text('Selecciona Año', style: TextStyle(color: Colors.white)),
                dropdownColor: Color(0xFF2F3640),
                iconEnabledColor: Colors.green,
                items: anios.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString(), style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnio = value;
                    selectedModelo = null;
                    selectedVersion = null;
                    alquiladoStatus = null;
                    fechaInicioAlquiler = null;
                    fechaFinAlquiler = null;
                    modelos = [];
                    versiones = [];
                  });
                  if (value != null) {
                    _fetchModelos(selectedMarca!, value);
                  }
                },
              ),
            if (selectedAnio != null)
              DropdownButton<String>(
                value: selectedModelo,
                hint: Text('Selecciona Modelo', style: TextStyle(color: Colors.white)),
                dropdownColor: Color(0xFF2F3640),
                iconEnabledColor: Colors.green,
                items: modelos.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModelo = value;
                    selectedVersion = null;
                    alquiladoStatus = null;
                    fechaInicioAlquiler = null;
                    fechaFinAlquiler = null;
                    versiones = [];
                  });
                  if (value != null) {
                    _fetchVersiones(selectedMarca!, selectedAnio!, value);
                  }
                },
              ),
            if (selectedModelo != null)
              DropdownButton<String>(
                value: selectedVersion,
                hint: Text('Selecciona Versión', style: TextStyle(color: Colors.white)),
                dropdownColor: Color(0xFF2F3640),
                iconEnabledColor: Colors.green,
                items: versiones.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVersion = value;
                    alquiladoStatus = null;
                    fechaInicioAlquiler = null;
                    fechaFinAlquiler = null;
                  });
                  if (value != null) {
                    _fetchAlquiladoStatus(selectedMarca!, selectedAnio!, selectedModelo!, value);
                  }
                },
              ),
            if (alquiladoStatus != null)
              Text(
                alquiladoStatus == 1
                    ? 'Estado: Está alquilado hasta $fechaFinAlquiler'
                    : 'Estado: No está alquilado',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            SizedBox(height: 20),
            if (alquiladoStatus != null && alquiladoStatus != 1)
              ElevatedButton(
                onPressed: () {
                  _selectDateRange(context);
                },
                child: Text('Alquilar Coche'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Coches Alquilados:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vehiculosAlquilados.length,
                itemBuilder: (context, index) {
                  final vehiculo = vehiculosAlquilados[index];
                  return ListTile(
                    title: Text('${vehiculo["marca"]} ${vehiculo["modelo"]}', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Hasta el: ${vehiculo["fecha_fin"]}', style: TextStyle(color: Colors.white70)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
