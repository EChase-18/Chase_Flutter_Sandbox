import 'package:chase_sandbox_one/the_matrix.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey(debugLabel: "Happy Key");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      home: MyFirstApp(),
      title: 'ChaseSandbox',
    );
  }
}

class MyFirstApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyFirstApp();
}

class _MyFirstApp extends State<MyFirstApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffc2b280),
        title: const Text("Chase Sandbox"),
        actions: [
          IconButton(
            onPressed: () {
              navKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => TheMatrix()));
            },
            icon: const Icon(Icons.grid_4x4),
          ),
        ],
      ),
      body: Center(
        child: Draggable<String>(
          feedback: ClipRRect(
            borderRadius: BorderRadius.circular(60.0),
            child: Image.asset(
              'images/awesome_sand_3000.jpg',
              height: 200,
              width: 200,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.0),
            child: Image.asset(
              'images/awesome_sand_3000.jpg',
              height: 200,
              width: 200,
            ),
          ),
          childWhenDragging: Container(),
        ),
      ),
    );
  }
}
