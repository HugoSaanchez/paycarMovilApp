import 'package:flutter/material.dart';
import 'package:paycar/presentation/screen/addGrupo._screen.dart';
import 'package:paycar/presentation/screen/group_screen.dart';
import 'package:paycar/presentation/screen/login_screen.dart';
import 'package:paycar/presentation/screen/perfil_screen.dart';
import 'package:paycar/service/grupo_service.dart';
import 'package:paycar/service/usuario_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GrupoService grupoService = GrupoService();
  final UsuarioService usuarioService = UsuarioService();
  late Future<List<Map<String, dynamic>>> gruposFuture;
  bool showCards = true;

  @override
  void initState() {
    super.initState();
    gruposFuture = grupoService.getGrupos();
  }

  void _navigateToGroupDetails(BuildContext context, Map<String, dynamic> grupo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(grupo: grupo),
      ),
    ).then((_) {
      setState(() {
        gruposFuture = grupoService.getGrupos(); // Refrescar la lista de grupos al volver
      });
    });
  }

  void _onMenuOptionSelected(String option) {
    switch (option) {
      case 'Crear Grupo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddGroupScreen()),
        ).then((_) {
          setState(() {
            gruposFuture = grupoService.getGrupos();
          });
        });
        break;
      case 'Perfil':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 'Cerrar Sesión':
        usuarioService.logout().then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F3640),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text(
          'PayCar',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuOptionSelected,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Crear Grupo',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Crear Grupo', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Perfil',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Perfil', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Cerrar Sesión',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ];
            },
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Colors.green,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            if (showCards)
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: gruposFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No tienes grupos.',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      final grupos = snapshot.data!;
                      return ListView.builder(
                        itemCount: grupos.length,
                        itemBuilder: (context, index) {
                          final grupo = grupos[index];
                          return GestureDetector(
                            onTap: () => _navigateToGroupDetails(context, grupo),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.transparent,
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.green,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        grupo['titulo'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        grupo['descripcion'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
