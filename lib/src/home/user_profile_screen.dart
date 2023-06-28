import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;

  const UserProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse("https://$url");
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "can not launch url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: firestore
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Erro ao carregar os dados do Firebase');
        }
        if (!snapshot.hasData || snapshot.data!.size == 0) {
          return const Text('Não há dados disponíveis');
        }

        Map<String, dynamic>? userData =
            snapshot.data!.docs[0].data() as Map<String, dynamic>;

        final bool hasFacebook = userData.containsKey('facebook');
        final bool hasInstagram = userData.containsKey('instagram');
        final bool hasTwitter = userData.containsKey('twitter');
        final bool hasAbout = userData.containsKey('twitter');
        final bool hasAvatarUrl = userData.containsKey('avatarUrl');

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(userData['fullname']),
              backgroundColor: primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {},
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
                          child: InkWell(
                            onTap: () {},
                            child: hasAvatarUrl
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey,
                                    foregroundImage: NetworkImage(
                                      userData[
                                          'avatarUrl'], // URL da imagem do Firebase Storage
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: primaryColor,
                                    child: Icon(Icons.person, size: 30),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          children: [
                            Text(
                              userData['fullname'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              userData['username'],
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
                                ? '@${userData['facebook']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.facebook),
                              color: const Color.fromRGBO(24, 119, 242, 1),
                              onPressed: () async {
                                final facebookUsername = userData['facebook'];
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
                                ? '@${userData['instagram']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.instagram),
                              color: const Color.fromRGBO(225, 48, 108, 1),
                              onPressed: () async {
                                final instagramUsername = userData['instagram'];
                                _launchUrl(
                                    'www.instagram.com/$instagramUsername/');
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        InkWell(
                          child: Tooltip(
                            message: hasTwitter
                                ? '@${userData['twitter']}'
                                : 'Não cadastrado',
                            child: IconButton(
                              icon: const Icon(FontAwesomeIcons.twitter),
                              color: const Color.fromRGBO(29, 161, 242, 1),
                              onPressed: () async {
                                final twitterUsername = userData['twitter'];
                                _launchUrl('www.twitter.com/$twitterUsername');
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
                        if (hasAbout) Text(userData['about']),
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
