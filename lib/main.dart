import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline OCR',
      home: MyHomePage(title: 'Offline OCR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic _pickImageError;
  String _retrieveDataError;
  String _extractedText;
  final ImagePicker _picker = ImagePicker();

  // receive intent
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
          if (value.isNotEmpty) {
            _onImageReceived(value[0]);
          }
        }, onError: (err) {
          print("getIntentDataStream error: $err");
        });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _onImageReceived(value[0]);
      }
    });

  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      final pickedFile = await _picker.getImage(source: source);

      // extract text from file
      String extractedText = await TesseractOcr.extractText(pickedFile.path, language: "eng");
      // debugPrint(extractedText);
      setState(() {
        _extractedText = extractedText;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  void _onImageReceived(SharedMediaFile mediaFile) async {
    try {
      // extract text from file
      String extractedText = await TesseractOcr.extractText(mediaFile.path, language: "eng");
      // debugPrint(extractedText);
      setState(() {
        _extractedText = extractedText;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Widget _showExtractedText() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_extractedText != null) {
      return ListView(
        children: <Widget>[
          Center(
            child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text('Detected Text',
                    style: TextStyle(fontSize: 22))),
          ),
          Center(
            child: SelectableText(_extractedText),
          ),
        ],
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Please pick an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20.0, left: 20.0),
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
          future: retrieveLostData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Text(
                  'Processing image..',
                  textAlign: TextAlign.center,
                );
              case ConnectionState.done:
                return _showExtractedText();
              default:
                if (snapshot.hasError) {
                  return Text(
                    'Pick image error: ${snapshot.error}}',
                    textAlign: TextAlign.center,
                  );
                } else {
                  return const Text(
                    'You have not yet picked an image.',
                    textAlign: TextAlign.center,
                  );
                }
            }
          },
        )
            : _showExtractedText(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

}
