import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/models/auth.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<Auth> login(String email, String senha) async {
    // Chamada para a API de autenticação
    final response = await Dio().post(
      Api.login,
      data: {'username': email, 'password': senha},
    );

    // Retorna o usuário com o token
    return Auth.fromJson(response.data);
  }

  Future<void> saveToken(String token) async {
    // Armazena o token no SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('token', 'Token $token');
  }

  Future<String?> get token async {
    // Recupera o token do SharedPreferences
    return SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
  }
  Future<void> logout() async {
    // Recupera o token do SharedPreferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}