import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<Objetos> buscarTemperatura(String cidade) async {
  final resposta = await http.get(
      'https://api.hgbrasil.com/weather?key=312a05a8&city_name=${Uri.encodeQueryComponent(cidade)}');
  if (resposta.statusCode == 200) {
    return Objetos.fromJson(json.decode(resposta.body));
  } else {
    throw Exception('Falha no carregamento');
  }
}

class Objetos {
  final String by;
  final bool validKey;
  final Temperatura results;
  final double excutionTime;
  final bool fromCache;

  Objetos(
      {this.by,
      this.validKey,
      this.results,
      this.excutionTime,
      this.fromCache});

  factory Objetos.fromJson(Map<String, dynamic> json) {
    return Objetos(
        by: json['by'],
        validKey: json['valid_key'],
        results: Temperatura.fromJson(json['results']),
        excutionTime: json['execution_time'],
        fromCache: json['from_cache']);
  }
}

class Temperatura {
  final int temperatura;
  final String nomeDaCidade;
  final String condicoesAtual;
  final String data;
  final String hora;
  final String periodoAtual;
  final int umidadeDoAr;
  final String velocidadeDoVento;
  final String nascerDoSol;
  final String porDoSol;
  final List<ProximosDias> proximosDias;

  Temperatura(
      {this.temperatura,
      this.nomeDaCidade,
      this.condicoesAtual,
      this.data,
      this.hora,
      this.periodoAtual,
      this.nascerDoSol,
      this.porDoSol,
      this.umidadeDoAr,
      this.velocidadeDoVento,
      this.proximosDias});
  factory Temperatura.fromJson(Map<String, dynamic> json) {
    return Temperatura(
      temperatura: json['temp'],
      nomeDaCidade: json['city_name'],
      condicoesAtual: json['description'],
      periodoAtual: json['currently'],
      data: json['date'],
      hora: json['time'],
      umidadeDoAr: json['humidity'],
      velocidadeDoVento: json['wind_speedy'],
      nascerDoSol: json['sunrise'],
      porDoSol: json['sunset'],
      proximosDias: (json['forecast'])
          .map<ProximosDias>((json) => ProximosDias.fromJson(json))
          .toList(),
    );
  }
}

// List<ProximosDias> parseProximosDias(Map<String, dynamic> responseBody) {
//   return responseBody.map<ProximosDias>((json) => ProximosDias.fromJson(json)).toList();
// }

class ProximosDias {
  final String data;
  final String diaSemana;
  final int max;
  final int min;
  final String previsao;

  ProximosDias({this.data, this.diaSemana, this.max, this.min, this.previsao});
  factory ProximosDias.fromJson(Map<String, dynamic> json) {
    return ProximosDias(
        data: json['date'],
        diaSemana: json['weekday'],
        max: json['max'],
        min: json['min'],
        previsao: json['description']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Forecast(),
    );
  }
}

void main() => runApp(MyApp());

class Forecast extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _ForecastState createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final _nomeDaCidadeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Icon(Icons.brightness_high),
                SizedBox(
                  height: 16.0,
                ),
                Text("ForeCast")
              ],
            ),
            SizedBox(height: 120.0),
            TextField(
              controller: _nomeDaCidadeController,
              decoration:
                  InputDecoration(filled: true, labelText: "Nome da Cidade"),
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text("LIMPA"),
                  onPressed: () {
                    _nomeDaCidadeController.clear();
                  },
                ),
                RaisedButton(
                  child: Text("BUSCA"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(_nomeDaCidadeController.text)),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String cidade;

  HomeScreen(this.cidade);

  @override
  _HomeScreenState createState() => _HomeScreenState(this.cidade);
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Objetos> objetos;
  final String cidade;
  List<ProximosDias> proximos;

  _HomeScreenState(this.cidade);
  @override
  void initState() {
    super.initState();
    objetos = buscarTemperatura(cidade);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: objetos,
      builder: (context, dados) {
        if (dados.hasData) {
          Objetos objetos = dados.data;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(objetos.results.nomeDaCidade),
            ),
            body: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(objetos.results.periodoAtual),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.brightness_3),
                ),
              ]),
              SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(objetos.results.temperatura.toString() + '°'),
                      Text(objetos.results.condicoesAtual)
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(objetos.results.hora),
                      Text(objetos.results.data),
                    ],
                  )
                ],
              ),
              SizedBox(height: 80.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('Velocidade do Vento'),
                      Text(objetos.results.velocidadeDoVento),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 80.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('Umid. do Ar'),
                      Text(objetos.results.umidadeDoAr.toString() + '%'),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(objetos.results.nascerDoSol),
                      Text(objetos.results.porDoSol),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 80.0),
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
                    child: Text('PRÓXIMOS DIAS'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProxDiasScreen(
                            proxDias: objetos.results.proximosDias,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ]),
          );
        } else if (dados.hasError) {
          return Text('${dados.error}');
        }

        return CircularProgressIndicator();
      },
    );
  }
}
// A parte de mostrar os próximos dias está com problema no layout

class ProxDiasScreen extends StatelessWidget {
  final List<ProximosDias> proxDias;

  const ProxDiasScreen({Key key, this.proxDias}) : super(key: key);
  Widget _builderProximosDiasItem(BuildContext context, int index) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Card(
        child: ListTile(
          title: Text(
              proxDias[index].diaSemana + ' ' + ' ' + proxDias[index].data),
          subtitle: Text(proxDias[index].previsao),
          trailing: Column(
            children: <Widget>[
              Text('Min ' + proxDias[index].min.toString()),
              SizedBox(
                height: 8,
              ),
              Text('Max ' + proxDias[index].max.toString()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: proxDias.length, itemBuilder: (context, ProximosDias) {});
  }
}
