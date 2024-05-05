// firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class FirebaseOptions {
  static FirebaseOptions _instance = FirebaseOptions._();
  FirebaseOptions._();

  static FirebaseOptions getInstance() {
    return _instance;
  }

// Adicione suas configurações do Firebase aqui, como chaves de API, IDs do projeto, etc.
}
