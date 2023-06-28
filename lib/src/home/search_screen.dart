import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/widgets/user_link_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<UserLinkWidget> userWidgets = [];

  void searchUsernames(String user) {
    final collection = FirebaseFirestore.instance.collection('users');
    collection
        .where('username', isGreaterThanOrEqualTo: user)
        .get()
        .then((querySnapshot) {
      setState(() {
        userWidgets = querySnapshot.docs.map((doc) {
          final hasAvatar = doc.data().containsKey('avatarUrl');
          final username = doc.data()['username'] as String?;
          final fullname = doc.data()['fullname'] as String?;
          return UserLinkWidget(
            avatarUrl: hasAvatar ? doc.data()['avatarUrl'] : null,
            username: username,
            fullname: fullname,
          );
        }).toList();
      });
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro de registro'),
            content:
                Text('Ocorreu um erro ao buscar o usuário. $error.message'),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Pesquisar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Username',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final user = searchController.text.trim();
                    searchUsernames(user);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: userWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
