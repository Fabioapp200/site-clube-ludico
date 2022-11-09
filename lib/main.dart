import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Map<String, dynamic>> gameList = [];
  List<Map<String, dynamic>> gameListReset = [];
  List<Map<String, dynamic>> tempFilteredGameList = [];
  List filteredGameList = [];

  final TextEditingController textEditingController = TextEditingController();

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
      filteredGameList = games.toList();
      for (var game in filteredGameList) {
        final id = game.getAttribute('objectid');
        final name = game.getElement('name')?.innerText;
        final image = game.getElement('image')?.innerText;
        final thumbnail = game.getElement('thumbnail')?.innerText;
        final year = game.getElement('yearpublished')?.innerText;
        if (id != null) {
          gameList.add({
            'id': id,
            'name': name,
            'year': year,
            'thumbnail': thumbnail,
          });
          setState(() {
            gameListReset.addAll(gameList);
          });
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
    final width = MediaQuery.of(context).size.width;
    final bool mobile = width < 768;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clube Lúdico',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Row(
              children: [
                if (!mobile) Spacer(),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      labelText: "Procurar Jogos",
                      hintText: "Procurar Jogos",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      gameList.clear();
                      tempFilteredGameList.clear();
                      gameList.addAll(gameListReset);

                      gameList.forEach((element) {
                        final gameName = element['name'].toLowerCase();
                        final searchedValue = value.toLowerCase();
                        if (gameName.contains(searchedValue) && !tempFilteredGameList.contains(element)) {
                          tempFilteredGameList.add(element);
                        }
                      });
                      gameList.clear();
                      gameList.addAll(tempFilteredGameList);
                      setState(() {});
                    },

                  ),
                ),
                if (!mobile) Spacer(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gameList.length,
              itemBuilder: (context, index) {
                final x = gameList[index];
                return GameTile(
                  id: x['id']?? '',
                  name: x['name']?? '',
                  year: x['year']?? '',
                  thumbnail: x['thumbnail']?? '',
                );
              },
            ),
          ),
        ],
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
    final width = MediaQuery.of(context).size.width;
    final bool mobile = width < 768;
    final double thumbnailSize = width * 0.175;

    topPadding() {
      if (mobile) {
        return 0.0;
      } else {
        return 0.0;
      }
    }

    double titleSize() {
      if (mobile) {
        return 20;
      } else {
        return 36;
      }
    }

    double elevatedButtonPadding() {
      if (mobile) {
        return 2;
      } else {
        return 32;
      }
    }

    return Row(
      children: [
        if (!mobile) Spacer(),
        Expanded(
          flex: 10,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            thumbnail!,
                            height: thumbnailSize,
                            width: thumbnailSize,
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(top: topPadding()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name!,
                                  style: TextStyle(fontSize: titleSize()),
                                ),
                                Text(year!)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: elevatedButtonPadding()),
                    child: ElevatedButton(
                      onPressed: () async {
                        const phone = '5519983162442';

                        final message = 'Olá! Acabei de achar o jogo $name'
                            ' no site do Clube Lúdico e gostaria de saber'
                            ' se ele está disponível para aluguel.';

                        final Uri url =
                            Uri.parse('https://wa.me/$phone?text=$message');

                        await launchUrl(url);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Flex(
                          direction: mobile ? Axis.vertical : Axis.horizontal,
                          children: const [
                            Text('Quero '),
                            Text('Jogar'),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(
                thickness: 2,
                indent: 50,
                endIndent: 50,
              ),
            ],
          ),
        ),
        if (!mobile) Spacer()
      ],
    );
  }
}

class Spacer extends StatelessWidget {
  const Spacer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(),
    );
  }
}
