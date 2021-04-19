import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/model/user_model.dart';
import 'package:firebase/services/database_base.dart';

class FirestoreDBService implements DBBase {
  // final Firestore _firebaseAuth = Firestore.instance;
  final Firestore _firebaseAuth = Firestore.instance;

  @override
  Future<bool> saveUser(User user) async {
    DocumentSnapshot _okunanUser =
        await Firestore.instance.document("users/${user.userID}").get();

    if (_okunanUser.data == null) {
      await _firebaseAuth
          .collection("users")
          .document(user.userID)
          .setData(user.toMap());
      return true;
    } else {
      return true;
    }
  }

  static initializeApp() {}
}

/*Future<bool> saveUser(User user) async {
    await _firebaseAuth
        .collection("users")
        .document(user.userID)
        .setData(user.toMap());

    DocumentSnapshot _okunanUser =
        await Firestore.instance.document("user/${user.userID}").get();

    Map _okunanUserBilgileriMap = _okunanUser.data;
    User _okunanUserBilgileriNesne = User.fromMap(_okunanUserBilgileriMap);
    print("Okunan user nesnesi :" + _okunanUserBilgileriNesne.toString());

    return true;
  }
}*/
