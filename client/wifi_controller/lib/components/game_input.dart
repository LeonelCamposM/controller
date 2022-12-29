import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_controller/core/size_config.dart';

class GameInput extends StatelessWidget {
  GameInput({super.key, required this.keyPressed, this.channel});
  String keyPressed;
  bool _longPressCancelled = true;
  final channel;

  void onPressedKey() {
    HapticFeedback.vibrate();
    channel.sink.add(keyPressed);
    _longPressCancelled = false;
  }

  void onCancelPressedKey() {
    HapticFeedback.vibrate();
    channel.sink.add('!$keyPressed');
    _longPressCancelled = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => {onPressedKey()},
      onTapUp: (details) => {onCancelPressedKey()},
      onLongPressUp: () {
        onCancelPressedKey();
      },
      onLongPressMoveUpdate: (details) {
        if (details.offsetFromOrigin.distance > 150) {
          if (!_longPressCancelled) {
            onCancelPressedKey();
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
          width: SizeConfig.blockSizeHorizontal * 10,
          height: SizeConfig.blockSizeVertical * 15,
          color: const Color.fromARGB(255, 53, 206, 22),
          child: Center(child: Text(keyPressed))),
    );
  }
}
