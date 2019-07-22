import 'package:flutter/material.dart';

class BlinkingButton extends StatefulWidget {
  var toggleRecordState;

  BlinkingButton(this.toggleRecordState);

  @override
  _BlinkingButtonState createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<BlinkingButton>


    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animationController,
        child: MaterialButton(
          child: Icon(Icons.mic),
          onPressed: () {
            setState(() {
              print("Test");
              widget.toggleRecordState();
            });

          },
        ),);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
