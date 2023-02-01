import 'dart:convert';

import 'package:consumiendo_api_rest/model/Gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //1. Hacemos una espera de petición con Future
  late Future<List<Gif>> _listadoGifs;
  //1.1. Creamos una función que nos devuelvo ese valor
  Future<List<Gif>> _getGifs() async {
    //1.2. await nos sirve para hacer esa espera
    //1.3. Para que podamos traer el link si progrmaa debemos colocarlo dentro del Uri.dataFromString
    var urlLink = Uri.parse(
        "https://api.giphy.com/v1/gifs/trending?api_key=krkMOOfWrkatvx3M1cw3G04tqoWMwOBA&limit=10&rating=g");
    final response = await http.get(urlLink);

//1.4. Creamos un ararys vacío de una lista de Gif
    List<Gif> gifs = [];
    if (response.statusCode == 200) {
      //print(response.body);
      String body = utf8
          .decode(response.bodyBytes); //Para asegurarnos que esté codificado
      //convertimos el string a json
      final jsonData = jsonDecode(body);
      for (var item in jsonData["data"]) {
        gifs.add(
          Gif(item["title"], item["images"]["downsized"]["url"]),
        );
      }
      return gifs;
      // print(jsonData["data"][0]["type"]);
    } else {
      throw Exception("Error a la hora de conectar");
    }
  }

  //1.4. El Init state es una función que se ejecuta cuadno se abre una pantalla
  @override
  void initState() {
    super.initState();
    //1.4.1. Llamamos a la función
    //1.6. Una vez acabado todo hacemos una referencia
    _listadoGifs = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        //2. Una vez que tengamos la lógica empezamos con el diseño
        // creamos un future builder que recibirá al listado de gifs
        body: FutureBuilder(
          future: _listadoGifs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              //  return Text('Correcto');
              //2.1 Una vez que se comprobró que todo está bien, vamos a delvover una lista
              return GridView.count(
                crossAxisCount: 2, //Para dividir los elementos en dos
                children: _listGifs(snapshot.data as List<Gif>),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error');
            }
            // ignore: prefer_const_constructors
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
        ),
        /*
        FutureBuilder(
          future: _listadoGifs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return Text('Correcto');
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error');
            }
            // ignore: prefer_const_constructors
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
        ), */
      ),
    );
  }
}

//2.3. Creamos una lista para colocarlo en la lista valga la redundancia
List<Widget> _listGifs(List<Gif> data) {
  List<Widget> gifs = [];
  //2.3.1. Lo recorremos con un for in
  for (var gif in data) {
    gifs.add(Card(
        child: Column(
      children: [
        //Para ver el img
        Image.network(gif.url),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(gif.name),
        ),
      ],
    )));
  }
  return gifs;
}
