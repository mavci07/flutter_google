import 'package:firebase/repository/user_repository.dart';
import 'package:firebase/services/fake_auth_service.dart';
import 'package:firebase/services/firebase_auth_service.dart';
import 'package:firebase/services/firestore_db_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FirestoreDBService());
  locator.registerLazySingleton(() => FakeAuthenticationService());
  locator.registerLazySingleton(() => UserRepository());
}
