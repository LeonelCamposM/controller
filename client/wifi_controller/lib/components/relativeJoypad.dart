import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/src/channel.dart';
import 'package:wifi_controller/components/joypad.dart';
import 'package:wifi_controller/core/size_config.dart';

class RelativeJoypad extends StatefulWidget {
  final channel;
  RelativeJoypad(this.channel);

  @override
  RelativeJoypadPageState createState() => RelativeJoypadPageState(channel);
}

class RelativeJoypadPageState extends State<RelativeJoypad> {
  // Coordenadas del joystick
  double _joystickX = 0;
  double _joystickY = 0;

  // Coordenadas del toque
  double _touchX = 0;
  double _touchY = 0;

  double movement_x = 0;
  double movemnt_y = 0;
  final channel;

  Offset delta = Offset.zero;
  bool left = false;
  bool right = false;
  bool up = false;
  bool down = false;
  RelativeJoypadPageState(this.channel);

  void callbackFuction() {
    setState(() {
      _touchX = 0;
      _touchY = 0;
      _joystickX = 0;
      _joystickY = 0;
    });
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

  void updateDelta(Offset newDelta) {
    setState(() {
      delta = newDelta;
    });
    onChange(newDelta);
  }

  void onChange(Offset delta) {
    print(delta);
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
    } else {
      if (delta.dx < 0) {
        if (!left && delta.dx <= -25) {
          HapticFeedback.vibrate();
          delt += 'izq';
          channel.sink.add('a');
          channel.sink.add('!d');
          left = true;
        }
      } else {
        if (!right && delta.dx >= -15) {
          HapticFeedback.vibrate();
          delt += 'der';
          channel.sink.add('d');
          channel.sink.add('!a');
          right = true;
        }
      }

      if (delta.dy < 0) {
        if (!up && delta.dy <= -11) {
          HapticFeedback.vibrate();
          delt += ' arr';
          channel.sink.add('w');
          up = true;
        }
      } else {
        if (!down && delta.dy <= -11) {
          HapticFeedback.vibrate();
          delt += ' aba';
          channel.sink.add('s');
          down = true;
        }
      }
    }

    print(delt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(children: [
        // Área de juego
        Container(
            width: SizeConfig.blockSizeHorizontal * 30,
            height: SizeConfig.blockSizeVertical * 35,
            color: const Color.fromARGB(255, 227, 47, 47),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanDown: (details) {
                setState(() {
                  // Inicializa las variables _joystickX y _joystickY con las coordenadas del toque del usuario
                  _joystickX = details.localPosition.dx;
                  _joystickY = details.localPosition.dy;
                  _touchX = details.localPosition.dx;
                  _touchY = details.localPosition.dy;
                  movement_x = details.localPosition.dx;
                  movemnt_y = details.localPosition.dy;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  // _touchX = details.localPosition.dx;
                  // _touchY = details.localPosition.dy;
                  movement_x = details.localPosition.dx;
                  movemnt_y = details.localPosition.dy;
                });
                calculateDelta(
                    Offset(movement_x - _touchX, movemnt_y - _touchY));
              },
              onPanEnd: (details) {
                setState(() {
                  _touchX = 0;
                  _touchY = 0;
                  _joystickX = 0;
                  _joystickY = 0;
                });
                updateDelta(Offset.zero);
              },
            )),

        _joystickX != 0 && _joystickY != 0
            ? Positioned(
                left: _touchX - (SizeConfig.safeBlockHorizontal * 8 / 2),
                top: _touchY - (SizeConfig.safeBlockHorizontal * 8 / 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x88ffffff),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(movement_x - _touchX, movemnt_y - _touchY),
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
                ))
            : SizedBox(),
        SizedBox(
          width: 100,
          height: 100,
        ),
        Text(movemnt_y.toString())
      ])
    ]);
    // ],
    // );
  }
}
