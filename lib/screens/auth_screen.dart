import 'dart:io';
import 'package:chat_app/widgets/auth/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  void _submitAuthForm({
    required String email,
    required String password,
    required String username,
    required bool isLogin,
    required File userImageFile,
  }) async {
    late UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        //
        Reference reference = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(userCredential.user!.uid + '.jpg');
        await reference.putFile(userImageFile);

        //
        final url = await reference.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(
              userCredential.user!.uid,
            )
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        });
        print(userCredential.credential!.providerId);
      }
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred, please check your credentials';
      if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
