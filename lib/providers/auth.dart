import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  //token in firebase expire in about 1 hour
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    //TODO check user id like the token getter
    return _userId;
  }

//All API documents are availabe at the link below
//https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  Future<void> signup(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBxg-MzO6DPYzUZ5vdTwiRQtzsD00ieem8";
    try {
      final response = await http.post(url,
          body: jsonEncode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      _autoLogout();
      notifyListeners();
      final userData = jsonEncode({
        "token": _token,
        "userId": userId,
        "expiryDate": _expiryDate.toIso8601String()
      });
      final pref = await SharedPreferences.getInstance();
      pref.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signin(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBxg-MzO6DPYzUZ5vdTwiRQtzsD00ieem8";
    try {
      final response = await http.post(url,
          body: jsonEncode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      _autoLogout();
      notifyListeners();
      final userData = jsonEncode({
        "token": _token,
        "userId": userId,
        "expiryDate": _expiryDate.toIso8601String()
      });
      final pref = await SharedPreferences.getInstance();
      pref.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey("userData")) {
      return false;
    }
    final userData =
        jsonDecode(pref.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData["token"];
    _userId = userData["userId"];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    // pref.remove("userData");
    pref.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () {
      logout();
    });
  }
}
