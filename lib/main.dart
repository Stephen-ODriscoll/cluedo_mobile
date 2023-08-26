import "package:flutter/material.dart";

import "view/components/custom_text.dart";
import "view/tabs.dart";

import "controller/storage.dart";
import "model/constant.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager().loading; // Load Assets
  runApp(const Cluedo());
}

class Cluedo extends StatelessWidget {
  const Cluedo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = 0xFF600000;
    const int r = 0x60, g = 0x00, b = 0x00;
    const Map<int, Color> colors = {
      50: Color.fromRGBO(r, g, b, .55),
      100: Color.fromRGBO(r, g, b, .6),
      200: Color.fromRGBO(r, g, b, .65),
      300: Color.fromRGBO(r, g, b, .7),
      400: Color.fromRGBO(r, g, b, .75),
      500: Color.fromRGBO(r, g, b, .8),
      600: Color.fromRGBO(r, g, b, .85),
      700: Color.fromRGBO(r, g, b, .9),
      800: Color.fromRGBO(r, g, b, .95),
      900: Color.fromRGBO(r, g, b, 1)
    };

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: const MaterialColor(color, colors),
        primaryColor: const Color.fromRGBO(r, g, b, 1)
      ),
      home: const HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _numPlayers = MIN_PLAYERS;
  String _version = StorageManager().versions.keys.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: _numPlayers,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                for (int i = MIN_PLAYERS; i <= MAX_PLAYERS; ++i) DropdownMenuItem(
                  value: i,
                  child: CustomText("$i Players")
                )
              ],
              onChanged: (int? newNum) {
                setState(() { _numPlayers = newNum!; });
              }
            ),
            DropdownButton(
              value: _version,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                for (final key in StorageManager().versions.keys) DropdownMenuItem(
                  value: key,
                  child: CustomText(key)
                )
              ],
              onChanged: (String? newVersion) {
                setState(() { _version = newVersion!; });
              }
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Tabs(_numPlayers, _version)));
              },
              child: const CustomText('Continue')
            )
          ]
        )
      )
    );
  }
}
