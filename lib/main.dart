import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() => runApp(const DailyGratitudeApp());

class DailyGratitudeApp extends StatelessWidget {
  const DailyGratitudeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Gratitude',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E90FF),
              Color(0xFF00BFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'What are you grateful for today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: GratitudeInput(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GratitudeInput extends StatefulWidget {
  const GratitudeInput({Key? key}) : super(key: key);

  @override
  GratitudeInputState createState() => GratitudeInputState();
}

class GratitudeInputState extends State<GratitudeInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Enter your gratitude here',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            _saveGratitude(value);
            _controller.clear();
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GratitudeLog(),
              ),
            );
          },
          child: const Text('View Gratitude Log'),
        ),
      ],
    );
  }

  void _saveGratitude(String gratitude) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy h:mm a').format(now);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gratitude.txt');
    await file.writeAsString('$formattedDate: $gratitude\n',
        mode: FileMode.append);
  }
}

class GratitudeLog extends StatefulWidget {
  const GratitudeLog({Key? key}) : super(key: key);

  @override
  _GratitudeLogState createState() => _GratitudeLogState();
}

class _GratitudeLogState extends State<GratitudeLog> {
  late Future<Map<String, List<String>>> _gratitudeMap;

  @override
  void initState() {
    super.initState();
    _gratitudeMap = _readGratitude();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude Log'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: FutureBuilder(
          future: _gratitudeMap,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, List<String>>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final date = snapshot.data!.keys.elementAt(index);
                  final gratitudeList = snapshot.data![date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gratitudeList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final gratitude = gratitudeList[index];
                          final time = gratitude.split(': ')[0];
                          final message = gratitude.split(': ')[1];
                          return ListTile(
                            title: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontStyle: FontStyle
                                    .italic, // Add this line to make the time italic
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                _deleteGratitude(date, gratitude).then((_) {
                                  setState(() {
                                    _gratitudeMap = _readGratitude();
                                  });
                                });
                              },
                              splashColor: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ), // Add this line to make the icon responsive
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, List<String>>> _readGratitude() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gratitude.txt');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final gratitudeList =
          contents.split('\n').where((element) => element.isNotEmpty).toList();
      final gratitudeMap = <String, List<String>>{};
      for (final gratitude in gratitudeList) {
        final date = gratitude.split(': ')[0].split(' ')[0];
        if (gratitudeMap.containsKey(date)) {
          gratitudeMap[date]!.add(gratitude);
        } else {
          gratitudeMap[date] = [gratitude];
        }
      }
      return gratitudeMap;
    } else {
      return {'No gratitude recorded yet.': []};
    }
  }

  Future<void> _deleteGratitude(String date, String gratitude) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gratitude.txt');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final newContents = contents.replaceAll('$gratitude\n', '');
      await file.writeAsString(newContents);
    }
  }
}
