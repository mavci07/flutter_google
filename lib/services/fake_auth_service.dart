import 'package:firebase/model/user_model.dart';
import 'package:firebase/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "123123123123123";
  @override
  Future<User> currentUser() async {
    return await Future.value(User(userID: userID, email: 'fakeeeeee'));
  }

  @override
  Future<User> signInAnonymously() async {
    return await Future.delayed(
        Duration(seconds: 2), () => User(userID: userID, email: 'fakeeeeee'));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<User> signInWithGoogle() async {
    return await Future.delayed(Duration(seconds: 2),
        () => User(userID: "google_user_id_1234", email: 'fakeeeeee'));
  }

  @override
  Future<User> signInWithFacebook() async {
    return await Future.delayed(Duration(seconds: 2),
        () => User(userID: "facebook_user_id_1234", email: 'fakeeeeee'));
  }

  @override
  Future<User> createUserWithEmailandPassword(
      String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2),
        () => User(userID: "created_user_id_1234", email: 'fakeeeeee'));
  }

  @override
  Future<User> signInWithEmailandPassword(String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2),
        () => User(userID: "SİgnIn_user_id_1234", email: 'fakeeeeee'));
  }
}
