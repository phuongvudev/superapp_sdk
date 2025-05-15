import 'package:app/di/di.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount:
                    appManager.superAppKit.miniApp.registeredMiniApps.length,
                itemBuilder: (context, index) {
                  final miniApp =
                      appManager.superAppKit.miniApp.registeredMiniApps[index];
                  return ListTile(
                    leading: Image.network(
                      miniApp.appIcon ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    title: Text(miniApp.name),
                    subtitle: Text(miniApp.description ?? ''),
                    onTap: () {
                      // Handle mini app tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
