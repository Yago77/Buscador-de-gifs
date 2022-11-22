import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lista_de_tarefas/pages/gif_page.dart';
import 'package:flutter_share/flutter_share.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? search;

  int offset = 0;
  Future<Map> getGifs() async {
    http.Response response;

    if (search == null) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=BSWvU0HWvuemCHMlnNWnVsdMDKB7eFZ6&limit=30&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=BSWvU0HWvuemCHMlnNWnVsdMDKB7eFZ6&q=$search&limit=29&offset=$offset&rating=g&lang=en"));
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(),
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int getCount(List data) {
    if (search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) =>
                      GifPage(gifData: snapshot.data["data"][index])),
                ),
              );
            },
            onLongPress: () {
              share(snapshot.data['data'][index]['images']['fixed_height']
                      ['url']
                  .toString());
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  "Carregar mais...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                )
              ],
            ),
            onTap: () {
              setState(() {
                offset += 29;
              });
            },
          );
        }
      },
    );
  }

  Future share(String link) async {
    await FlutterShare.share(
        title: "Compartilhar Gif",
        text: "Compartilhe com quem quiser esse gif",
        linkUrl: link,
        chooserTitle: null);
  }
}
