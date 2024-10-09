import 'package:flutter/material.dart';

class BusScreen extends StatelessWidget {
  const BusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the Bus Screen!'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BusScreen(),
  ));
}