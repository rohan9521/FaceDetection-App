import 'package:flutter/material.dart';

class NewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NewWidget"),
      ),
      body: Column(
        children: [
          RaisedButton(
            onPressed: null,
            child: Text("Press Me"),
          )
        ],
      ),
    );
  }
}
