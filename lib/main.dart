import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<Temperatura> buscarTemperatura() async {
  final resposta = await http.get(
      'https://api.hgbrasil.com/weather?key=SUA-CHAVE&city_name=Campinas,SP');
  if (resposta.statusCode == 200) {
    return Temperatura.fromJson(json.decode(resposta.body));
  } else {
    throw Exception('Falha no carregamento');
  }
}

class Objetos {
  final String by;
  final bool validKey;
  final Temperatura results;
  final int excutionTime;
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
  final int velocidadeDoVendo;
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
      this.velocidadeDoVendo,
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
      velocidadeDoVendo: json['wind_speedy'],
      nascerDoSol: json['sunrise'],
      porDoSol: json['sunset'],
      proximosDias: parseProximosDias(json['forecast']),
    );
  }
}

List<ProximosDias> parseProximosDias(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<ProximosDias>((json) => ProximosDias.fromJson(json))
      .toList();
}

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
  Future<Temperatura> temperatura;
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return FutureBuilder(
                          future: temperatura,
                          builder: (context, dados) {
                            if (dados.hasData) {
                              return Scaffold(
                                appBar: AppBar(
                                  leading: IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  title: Text(dados.data.nomeDaCidade),
                                ),
                                body: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(dados.data.periodoAtual),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.brightness_3),
                                        ),
                                      ]),
                                  SizedBox(height: 120),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Text(dados.data.temperatura),
                                          Text(dados.data.condicoesAtual)
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text('19:00'),
                                          Text('10/01/2020'),
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
                                          Text('8km/h'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 80.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Text('Umid. do Ar'),
                                          Text('60%'),
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text('5:32 am'),
                                          Text('6:00 pm'),
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
                                          _ProxDias();
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
                      }),
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

  // void _Home() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(builder: (BuildContext context) {
  //       return Scaffold(
  //         appBar: AppBar(
  //           leading: IconButton(
  //             icon: Icon(Icons.arrow_back),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //           title: Text('Rio Largo'),
  //         ),
  //         body: Column(children: [
  //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //             Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Text('Rio Largo'),
  //               ],
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Icon(Icons.brightness_3),
  //             ),
  //           ]),
  //           SizedBox(height: 120),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: <Widget>[
  //               Column(
  //                 children: <Widget>[Text('25°'), Text('Nublado')],
  //               ),
  //               Column(
  //                 children: <Widget>[
  //                   Text('19:00'),
  //                   Text('10/01/2020'),
  //                 ],
  //               )
  //             ],
  //           ),
  //           SizedBox(height: 80.0),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Column(
  //                 children: <Widget>[
  //                   Text('Velocidade do Vento'),
  //                   Text('8km/h'),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 80.0),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: <Widget>[
  //               Column(
  //                 children: <Widget>[
  //                   Text('Umid. do Ar'),
  //                   Text('60%'),
  //                 ],
  //               ),
  //               Column(
  //                 children: <Widget>[
  //                   Text('5:32 am'),
  //                   Text('6:00 pm'),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 80.0),
  //           ButtonBar(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               RaisedButton(
  //                 child: Text('PRÓXIMOS DIAS'),
  //                 onPressed: () {
  //                   _ProxDias();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ]),
  //       );
  //     }),
  //   );
  // }

  void _ProxDias() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: ListView(
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text('seg 06/01'),
                  subtitle: Text('Tempestade'),
                  trailing: Column(
                    children: <Widget>[
                      Text('Min 20'),
                      SizedBox(
                        height: 8,
                      ),
                      Text('Max 30'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
