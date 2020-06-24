import 'package:flutter/material.dart';
import 'package:widget_recorder/widget_recorder.dart';
import 'package:image/image.dart' as img;

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
  final _colors = [Colors.red, Colors.blue, Colors.green];
  AnimationController _controller;
  WidgetRecorderController _widgetRecorderController;
  bool _recording = false;
  img.Animation _animation;
  int _colorIndex = 0;
  GlobalKey _playerKey;

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
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Column(
          children: <Widget>[
            WidgetRecorder(
              controller: _widgetRecorderController,
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
                            color: _colors[_colorIndex % _colors.length],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: Colors.white,
                  onPressed: () => startRecord(),
                  child: Text('Record'),
                ),
                FlatButton(
                  color: Colors.white,
                  onPressed: () => switchColor(),
                  child: Text('Switch color'),
                )
              ],
            ),
            if (_animation != null)
              AnimationPlayer(key: _playerKey, animation: _animation),
          ],
        ),
        if (_recording)
          Container(
            height: MediaQuery.of(context).size.height -
                (MediaQuery.of(context).padding.top + 20),
            width: MediaQuery.of(context).size.width,
            color: Colors.red.withOpacity(0.1),
            child: Center(
              child: Text(
                "Recording",
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.none),
              ),
            ),
          ),
      ],
    );
  }

  void switchColor() => setState(() => _colorIndex++);

  void startRecord() async {
    setState(() {
      _recording = true;
    });
    _widgetRecorderController = WidgetRecorderController(
      childAnimationControler: _controller,
      fps: Fps.Fps10,
    );

    // This callback is called when the widget need a new frame
    _widgetRecorderController.addListener(notifyNewFrameReady);
    var animation = await _widgetRecorderController.captureAnimation();
    onRecordEnded(animation);
    // .then((animation) => onRecordEnded(animation));
  }

  // When recording is finished, an animation is available
  void onRecordEnded(img.Animation animation) {
    setState(() {
      _recording = false;
      _controller.repeat();
      _widgetRecorderController.removeListener(notifyNewFrameReady);
      _animation = animation;
      _playerKey = GlobalKey();
    });
  }

  // Notify the widgetRecorderController that a new frame is ready
  void notifyNewFrameReady() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _widgetRecorderController.newFrameReady());
  }
}

class AnimationPlayer extends StatefulWidget {
  final img.Animation animation;

  const AnimationPlayer({Key key, @required this.animation}) : super(key: key);

  @override
  _AnimationPlayerState createState() => _AnimationPlayerState();
}

class _AnimationPlayerState extends State<AnimationPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<List<int>> _frames;
  int _durationInMs = 0;

  @override
  void initState() {
    assert(widget.animation != null);

    _frames =
        widget.animation.frames.map((frame) => img.encodePng(frame)).toList();
    widget.animation.frames
        .forEach((frameImage) => _durationInMs += frameImage.duration);
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: _durationInMs));
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Text(
            'the copy is below',
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 26),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Image.memory(
              _frames[(_controller.value * widget.animation.length).toInt()],
            ),
          ),
        ],
      );
}
