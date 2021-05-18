
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:chat/models/login_response.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/models/usuario.dart';

class AuthService with ChangeNotifier{

  Usuario usuario;
  bool _autenticando = false;

  final _storage = new FlutterSecureStorage();
  
  bool get autenticando => this._autenticando;
  set autenticando( bool valor){
    this._autenticando = valor;
    notifyListeners();
  }

  // Getters del token de forma estática
  static Future<String> getToken() async{
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async{
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  
  Future <bool> login ( String email, String password) async{

    this.autenticando = true;

    final data = {
      'email': email,
      'password' : password
    };

    final uri = Uri.parse('${Environment.apiurl}/login');
    

    final resp = await http.post(uri,
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    print( resp.body);
    this.autenticando = false;

    if( resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      // aumentar el minsdk , mira las preguntas del video, ya que el minimo
      // para utilizar flutter_secure_storage es 18 
      // ir a android/app/build.grandle y aumentar el minsdk y luego flutter clean.
      
      await this._guardarToken(loginResponse.token);

      return true;
    }else{
      return false;
    }

  }

  Future register ( String nombre, String email, String password) async{
    
    this.autenticando = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password' : password
    };

    final uri = Uri.parse('${Environment.apiurl}/login/new');
    

    final resp = await http.post(uri,
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    print( resp.body);
    this.autenticando = false;

    if( resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      
      await this._guardarToken(loginResponse.token);

      return true;
    }else{
      final resBody = jsonDecode(resp.body);
      return resBody['msg'];
    }
  
  }

  Future<bool> isLoggedin() async {

    final token = await this._storage.read(key: 'token');
    
    final uri = Uri.parse('${Environment.apiurl}/login/renew');
    

    final resp = await http.get(uri,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token
      }
    );

    // print( resp.body);
    this.autenticando = false;

    if( resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      
      await this._guardarToken(loginResponse.token);

      return true;
    }else{
      await this.logOut();
      return false;
    }

  }

  Future _guardarToken( String token) async{
    return await _storage.write(key: 'token', value: token);
  }

  Future logOut() async{
    await _storage.delete(key: 'token');
  }



}