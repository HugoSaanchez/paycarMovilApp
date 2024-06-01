class Mensaje {
  final int idEmisor;
  final int idReceptor;
  final String mensaje;
  final String hora;

  Mensaje({
    required this.idEmisor,
    required this.idReceptor,
    required this.mensaje,
    required this.hora,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      idEmisor: json['idEmisor'] as int,
      idReceptor: json['idReceptor'] as int,
      mensaje: json['mensaje'] as String,
      hora: json['hora'] as String,
    );
  }
  
}
