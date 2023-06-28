import 'package:flutter/material.dart';
import 'package:where_are_my_friends/src/authentication/confirm_screen.dart';
import 'package:where_are_my_friends/src/authentication/login_screen.dart';
import 'package:where_are_my_friends/src/authentication/recovery_screen.dart';
import 'package:where_are_my_friends/src/authentication/signup_screen.dart';
import 'package:where_are_my_friends/src/authentication/welcome_screen.dart';
import 'package:where_are_my_friends/src/home/home_screen.dart';
import 'package:where_are_my_friends/src/home/principal_screen.dart';
import 'package:where_are_my_friends/src/home/profile_screen.dart';
import 'package:where_are_my_friends/src/home/search_screen.dart';
import 'package:where_are_my_friends/src/home/user_profile_screen.dart';

import 'package:vrouter/vrouter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return VRouter(
      buildTransition: (animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      title: '',
      theme: ThemeData(), //trabalhar no tema
      initialUrl: '/welcome',
      debugShowCheckedModeBanner: false,
      routes: [
        VWidget(path: '/welcome', widget: const WelcomeScreen()),
        VWidget(path: '/login', widget: const LoginScreen()),
        VWidget(path: '/sign-up', widget: const SignUpScreen()),
        VWidget(path: '/confirm', widget: const ConfirmScreen()),
        VWidget(
            path: '/password-recovery', widget: const PasswordRecoveryScreen()),
        VGuard(
          beforeEnter: (vRedirector) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return vRedirector.to('/login', isReplacement: true);
            }
          },
          stackedRoutes: [
            VNester(
              path: '/',
              widgetBuilder: (child) => HomePageScreen(child),
              nestedRoutes: [
                VWidget(path: '/', widget: const PrincipalScreen()),
                VWidget(path: '/profile', widget: const ProfileScreen()),
                VWidget(path: '/search', widget: const SearchScreen()),
                VWidget.builder(
                  path: '/user/:username',
                  builder: (context, state) => UserProfileScreen(
                      username: state.pathParameters['username'] as String),
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}
