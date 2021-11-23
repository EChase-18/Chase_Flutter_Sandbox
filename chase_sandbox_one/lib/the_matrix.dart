import 'package:chase_sandbox_one/main.dart';
import 'package:flutter/material.dart';

class TheMatrix extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TheMatrix();
}

class _TheMatrix extends State<TheMatrix> {
  double x = 0;
  double y = 0;
  double z = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amberAccent,
        title: const Text("The Matrix"),
        leading: IconButton(
          onPressed: () {
            navKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => MyFirstApp()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Transform(
          transform: Matrix4(
            1,
            0,
            0,
            0,
            0,
            1,
            0,
            0.03,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            1,
          )
            ..rotateX(x)
            ..rotateY(y)
            ..rotateZ(z),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                x = x + details.delta.dy / 100;
                y = y - details.delta.dx / 100;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60.0),
              child: Image.asset(
                'images/awesome_sand_3000.jpg',
                height: 200,
                width: 200,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
