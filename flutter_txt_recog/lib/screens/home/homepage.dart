
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  bool isImageLoaded = false;
  String _txtValue = 'Read text here';
  TextEditingController txtController = TextEditingController();

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks){
      for (TextLine line in block.lines){
        for (TextElement word in line.elements){

          txtController.text += word.text;
          print(word.text);
        }
      }
    }

  }

  Future decode() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(ourImage);

    for (Barcode readableCode in barCodes) {
      print(readableCode.displayValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    //FirebaseApp.initializeApp(context);
    txtController.text = _txtValue;
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          isImageLoaded ?
              Center(
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(pickedImage), fit: BoxFit.cover
                    )
                  )
                ),
              ): Container(),

          SizedBox(height: 10.0),
          RaisedButton(
            child: Text('Pick an image'),
            onPressed: pickImage,
          ),

          SizedBox(height: 10.0),
          RaisedButton(
            child: Text('Read text'),
            onPressed: readText,
          ),

          SizedBox(height: 10.0),
          RaisedButton(
            child: Text('Read Bar Code'),
            onPressed: decode,
          ),

          TextField(
            textAlign: TextAlign.center,
            controller: txtController,
          ),
        ],
      )
    );
  }
}
