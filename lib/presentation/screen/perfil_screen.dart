import 'package:flutter/material.dart';
import 'package:paycar/service/usuario_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UsuarioService usuarioService = UsuarioService();
  late Future<double> valoracionMediaFuture;
  late Future<List<Map<String, dynamic>>> comentariosFuture;

  @override
  void initState() {
    super.initState();
    valoracionMediaFuture = usuarioService.verMediaValoracion();
    comentariosFuture = usuarioService.verTodosLosComentarios();
  }

  Widget buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) > 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.yellow));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: Colors.yellow));
    }
    while (stars.length < 5) {
      stars.add(Icon(Icons.star_border, color: Colors.yellow));
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F3640),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<double>(
                future: valoracionMediaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final valoracionMedia = snapshot.data ?? 0.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valoración media:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        buildStarRating(valoracionMedia),
                        Text(
                          valoracionMedia.toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'Comentarios:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: comentariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No tienes comentarios.',
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    final comentarios = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true, // Added to ensure the ListView is wrapped correctly
                      physics: NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                      itemCount: comentarios.length,
                      itemBuilder: (context, index) {
                        final comentario = comentarios[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              comentario['comentario'],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Pasajero: ${comentario['pasajeroNombre']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
