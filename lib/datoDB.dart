class DatoDB {
  final int id;
  final String ip;
  final String clave;

  DatoDB({required this.id, required this.ip, required this.clave});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ip': ip,
      'clave': clave,
    };
  }
}
