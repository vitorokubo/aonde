import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vrouter/vrouter.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/image_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';
import 'package:where_are_my_friends/src/constants/text_strings.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSize),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignUpHeaderWidget(),
                SignUpFormWidget(),
                SignUpOther(),
                // LoginFooterWidge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpHeaderWidget extends StatelessWidget {
  const SignUpHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            logoColor,
            height: size.height * 0.2,
          ),
          const Text(
            'Junte-se a nós',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          ),
          Text(
            'Crie uma conta e veja onde as pessoas circulam',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  static final RegExp fullNameRegExp =
      RegExp(r'^[A-Z][a-zA-Z]*(\s[A-Z][a-zA-Z]*)?$');
  static final RegExp userNameRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();

  String fullname = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório.';
    }
    if (value != password) {
      return 'As senhas não correspondem.';
    }
    return null;
  }

  void register(BuildContext context) async {
    final vrouter = VRouter.of(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          throw Exception('Usuário em uso');
        }

        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        firestore
            .collection('users')
            .doc(auth.currentUser?.uid)
            .set({'fullname': fullname, 'username': username, 'email': email});
        vrouter.to('/confirm');
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro de registro'),
              content:
                  Text('Ocorreu um erro ao registrar o usuário. $e.message'),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: tDefaultSize - 10),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onSaved: (value) => fullname = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu nome';
                }
                return SignUpFormWidget.fullNameRegExp.hasMatch(value)
                    ? null
                    : 'Primeira letra maiuscula e não pode conter caracteres especiais';
              },
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
                  Icons.account_circle,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onSaved: (value) => username = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu nome de usuário';
                }
                if (!SignUpFormWidget.userNameRegExp.hasMatch(value)) {
                  return 'Não pode conter caracteres especiais';
                }
                return null;
              },
              decoration: const InputDecoration(
                label: Text('Usuário'),
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
                  Icons.alternate_email,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onSaved: (value) => email = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Campo obrigatório";
                }
                return null;
              },
              decoration: const InputDecoration(
                label: Text('E-mail'),
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
                  Icons.email,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Campo obrigatório.";
                }
                if (value.length < 6) {
                  return "Campo deve conter no mínimo 6 caracteres.";
                }
                return null;
              },
              onSaved: (value) => password = value!,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                label: Text('Senha'),
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: primaryColor)),
                prefixIcon: Icon(Icons.fingerprint, color: primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Campo obrigatório";
                }
                validateConfirmPassword(value);

                return null;
              },
              onSaved: (value) => confirmPassword = value!,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                label: Text('Confirmar Senha'),
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: primaryColor)),
                prefixIcon: Icon(Icons.password_outlined, color: primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => register(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                ),
                child: Text(cadastrar.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpOther extends StatelessWidget {
  const SignUpOther({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ou',
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              icon: const Image(
                image: AssetImage(logoGoogle),
                width: 45.0,
              ),
              label: const Text('Cadastre-se com o Google')),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            VRouter.of(context).to('/login');
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Já possui uma conta? ',
                    style: Theme.of(context).textTheme.bodyMedium),
                const TextSpan(text: ' Entrar'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
