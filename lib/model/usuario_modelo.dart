import 'package:paycar/model/comentario_model.dart';
import 'package:paycar/model/usuarioGrupo_modelo.dart';
import 'package:paycar/model/valoracion_model.dart';

class Usuario {
  int id;
  String nombre;
  String username;
  String password;
  String rol;
  bool activado;
  bool borrado;
  String token;
  List<UsuarioGrupo> gruposCreados;
  List<Valoracion> valoracionesRecibidas;
  List<Comentario> comentariosRecibidos;
  String amigos;

  Usuario({
    required this.id,
    required this.nombre,
    required this.username,
    required this.password,
    required this.rol,
    required this.activado,
    required this.borrado,
    required this.token,
    required this.gruposCreados,
    required this.valoracionesRecibidas,
    required this.comentariosRecibidos,
    required this.amigos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      username: json['username'],
      password: json['password'],
      rol: json['rol'],
      activado: json['activado'],
      borrado: json['borrado'],
      token: json['token'],
      gruposCreados: List<UsuarioGrupo>.from(json['gruposCreados'].map((x) => UsuarioGrupo.fromJson(x))),
      valoracionesRecibidas: List<Valoracion>.from(json['valoracionesRecibidas'].map((x) => Valoracion.fromJson(x))),
      comentariosRecibidos: List<Comentario>.from(json['comentariosRecibidos'].map((x) => Comentario.fromJson(x))),
      amigos: json['amigos'],
    );
  }
}