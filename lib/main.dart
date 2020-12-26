import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  var listQuestions = ['was ist dein name?', 'What is your favourite sport?'];
  var _questionIndex = 0;
  var height = 100;
  var width = 100;
  var _imageFile;
  List<Rect> rectList = new List<Rect>();
  ui.Image _image;
  List<Face> _faces;

  Future<ui.Image> loadImage(File image) async {
    var img = await image.readAsBytes();
    return await decodeImageFromList(img);
  }

  Future _getImage(File imgFile) async {
    setState(() {
      rectList = List<Rect>();
    });
    List<Rect> newList = new List<Rect>();
//    await ImagePicker.pickImage(source: ImageSource.camera)
    var imageFile = imgFile;
    print(imageFile.runtimeType);
    var image = FirebaseVisionImage.fromFile(imageFile);
    var faceDetector = FirebaseVision.instance.faceDetector();
    var faces = await faceDetector.processImage(image);
    for (Face f in faces) {
      rectList.add(f.boundingBox);
    }

    // faces.map((e) => {print(e)});
    // setState(() {
    //   rectList = newList;
    // });
    // Future<List<Rect>> loadFaces(List<Face> faces) async {
    //   List<Rect> listRect;
    //   faces.map((e) => rectList.add(e.boundingBox));
    //   return rectList;
    // }

    setState(() {
      _imageFile = imageFile;
      _faces = faces;
    });
    // loadFaces(faces).then((value) => _rectList = value);

    loadImage(imageFile).then((img) {
      print(img.height);
      print(img.width);
      setState(() {
        this._image = img;
        height = img.height;
        width = img.width;
      });
    });
  }

  Future<void> _getImageGallery() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    _getImage(imageFile);
  }

  Future<void> _getImageCamera() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    _getImage(imageFile);
  }

  // void show() {
  //   print('Answer the questions');
  //   setState(() {
  //     _questionIndex = _questionIndex + 1;
  //   });
  // }

  // Future<void> _showDialogBox(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Capture Image"),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               GestureDetector(
  //                 child: Text("Capture Image"),
  //                 onTap: _getImageCamera,
  //               ),
  //               Padding(padding: EdgeInsets.all(0.0)),
  //               GestureDetector(
  //                 child: Text("Open Gallery"),
  //                 onTap: _getImageGallery,
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Face Detection using Firebase'),
      ),
      // body: Row(
      //   children: [
      //     Text(listQuestions.elementAt(_questionIndex)),
      //     RaisedButton(child: Question('A1'), onPressed: () => {show()}),
      //     RaisedButton(child: Question('A2'), onPressed: () => {show()}),
      //     RaisedButton(
      //         child: Text('Navigate'), onPressed: () => {_getImage()}),
      //   ],
      // )
      body: Column(children: [
        Row(children: [
          RaisedButton(
            onPressed: () => {_getImageGallery()},
            child: Text("Load Image"),
          ),
          RaisedButton(
            onPressed: () => {_getImageCamera()},
            child: Text("Open Camera"),
          )
        ]),
        FittedBox(
          child: SizedBox(
            width: this.width.toDouble(),
            height: this.height.toDouble(),
            child: CustomPaint(
              painter: Painter(rect: rectList, image: _image),
            ),
          ),

          // ImagesAndFaces(
          //   imageFile: _imageFile,
          //   faces: _faces,
          // )
        ),
      ]),

      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
      ),
    ));
  }
}

class ImagesAndFaces extends StatelessWidget {
  ImagesAndFaces({this.imageFile, this.faces});
  final File imageFile;
  final List<Face> faces;
  //final List<Rect> rectList;
  @override
  Widget build(BuildContext context) {
    //  faces.map((e) => rectList.add(e.boundingBox));
    return Column(
      children: <Widget>[
        Flexible(
            flex: 2,
            child: Container(
                child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ))),
        Flexible(
            flex: 2,
            child: Container(
              child: ListView(
                children: faces.map((f) => FaceCoordinates(f)).toList(),
              ),
            ))
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);
  final Face face;
  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('${pos.top},${pos.left},${pos.bottom},${pos.right}'),
    );
  }
}

class Painter extends CustomPainter {
  List<Rect> rect;
  ui.Image image;

  Painter({@required this.rect, @required this.image});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }
    print("this is reachable");
    for (Rect rect in this.rect) {
      print("rect");
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return image != oldDelegate.image || (rect != oldDelegate.rect);
  }
}
