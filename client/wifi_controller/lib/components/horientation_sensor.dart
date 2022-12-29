import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:wifi_controller/core/size_config.dart';

class OrientationExample extends StatefulWidget {
  final channel;

  const OrientationExample({super.key, required this.channel});
  @override
  // ignore: no_logic_in_create_state
  OrientationExampleState createState() => OrientationExampleState(channel);
}

class OrientationExampleState extends State<OrientationExample> {
  String _orientation = 'Horizontal';
  late dynamic _accelSubscription;
  List<double> _accelData = [0, 0, 0];
  final channel;
  bool left = false;
  bool rigth = false;
  bool released = false;
  bool updateSensor = false;
  bool _longPressCancelled = false;

  OrientationExampleState(this.channel);

  @override
  void initState() {
    super.initState();
    getSensorsInfo();
  }

  void getSensorsInfo() async {
    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    _accelSubscription = stream.listen((sensorEvent) {
      if (!_longPressCancelled) {
        var data = sensorEvent.data;
        double x = data[1];
        setState(() {
          _accelData = sensorEvent.data;
        });
        if ((0 <= x && x < 3) || (x > 0 && x < -3)) {
          if (!released) {
            channel.sink.add('!a');
            channel.sink.add('!d');
            HapticFeedback.vibrate();
            HapticFeedback.vibrate();
            setState(() {
              _orientation = 'Horizontal';
              left = false;
              rigth = false;
              released = true;
            });
          }
        } else if (x < -4) {
          if (!left) {
            HapticFeedback.vibrate();
            channel.sink.add('a');
            setState(() {
              left = true;
              released = false;
              _orientation = 'Left';
            });
          }
        } else if (x > 4) {
          if (!rigth) {
            HapticFeedback.vibrate();
            channel.sink.add('d');
            setState(() {
              rigth = true;
              released = false;
              _orientation = 'Right';
            });
          }
        } else {
          setState(() {
            _orientation = 'Horizontal';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription.cancel();
    super.dispose();
  }

  void onPressedKey() {
    HapticFeedback.vibrate();
    setState(() {
      _longPressCancelled = !_longPressCancelled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_orientation),
        _longPressCancelled == true
            ? GestureDetector(
                onTap: () => {onPressedKey()},
                behavior: HitTestBehavior.opaque,
                child: Container(
                    width: SizeConfig.blockSizeHorizontal * 7,
                    height: SizeConfig.blockSizeVertical * 5,
                    color: const Color.fromARGB(255, 206, 22, 22),
                    child: const Center(child: Text('Sensor'))),
              )
            : GestureDetector(
                onTap: () => {onPressedKey()},
                behavior: HitTestBehavior.opaque,
                child: Container(
                    width: SizeConfig.blockSizeHorizontal * 7,
                    height: SizeConfig.blockSizeVertical * 5,
                    color: const Color.fromARGB(255, 22, 206, 25),
                    child: const Center(child: Text('Sensor'))),
              )
      ],
    );
  }
}
