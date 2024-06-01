import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'package:paycar/model/usuario_modelo.dart';
import 'package:paycar/presentation/screen/costos_screen.dart';
import 'package:paycar/service/grupo_service.dart';
import 'package:paycar/service/usuario_service.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;
  final GrupoService grupoService = GrupoService(); // Instancia de GrupoService
  final UsuarioService usuarioService = UsuarioService();

  GroupDetailsScreen({Key? key, required this.grupo}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  String? usuarioActualId;
  String? rolUsuario;
  bool isLoading = true;
  bool hasError = false;
  double? diferenciaUsuarioActual;
  String? invitacionUrl;
  int idConductor = 0;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      usuarioActualId = await obtenerUsuarioActualId();
      if (usuarioActualId != null) {
        final result = await widget.grupoService.getUsuarioRolNombre(int.parse(usuarioActualId!), widget.grupo['id']);
        if (result != null) {
          rolUsuario = result['rol'];
        }
      }
      await _fetchDiferenciaUsuarioActual();
      await _fetchInvitacion();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDiferenciaUsuarioActual() async {
    final diferencias = await widget.grupoService.calcularDiferenciaCoste(widget.grupo['id']);
    if (diferencias != null && usuarioActualId != null) {
      final result = await widget.grupoService.getUsuarioRolNombre(int.parse(usuarioActualId!), widget.grupo['id']);
      if (result != null) {
        final nombreUsuario = result['nombre'];
        setState(() {
          diferenciaUsuarioActual = diferencias[nombreUsuario];
        });
      }
    }
  }

  Future<String?> obtenerUsuarioActualId() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'userId');
  }

  Future<void> _fetchInvitacion() async {
    final url = await widget.grupoService.obtenerInvitacion(widget.grupo['id']);
    setState(() {
      invitacionUrl = url;
    });
  }

 Future<void> _generateInviteCode() async {
  try {
    final url = await widget.grupoService.crearInvitacion(widget.grupo['id']);
    setState(() {
      invitacionUrl = url;
    });
    Navigator.of(context).pop(); // Close the current dialog
    // Reload the page
    _initializeUser();

  } catch (e) {
    // Handle error if needed
  }
}


  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invitar a grupo'),
          content: invitacionUrl == null
              ? Text('No hay enlace de invitación. ¿Quieres generar uno?')
              : Row(
                  children: [
                    Expanded(child: Text('Código: $invitacionUrl')),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: invitacionUrl ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Código copiado al portapapeles')));
                      },
                    ),
                  ],
                ),
          actions: [
            if (invitacionUrl == null)
              TextButton(
                child: Text('Generar enlace'),
                onPressed: _generateInviteCode,
               
              ),
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showValoracionComentarioDialog() async {
    TextEditingController _comentarioController = TextEditingController();
    int _valoracion = 1; // Valor inicial válido

    // Obtener el id del conductor
    final int idCond = idConductor;
    final int idGrupo = widget.grupo['id'];

    // Obtener el comentario y la valoración actuales
    String? comentarioActual = await widget.usuarioService.verComentario(idCond, idGrupo);
    int? valoracionActual = await widget.usuarioService.verValoracion(idCond, idGrupo);

    // Si existen datos, inicializarlos
    if (comentarioActual != null) {
      _comentarioController.text = comentarioActual;
    }
    if (valoracionActual != null) {
      _valoracion = valoracionActual;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Valorar y Comentar'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Valoración actual:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _valoracion ? Icons.star : Icons.star_border,
                          color: index < _valoracion ? Colors.yellow : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _valoracion = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí',
                    ),
                    maxLines: 3,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enviar'),
              onPressed: () async {
                // Lógica para enviar la valoración y el comentario
                int nuevaValoracion = _valoracion;
                String nuevoComentario = _comentarioController.text;

                // Aquí puedes agregar la lógica para enviar la nueva valoración y comentario al servidor
                await widget.usuarioService.valorarUsuario(idCond, nuevaValoracion, idGrupo);
                await widget.usuarioService.comentarUsuario(idCond, nuevoComentario, idGrupo);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " ${widget.grupo['titulo']}",
          style: TextStyle(color: Colors.white), // Color del texto del título en verde
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      backgroundColor: Color(0xFF2F3640),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Error al cargar los detalles del grupo.', style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        widget.grupo['descripcion'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 5),
                      FutureBuilder<Map<String, List<String>>>(
                        future: _fetchUsuariosPorRol(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No se encontraron integrantes.', style: TextStyle(color: Colors.white)));
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._buildWidgetsFromRoles(snapshot.data!),
                                if (rolUsuario == 'conductor')
                                  SizedBox(height: 20),
                                if (rolUsuario == 'conductor')
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CalcularCostosScreen(grupoId: widget.grupo['id']),
                                        ),
                                      );
                                    },
                                    child: Text('Calcular Costos'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                if (rolUsuario == 'pasajero')
                                  ElevatedButton(
                                    onPressed: diferenciaUsuarioActual == 0.0 ? null : _handlePagar,
                                    child: Text(diferenciaUsuarioActual == 0.0 ? 'Ya has pagado' : 'Pagar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: diferenciaUsuarioActual == 0 ? Colors.grey : Colors.green,
                                    ),
                                  ),
                                if (rolUsuario == 'pasajero')
                                  ElevatedButton(
                                    onPressed: _showValoracionComentarioDialog,
                                    child: Text('Valorar y Comentar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<Map<String, List<String>>> _fetchUsuariosPorRol() async {
    Map<String, List<String>> usuariosPorRol = {};
    Map<String, double>? diferencias = await widget.grupoService.calcularDiferenciaCoste(widget.grupo['id']);
    if (diferencias == null) {
      // Manejo del error
      return usuariosPorRol;
    }

    for (var usuarioId in widget.grupo['usuarios']) {
      final result = await widget.grupoService.getUsuarioRolNombre(usuarioId, widget.grupo['id']);
      if (result != null) {
        String rol = result['rol'] ?? 'Desconocido'; // Provide default value
        String nombre = result['nombre'];
        if (rol.contains("conductor")) idConductor = result['id'];

        double diferencia = diferencias[nombre] ?? 0;
        if (!usuariosPorRol.containsKey(rol)) {
          usuariosPorRol[rol] = [];
        }
        usuariosPorRol[rol]!.add('$nombre (Diferencia: $diferencia)');
      } else {
        if (!usuariosPorRol.containsKey('Desconocido')) {
          usuariosPorRol['Desconocido'] = [];
        }
        usuariosPorRol['Desconocido']!.add('Usuario ID: $usuarioId no encontrado');
      }
    }

    return usuariosPorRol;
  }

  Future<void> _handlePagar() async {
    if (usuarioActualId != null) {
      Map<String, dynamic>? result = await widget.grupoService.actualizarCostepagado(widget.grupo['id'], int.parse(usuarioActualId!));
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago realizado correctamente')));
        await _fetchDiferenciaUsuarioActual();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al realizar el pago')));
      }
    }
  }

  List<Widget> _buildWidgetsFromRoles(Map<String, List<String>> usuariosPorRol) {
    List<Widget> widgets = [];

    // Añadir primero el conductor si existe
    if (usuariosPorRol.containsKey('conductor')) {
      widgets.add(Text(
        'Conductor',
        style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
      ));
      widgets.addAll(usuariosPorRol['conductor']!.map((nombre) => Text(
            nombre,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )));
      usuariosPorRol.remove('conductor'); // Remover el conductor del mapa
      widgets.add(SizedBox(height: 10)); // Añadir espacio después de la lista de conductores
    }

    // Añadir los demás roles
    usuariosPorRol.forEach((rol, nombres) {
      widgets.add(Text(
        rol,
        style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
      ));
      widgets.addAll(nombres.map((nombre) => Text(
            nombre,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )));
      widgets.add(SizedBox(height: 10)); // Añadir espacio entre grupos de roles
    });

    return widgets;
  }
}
