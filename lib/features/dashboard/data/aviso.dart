class Aviso {
  final int id;
  final String mensaje;
  final String fecha;

  Aviso({
    required this.id,
    required this.mensaje,
    required this.fecha,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      id: json['id'] as int,
      mensaje: json['mensaje'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mensaje': mensaje,
        'fecha': fecha,
      };
}

