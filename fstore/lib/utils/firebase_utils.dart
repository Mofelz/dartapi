import 'package:firebase_auth/firebase_auth.dart';
import 'package:fstore/utils/user_utils.dart';

import '../models/status.dart';

class FireBaseUtils {
  static FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  static FireBaseUtils get instance => FireBaseUtils();

  Future<Status> register(String login, String password) async {
    try {
      return await firebaseAuth
          .createUserWithEmailAndPassword(email: login, password: password)
          .then((value) {
        UserUtils.instanse.create(login, password, value.user!.uid);
        return Status();
      }).onError((error, stackTrace) {
        return Status(errorMessage: error.toString());
      });
    } on FirebaseAuthException catch (e) {
      return Status(errorMessage: e.message);
    }
  }

  Future<Status> deleteAccount() async {
    try {
      FirebaseAuth.instance.currentUser!.delete();
      return Status();
    } on FirebaseAuthException catch (e) {
      return Status(errorMessage: e.message);
    }
  }

  Future<Status> updateEmail(String login) async {
    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(login);
      return Status();
    } on FirebaseAuthException catch (e) {
      return Status(errorMessage: e.message);
    }
  }

  Future<Status> updatePassword(String password) async {
    try {
      FirebaseAuth.instance.currentUser!.updatePassword(password);
      return Status();
    } on FirebaseAuthException catch (e) {
      return Status(errorMessage: e.message);
    }
  }

  Future<Status> authWithLoginAndPassword(String login, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: login, password: password);
      return Status();
    } on FirebaseAuthException catch (e) {
      return Status(errorMessage: e.message);
    }
  }
}
