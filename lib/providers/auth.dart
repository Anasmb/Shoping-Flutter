import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  //token in firebase expire in about 1 hour
  String _token;
  DateTime _expiryDate;
  String _userId;

//All API documents are availabe at the link below
//https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  Future<void> signup(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBxg-MzO6DPYzUZ5vdTwiRQtzsD00ieem8";
    final response = await http.post(url,
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    print(json.decode(response.body));
  }
}
