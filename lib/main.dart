import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clube Lúdico',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> gameList = [];

  getData() async {
    var request = Request(
        'GET',
        Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=clubeludico'));

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      final document = XmlDocument.parse(str).getElement('items');
      final games = document!.children;
      for (var game in games) {
        final id = game.getAttribute('objectid');
        final name = game.getElement('name')?.innerText;
        final image = game.getElement('image')?.innerText;
        final thumbnail = game.getElement('thumbnail')?.innerText;
        final year = game.getElement('yearpublished')?.innerText;
        if (id != null) {
          gameList.add(GameTile(
            id: id,
            name: name,
            year: year,
            thumbnail: thumbnail,
          ));
          setState(() {});
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clube Lúdico',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: gameList,
          ),
        ),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile({
    Key? key,
    required this.id,
    required this.name,
    required this.year,
    required this.thumbnail,
  }) : super(key: key);

  final String? id;
  final String? name;
  final String? year;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(name!),
          leading: SizedBox(
            height: 350,
            width: 350,
            child: Image.network(
              thumbnail!,
              scale: 2,
            ),
          ),
        ),
        Divider(
          thickness: 2,
        )
      ],
    );
  }
}
