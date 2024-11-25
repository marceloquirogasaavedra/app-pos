class UserModel {
  final String token;
  final String email;
  final String nombre;
  final String apellido;
  final int id;

  UserModel({
    required this.token,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      id: json['id'],
    );
  }
}
