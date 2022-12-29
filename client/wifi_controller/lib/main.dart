import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wifi_controller/components/game_input.dart';
import 'package:wifi_controller/components/horientation_sensor.dart';
import 'package:wifi_controller/components/joypad.dart';
import 'package:wifi_controller/components/relativeJoypad.dart';
import 'package:wifi_controller/core/size_config.dart';

String addres = 'ws://192.168.1.109:1234';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Controller',
        theme: ThemeData.dark(),
        routes: {
          '/': (context) => const MyHomePage(),
        },
        initialRoute: '/');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = WebSocketChannel.connect(
    Uri.parse(addres),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 5),
            child: Column(
              children: [
                getCross(channel, 'w', 'a', 'd', 's'),
                RelativeJoypad(
                  channel,
                ),
                // Joypad(
                //   channel: channel,
                //   callback: () {
                //     print('yaa');
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OrientationExample(
            channel: channel,
          ),
          const SizedBox(height: 2),
          const SizedBox(height: 2),
        ],
      ),
      Padding(
          padding: const EdgeInsets.only(right: 30),
          child: getCross(channel, 'space', 'enter', 'e', 'q'))
    ]));
  }
}

Widget getCross(channel, String top, String left, String right, String bottom) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(height: SizeConfig.blockSizeVertical * 5),
      GameInput(keyPressed: top, channel: channel),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GameInput(keyPressed: left, channel: channel),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 15,
          ),
          GameInput(keyPressed: right, channel: channel),
        ],
      ),
      GameInput(keyPressed: bottom, channel: channel),
      SizedBox(height: SizeConfig.blockSizeVertical * 5),
    ],
  );
}
