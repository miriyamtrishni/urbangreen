import 'package:flutter/material.dart';

class BusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Screen'),
      ),
      body: Center(
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