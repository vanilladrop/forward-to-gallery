import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forward to Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: SharedItemPage(),
    );
  }
}

class SharedItemPage extends StatefulWidget {
  @override
  _SharedItemPageState createState() => _SharedItemPageState();
}

class _SharedItemPageState extends State<SharedItemPage> {
  late StreamSubscription _intentSubscription;
  final _sharedMedia = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSubscription = ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        _sharedMedia.clear();
        _sharedMedia.addAll(value);

        print(_sharedMedia.map((media) => media.toMap()));
      });
    }, onError: (error) {
      print("getIntentDataStream error: $error");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.getInitialMedia().then((media) => {
          setState(() {
            _sharedMedia.clear();
            _sharedMedia.addAll(media);
            print(_sharedMedia.map((media) => media.toMap()));

            // Tell the library that we are done processing the intent.
            ReceiveSharingIntent.reset();
          })
        });
  }

  @override
  void dispose() {
    _intentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Share Intent"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  //If there's no shared media, we assume the app was launched by itself. Thus, we tell the user to share media to it.
                  //If there's media, we display the path to it.
                  children: _sharedMedia.isEmpty
                      ? <Widget>[
                          const Text(
                            'This app is intended to be used via your phone\'s sharing/forwarding functionality.\n\nTry sharing an image or video file to this app!',
                            style: TextStyle(fontSize: 25.0),
                            textAlign: TextAlign.center,
                          ),
                        ]
                      : <Widget>[
                          const Text('Shared media:',
                              style: TextStyle(fontSize: 25.0),
                              textAlign: TextAlign.center),
                          Text(_sharedMedia
                              .map((files) => files.toMap())
                              .join(",\n----------\n"))
                        ],
                )),
          ],
        ),
      ),
    );
  }
}
