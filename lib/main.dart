import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const DailyGratitudeApp());

class DailyGratitudeApp extends StatelessWidget {
  const DailyGratitudeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Journal',
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
                'What are your thoughts today?',
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
  int _addEntryClickCount = 0;
  int _viewJournalClickCount = 0;

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8816215996841265/1305249671',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) =>
            print('Failed to load interstitial ad: $error'),
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter your thoughts here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (_controller.text.isEmpty) {
             await Fluttertoast.showToast(
                  msg: "Enter something!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  fontSize: 16.0);
              return;
            }
            _addEntryClickCount++;
            if (_addEntryClickCount % 4 == 0) {
              _saveGratitude(_controller.text);
              _controller.clear();
              _showInterstitialAd();
            } else {
              _saveGratitude(_controller.text);
              _controller.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'Add Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _viewJournalClickCount++;
            if (_viewJournalClickCount % 4 == 0) {
              _showInterstitialAd();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GratitudeLog(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GratitudeLog(),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'View Journal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
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
  GratitudeLogState createState() => GratitudeLogState();
}

class GratitudeLogState extends State<GratitudeLog> {
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
        title: const Text('Journal'),
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
                  final date =
                      (snapshot.data!.keys.toList().reversed).elementAt(index);
                  final gratitudeList =
                      (snapshot.data![date]!).reversed.toList();
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
                          final message = gratitude.split(': ')[1].trimRight();

                          return ListTile(
                            title: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
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
      final gratitudeList = contents
          .split(RegExp(r'\n(?=\w{3} \d{1,2}, \d{4})'))
          .where((element) => element.isNotEmpty)
          .toList();

      final gratitudeMap = <String, List<String>>{};
      for (final gratitude in gratitudeList) {
        final date = gratitude.split(', ')[0];
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
      final newContents =
          contents.replaceAll('$gratitude\n', '').replaceAll(gratitude, '');
      await file.writeAsString(newContents);
    }
  }
}
