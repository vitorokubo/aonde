import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vrouter/vrouter.dart';

class HomePageScreen extends StatefulWidget {
  final Widget child;
  const HomePageScreen(this.child, {super.key});

  @override
  HomePageScreenState createState() => HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen> {
  int _currentIndex = 1;

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.vRouter.to('/search');
        break;
      case 1:
        context.vRouter.to('/');
        break;
      case 2:
        context.vRouter.to('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _onTabSelected(context, index);
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: const Text('Buscar'),
            selectedColor: Colors.red, // Cor quando selecionado
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Principal'),
            selectedColor: Colors.blue, // Cor quando selecionado
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text('Perfil'),
            selectedColor: Colors.green, // Cor quando selecionado
          ),
        ],
      ),
    );
  }
}
