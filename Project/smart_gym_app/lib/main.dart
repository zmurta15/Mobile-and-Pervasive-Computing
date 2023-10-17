import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gym',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[900],
      ),
      home: const MyHomePage(title: 'Smart Gym'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counterInitial = 0;
  int _enter = 0; //Talvez meter como boolean
  int _lot = 6;

  void _setEnter() {
    setState(() {
      _enter = 1;
    });
  }

  void updateLotacao() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('lotacao/atual');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if(!mounted) return;
      setState(() {
        _lot = int.parse(data.toString());
      });
      _lot++;
    });
    DatabaseReference ref2 = FirebaseDatabase.instance.ref("lotacao");
    ref2.update({
      "atual": _lot
    });
  }

  //Isto provavelemnte vai sair daqui porque as saidas são dadas com sensor
  void _delEnter() {
    setState(() {
      _enter = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Gym'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Smart Gym',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people_sharp),
              title: const Text('Lotação',
                  style: TextStyle(
                    fontSize: 17.0,
            )),
              /*onTap: () {},*/
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LotacaoPage()),
              ),
            ),
            _enter == 1 ? ListTile(
              leading: const Icon(Icons.fitness_center_rounded),
              title: const Text('Reserva de equipamento',
                  style: TextStyle(
                    fontSize: 17.0,
                  )),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservasPage()),
              ),
            ) : ListTile(
                  leading: const Icon(Icons.fitness_center_rounded),
                  title: Text('Reserva de equipamento',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 17.0,
                    )),
            )
            ,ListTile(
              leading: const Icon(Icons.spatial_tracking_rounded),
              title: const Text('Maquinas',
                  style: TextStyle(
                    fontSize: 17.0,
                  )),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MaquinasPage()),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings',
                  style: TextStyle(
                    fontSize: 17.0,
                  )),
              //onTap: () => print("ListTile"),
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child:Container(
                padding: EdgeInsets.fromLTRB(25, 20, 20, 100),
                child: const Text('Bem vindo ao seu Smart Gym',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))),
            const Text(
              'Toque no botão em baixo para validar a sua entrada',
              style: TextStyle(
                //fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton(
                style: TextButton.styleFrom(
                  primary: _enter == 0 ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  if (_enter == 0) {
                    _setEnter();
                    updateLotacao();
                  } else {
                    _delEnter();
                  }
                },
                child: _enter == 0
                    ? Text(
                        'Registar entrada',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // double
                        ),
                      )
                    : Text(
                        'Entrada validada',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // double
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LotacaoPage extends StatefulWidget {


  @override
  State<LotacaoPage> createState() => _LotacaoPageState();
}

class _LotacaoPageState extends State<LotacaoPage> {
  double _lotacaoAtual = 0;
  double _lotacaoMax = 10;
  int _percentagem = 0;

  void updateLotacao() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('lotacao/atual');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if(!mounted) return;
      setState(() {
        _lotacaoAtual = double.parse(data.toString());
      });
    });
  }

  void calculatePercentage() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('lotacao/max');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if(!mounted) return;
      setState(() {
        _lotacaoMax = double.parse(data.toString());
      });
    });
    _percentagem = ((_lotacaoAtual/_lotacaoMax) *100).toInt();
  }


  @override
  Widget build(BuildContext context) {
    updateLotacao();
    calculatePercentage();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotação'),
      ),
      body: Center(
          child: Column (
              children: [
                const Padding(
                  padding: EdgeInsets.all(60),
                  child: const Text('Lotação atual',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: int.parse(_percentagem.toString()) >= 80 ? Colors.red : int.parse(_percentagem.toString()) >= 50 ? Colors.yellow : Colors.green ,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 200,
                  width: 200,
                  margin: EdgeInsets.only(left:20, top:10, right: 20, bottom:10),
                  child: Center(child: Text('${_percentagem.toString()}%',
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ]
          )

        )
      );
  }
}


class ReservasPage extends StatefulWidget {

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }


  final _formKey = GlobalKey<FormState>();
  String _nome = "";
  void getReserva() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('maquina1/nomeReserva');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if(!mounted) return;
      setState(() {
        _nome = data.toString();
      });
    });
  }

  void setReserva(String aux) {
    DatabaseReference ref2 = FirebaseDatabase.instance.ref("maquina1");
    ref2.update({
      "nomeReserva": aux
    });
  }

  @override
  Widget build(BuildContext context) {
    getReserva();
    return Scaffold(
        appBar: AppBar(
          title: Text("Máquinas"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                  child: Text('Passadeira',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              TextFormField(
                controller: myController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.fitness_center_rounded),
                  hintText: 'Escreva o seu nome',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor adicione o seu nome';
                  }
                  if(_nome != "null") {
                    return 'Máquina já se encontra reservada, por favor aguarde.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _nome = myController.text;
                      setReserva(_nome);
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Passadeira reservada por ${_nome}.')),
                      );
                    }
                  },
                  child: Text('Reservar'),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class MaquinasPage extends StatefulWidget {
  @override
  State<MaquinasPage> createState() => _MaquinasPageState();
}

class _MaquinasPageState extends State<MaquinasPage> {
  final List<String> entries = <String>['Passadeira', 'Bicicleta', 'Banco de supino'];
  int _st = 0;
  final List<int> _status = [0, 0, 1];
  void getStatus() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('maquina1/estado');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if(!mounted) return;
      setState(() {
        _st = int.parse(data.toString());
        _status[0] = _st;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getStatus();
    return Scaffold(
      appBar: AppBar(
        title: Text("Máquinas"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: _status[index] == 1 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 50,
            margin: EdgeInsets.only(left:20, top:10, right: 20, bottom:10),
            child: Center(child: Text(entries[index],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      )
    );
  }
}

