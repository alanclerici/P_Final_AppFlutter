class DatoDB {
  final int id;
  final String autologin;
  final String clave;

  DatoDB({required this.id, required this.autologin, required this.clave});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'autologin': autologin,
      'clave': clave,
    };
  }
}
