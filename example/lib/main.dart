import 'package:flutter/material.dart';
import 'package:widget_recorder/widget_recorder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Recorder Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WidgetRecorderExample(),
    );
  }
}

class WidgetRecorderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: Column(
        children: <Widget>[
          AnimatedCircle(),
        ],
      ),
    );
  }
}

class AnimatedCircle extends StatefulWidget {
  @override
  _AnimatedCircleState createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  static const double CircleInitialDiameter = 200;
  AnimationController _controller;
  WidgetRecorderController widgetRecorderController;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        WidgetRecorder(
          controller: widgetRecorderController,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: CircleInitialDiameter,
                width: CircleInitialDiameter,
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    height: CircleInitialDiameter * (1 - _controller.value),
                    width: CircleInitialDiameter * (1 - _controller.value),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(CircleInitialDiameter),
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
