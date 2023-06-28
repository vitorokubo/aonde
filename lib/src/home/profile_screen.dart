import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/vrouter.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';
import 'package:where_are_my_friends/src/home/edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse("https://$url");
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "can not launch url";
    }
  }

  void logout(context) async {
    try {
      await auth.signOut();
      VRouter.of(context).to('/welcome');
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
                  VRouter.of(context).pop();
                },
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(auth.currentUser!.uid).get(),
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

        final bool hasFacebook = data!.containsKey('facebook');
        final bool hasInstagram = data.containsKey('instagram');
        final bool hasTwitter = data.containsKey('twitter');
        final bool hasAbout = data.containsKey('twitter');
        final bool hasAvatar = data.containsKey('avatarUrl');

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(data['fullname']),
              backgroundColor: primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(tDefaultSize),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              hasAvatar
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
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person,
                                          size: 20, color: primaryColor),
                                    ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.edit,
                                        size: 20, color: primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          children: [
                            Text(
                              data['fullname'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data['username'],
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Tooltip(
                            message: hasFacebook
                                ? '@${data['facebook']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.facebook),
                              color: const Color.fromRGBO(24, 119, 242, 1),
                              onPressed: () async {
                                final facebookUsername = data['facebook'];
                                _launchUrl(
                                    'www.facebook.com/$facebookUsername');
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        InkWell(
                          child: Tooltip(
                            message: hasInstagram
                                ? '@${data['instagram']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.instagram),
                              color: const Color.fromRGBO(225, 48, 108, 1),
                              onPressed: () async {
                                if (hasFacebook) {
                                  final instagramUsername = data['instagram'];
                                  _launchUrl(
                                      'www.instagram.com/$instagramUsername/');
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        InkWell(
                          child: Tooltip(
                            message: hasTwitter
                                ? '@${data['twitter']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.twitter),
                              color: const Color.fromRGBO(29, 161, 242, 1),
                              onPressed: () async {
                                if (hasTwitter) {
                                  final twitterUsername = data['twitter'];
                                  _launchUrl(
                                      'www.twitter.com/$twitterUsername');
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Text(
                          'Sobre',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (hasAbout) Text(data['about']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
