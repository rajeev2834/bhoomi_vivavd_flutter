import 'dart:convert';
import 'dart:io';

import 'package:bhoomi_vivad/constants.dart';
import 'package:bhoomi_vivad/models/http_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Auth with ChangeNotifier {
  String? _token;

  bool get isAuth {
    return token != null;
  }

  dynamic get token {
    if (_token != null) return _token;
    return null;
  }

  Future<void> _authenticate(String username, String password) async {
    final url = base_url + 'token/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(
          {
            'username': username,
            'password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['non_field_errors'] != null) {
        throw HttpException(responseData['non_field_errors'][0]);
      }
      _token = responseData['token'];
      //await fetchAndSetCircle();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signin(String username, String password) async {
    return _authenticate(username, password);
  }

  Future<dynamic> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
    json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedUserData['token'];
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> fetchAndSetUser() async {
    final url = base_url + 'manage/';
    try {
      final response = await http.get(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Token " + _token.toString()});
      if(response.statusCode == 200)
      {
        final extractedUserData =
        jsonDecode(response.body) as Map<String, dynamic>;
        notifyListeners();
      }
      else{
        throw HttpException("Unable to load User data!!!");
      }

    } catch (error) {
      throw (error);
    }
  }

}