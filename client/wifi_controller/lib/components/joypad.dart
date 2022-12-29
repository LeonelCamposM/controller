import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_controller/core/size_config.dart';

class Joypad extends StatefulWidget {
  const Joypad({super.key, this.channel, required this.callback});
  final channel;
  final callback;

  @override
  // ignore: no_logic_in_create_state
  JoypadState createState() => JoypadState(callback, channel);
}

class JoypadState extends State {
  Offset delta = Offset.zero;
  bool left = false;
  bool right = false;
  bool up = false;
  bool down = false;
  double x = 0, y = 0, z = 0;
  final callback;
  final channel;

  JoypadState(
    this.callback,
    this.channel,
  );

  void updateDelta(Offset newDelta) {
    setState(() {
      delta = newDelta;
    });
    onChange(newDelta);
  }

  void calculateDelta(Offset offset) {
    Offset newDelta = offset - Offset(60, 60);
    updateDelta(
      Offset.fromDirection(
        newDelta.direction,
        min(30, newDelta.distance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 10,
      height: SizeConfig.blockSizeHorizontal * 10,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
        ),
        child: GestureDetector(
          onPanDown: onDragDown,
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x88ffffff),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Transform.translate(
                offset: delta,
                child: SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 8,
                  height: SizeConfig.blockSizeHorizontal * 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xccffffff),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onDragDown(DragDownDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragUpdate(DragUpdateDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragEnd(DragEndDetails d) {
    updateDelta(Offset.zero);
  }

  void onChange(Offset delta) {
    String delt = '';
    if (delta.dx == 0 && delta.dy == 0) {
      delt += 'center';
      channel.sink.add('!w');
      channel.sink.add('!a');
      channel.sink.add('!s');
      channel.sink.add('!d');

      left = false;
      right = false;
      up = false;
      down = false;
      print('callback');
      callback();
    } else {
      if (delta.dx < 0) {
        if (!left && delta.dx <= -29) {
          HapticFeedback.vibrate();
          delt += 'izq';
          channel.sink.add('a');
          left = true;
        }
      } else {
        if (!right && delta.dx >= 29) {
          HapticFeedback.vibrate();
          delt += 'der';
          channel.sink.add('d');
          right = true;
        }
      }

      if (delta.dy < 0) {
        if (!up && delta.dy <= -29) {
          HapticFeedback.vibrate();
          delt += ' arr';
          channel.sink.add('w');
          up = true;
        }
      } else {
        if (!down && delta.dy >= 29) {
          HapticFeedback.vibrate();
          delt += ' aba';
          channel.sink.add('s');
          down = true;
        }
      }
    }

    print(delt);
  }
}
