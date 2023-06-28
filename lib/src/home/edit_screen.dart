import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';
import 'package:where_are_my_friends/src/constants/text_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  Reference storage = FirebaseStorage.instance.ref();

  var formKey = GlobalKey<FormState>();

  String? facebook = '';
  String? instagram = '';
  String? twitter = '';
  String? about = '';
  String? fullname = '';

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final storageReference = storage.child('avatars/$userId.jpg');
        final file = File(imagePath);
        await storageReference.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await storageReference.getDownloadURL();
        await firestore.collection('users').doc(userId).update({
          'avatarUrl': downloadUrl,
        });
      }
    } else {
      // Caso o usuário tenha cancelado a seleção da imagem
    }
  }

  void editSave(context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        firestore.collection('users').doc(auth.currentUser?.uid).update({
          'fullname': fullname,
          'facebook': facebook,
          'instagram': instagram,
          'twitter': twitter,
          'about': about
        });
        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro de registro'),
              content: Text('Ocorreu um erro ao editar o usuário. $e.message'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fechar o diálogo
                  },
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text('Erro ao carregar os dados do Firebase');
          }
          if (!snapshot.hasData) {
            return const Text('Não há dados disponíveis');
          }

          Map<String, dynamic>? data =
              snapshot.data?.data() as Map<String, dynamic>?;

          // Extrair os dados do snapshot
          final bool hasFacebook = data!.containsKey('facebook');
          final bool hasInstagram = data.containsKey('instagram');
          final bool hasTwitter = data.containsKey('twitter');
          final bool hasAbout = data.containsKey('twitter');
          final bool hasAvatarUrl = data.containsKey('avatarUrl');

          return SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(tDefaultSize),
                  child: Form(
                    key: formKey,
                    child: Column(children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          hasAvatarUrl
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  foregroundImage: NetworkImage(
                                    data[
                                        'avatarUrl'], // URL da imagem do Firebase Storage
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: primaryColor,
                                  child: Icon(Icons.person, size: 30),
                                ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading:
                                                const Icon(Icons.camera_alt),
                                            title: const Text('Câmera'),
                                            onTap: () async {
                                              _getImage(
                                                  context, ImageSource.camera);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.photo_library),
                                            title: const Text('Galeria'),
                                            onTap: () async {
                                              _getImage(
                                                  context, ImageSource.gallery);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.photo,
                                    size: 20, color: primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onSaved: (value) => fullname = value!,
                        initialValue: data['fullname'],
                        decoration: const InputDecoration(
                          label: Text('Nome Completo'),
                          labelStyle: TextStyle(
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onSaved: (value) => facebook = value!,
                        initialValue: hasFacebook ? data['facebook'] : '',
                        decoration: const InputDecoration(
                          label: Text('@facebook'),
                          labelStyle: TextStyle(
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.facebook,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onSaved: (value) => instagram = value!,
                        initialValue: hasInstagram ? data['instagram'] : '',
                        decoration: const InputDecoration(
                          label: Text('@instagram'),
                          labelStyle: TextStyle(
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.instagram,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onSaved: (value) => twitter = value!,
                        initialValue: hasTwitter ? data['twitter'] : '',
                        decoration: const InputDecoration(
                          label: Text('@twitter'),
                          labelStyle: TextStyle(
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.twitter,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onSaved: (value) => about = value!,
                        initialValue: hasAbout ? data['about'] : '',
                        maxLines:
                            5, // Define o número máximo de linhas do campo de texto
                        keyboardType: TextInputType
                            .multiline, // Define o tipo de teclado como multilinhas
                        decoration: const InputDecoration(
                          labelText: 'Sobre',
                          labelStyle: TextStyle(
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.comment,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => editSave(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                          ),
                          child: Text(salvar.toUpperCase()),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
