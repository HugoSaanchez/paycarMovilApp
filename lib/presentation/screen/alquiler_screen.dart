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
  int? selectedMixto;

  List<String> marcas = [];
  List<int> anios = [];
  List<String> modelos = [];
  List<String> versiones = [];

  @override
  void initState() {
    super.initState();
    _fetchMarcas();
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

  Future<void> _fetchMixto(String marca, int anio, String modelo, String version) async {
    final mixto = await datosVehiculosService.getAlquiladoStatusPorMarcaAnioModeloVersion(marca, anio, modelo, version);
    setState(() {
      this.selectedMixto = mixto;
    });
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
                  selectedMixto = null;
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
                    selectedMixto = null;
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
                    selectedMixto = null;
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
                    selectedMixto = null;
                  });
                  if (value != null) {
                    _fetchMixto(selectedMarca!, selectedAnio!, selectedModelo!, value);
                  }
                },
              ),
            if (selectedMixto != null)
              Text(
                'Mixto: $selectedMixto',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí se añadirá la lógica para alquilar el coche
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
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Coche ${index + 1}', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Hasta el: 2024-12-31', style: TextStyle(color: Colors.white70)),
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

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // HomeScreen(),
    // FriendsScreen(),
    // ChatScreen(),
    AlquilarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F3640),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2F3640),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car, color: Colors.green),
            label: 'Alquiler',
          ),
          // Añadir más items aquí según sea necesario
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

