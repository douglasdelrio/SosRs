import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoS RS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _shelterController = TextEditingController();
  String _searchName = '';
  File? _imageFile;

  void _addPerson() async {
    if (_imageFile != null) {
      Reference ref = _storage.ref().child('photos').child(_imageFile!.path);
      UploadTask uploadTask = ref.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String photoURL = await snapshot.ref.getDownloadURL();

      _db.collection('people').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'shelter': _shelterController.text,
        'photoURL': photoURL,
      });
    } else {
      _db.collection('people').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'shelter': _shelterController.text,
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  void _searchPerson() {
    setState(() {
      _searchName = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SoS RS - Cadastro de Pessoas e Animais'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Localidade'),
            ),
            TextField(
              controller: _shelterController,
              decoration: InputDecoration(labelText: 'Abrigo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Adicionar Foto'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addPerson,
                  child: Text('Adicionar Pessoa'),
                ),
                ElevatedButton(
                  onPressed: _searchPerson,
                  child: Text('Procurar Pessoa'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Pessoas Encontradas:', style: TextStyle(fontSize: 18)),
            StreamBuilder(
              stream: _db
                  .collection('people')
                  .where('name', isEqualTo: _searchName)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.data == null)
                  return Text('Nenhuma pessoa encontrada.');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot person = snapshot.data!.docs[index];
                    return ListTile(
                      leading: person['photoURL'] != null
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(person['photoURL']),
                      )
                          : null,
                      title: Text(person['name']),
                      subtitle: Text(person['phone']),
                      onTap: () {
                        // Faça algo quando a pessoa for selecionada
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



