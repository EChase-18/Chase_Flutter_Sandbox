import 'dart:convert';
import 'dart:isolate';

import 'package:chase_sandbox_one/isolate_data_object.dart';
import 'package:chase_sandbox_one/the_matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey(debugLabel: "Happy Key");

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          // pageBuilder: (context, state) => NoTransitionPage<void>(
          //   key: state.pageKey,
          //   child: const HomeScreen(),
          // ),
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const HomeScreen(),
            transitionDuration: const Duration(seconds: 5),
            transitionsBuilder: (context, anim1, anim2, child) =>
                SizeTransition(
              sizeFactor: anim1,
              axis: Axis.vertical,
              axisAlignment: 1.0,
              child: child,
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              // pageBuilder: (context, state) => NoTransitionPage<void>(
              //   key: state.pageKey,
              //   child: const DetailScreen(),
              // ),
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const DetailScreen(),
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (context, anim1, anim2, child) =>
                    FadeTransition(
                  opacity: anim1,
                  child: child,
                ),
              ),
              // builder: (context, state) => const DetailScreen(),
            ),
            GoRoute(
              path: 'modal',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: ModalScreen(),
              ),
            )
          ],
        ),
      ],
    );
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff242526),
      ),
      drawer: Drawer(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/detail');
                },
                child: const CenteredText("Detail"),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => context.go('/modal'),
                child: const CenteredText('Modal'),
              )
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xff242526),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/detail'),
                child: const CenteredText('go /detail'),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => context.push('/detail'),
                child: const CenteredText('push /detail'),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => context.go('/modal'),
                child: const CenteredText('go /modal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const CenteredText('Back'),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => context.go('/modal'),
                child: const CenteredText('go /modal'),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => context.push('/modal'),
                child: const CenteredText('push /modal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModalScreen extends StatelessWidget {
  const ModalScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> messWithIsolates() async {
    final newPort = ReceivePort();
    // ignore: avoid_print
    print("Main Isolate: Sending Port to Child Isolate");
    final jsonStuff = await rootBundle.loadString('json_baseball.json');
    final isolateObject =
        IsolateDataObject(jsonData: jsonStuff, newSendPort: newPort.sendPort);
    await Isolate.spawn(childIsolateWork, isolateObject);
    // ignore: avoid_print
    print("Main Isolate: Waiting for Child Isolate");
    return await newPort.first as Map<String, dynamic>;
  }

  Future<void> childIsolateWork(IsolateDataObject data) async {
    // ignore: avoid_print
    debugPrint("Child Isolate Started");
    final stuff = jsonDecode(data.jsonData);
    // final stuff = await rootBundle.loadString('json1.json');
    debugPrint("Child Isolate: Parsed Json File");
    final anotherPort = ReceivePort();
    await Isolate.spawn(secondChildIsolateWork, anotherPort.sendPort);
    await Future.delayed(const Duration(seconds: 4));
    debugPrint("Child Isolate: Checkpoint 1");
    // newSendPort.send(stuff);
    Isolate.exit(data.newSendPort, stuff);
  }

  Future<void> secondChildIsolateWork(SendPort newPort) async {
    debugPrint("Child Isolate 2: Started");
    await Future.delayed(const Duration(seconds: 2));
    debugPrint("Child Isolate 2: Checkpoint 1");
    await Future.delayed(const Duration(seconds: 4));
    debugPrint("Child Isolate 2: Checkpoint 2");
    Isolate.exit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modal Page'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var something = await messWithIsolates();
            debugPrint("Received a json");
            something.forEach((key, value) {
              debugPrint("Following: $key, $value");
            });
          },
          child: const Text("Test Isolates"),
        ),
      ),
    );
  }
}

class CenteredText extends StatelessWidget {
  const CenteredText(this.text, {Key? key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 30),
      textAlign: TextAlign.center,
    );
  }
}

//-------------------------------------------------------------------------------------------------------------

// void main() {
//   runApp(MyApp());
// }

class MyOneApp extends StatelessWidget {
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
              navKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (_) => TheMatrix()));
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
