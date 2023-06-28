import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vrouter/vrouter.dart';
import 'package:where_are_my_friends/src/constants/color_strings.dart';
import 'package:where_are_my_friends/src/constants/image_strings.dart';
import 'package:where_are_my_friends/src/constants/sizes.dart';
import 'package:where_are_my_friends/src/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSize),
            child: const Column(
              children: [
                LoginHeaderWidget(),
                LoginFormWidget(),
                LoginOther(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SvgPicture.asset(
          loginImage,
          height: size.height * 0.2,
        ),
        const Text('Bem-vindo de volta,',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700)),
        const Text('Busque a sua volta e veja seus amigos.')
      ],
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  LoginFormWidgetState createState() => LoginFormWidgetState();
}

class LoginFormWidgetState extends State<LoginFormWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool obscurePassword = true;

  var formKey = GlobalKey<FormState>();

  void login(BuildContext context) async {
    final vrouter = VRouter.of(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        vrouter.to('/');
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
        child: Column(children: [
          TextFormField(
            onSaved: (value) => email = value!,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu E-mail';
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
              return null;
            },
            onSaved: (value) => password = value!,
            obscureText: obscurePassword,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              label: const Text('Senha'),
              labelStyle: const TextStyle(color: primaryColor),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0, color: primaryColor)),
              prefixIcon: const Icon(Icons.fingerprint, color: primaryColor),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => {VRouter.of(context).to('/password-recovery')},
              child: const Text('Esqueceu a senha ?'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => login(context),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 22.0),
              ),
              child: Text(
                entrar.toUpperCase(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class LoginOther extends StatelessWidget {
  const LoginOther({super.key});

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
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onPressed: () {},
              icon: const Image(
                image: AssetImage(logoGoogle),
                width: 45.0,
              ),
              label: const Text('Entrar com o Google')),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            VRouter.of(context).to('/sign-up');
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Não possui uma conta? ',
                    style: Theme.of(context).textTheme.bodyMedium),
                const TextSpan(text: ' Cadastrar'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
