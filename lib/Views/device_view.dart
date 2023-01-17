// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../Widgets/characteristic_tile_widget.dart';
import '../Widgets/descriptor_tile_widget.dart';
import '../Widgets/service_tile_widget.dart';


class DeviceView extends StatelessWidget {
  const DeviceView({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  // List<int> _getRandomBytes() {
  //   final math = Random();
  //   return [
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255)
  //   ];
  // }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTileWidget(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTileWidget(
                    characteristic: c,
                    onReadPressed: () async {
                      List<int> value = await c.read();
                      print('9999999999999 ${String.fromCharCodes(value)}');
                    },
                 
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTileWidget(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                      
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print('999999999999999 $device.connect()');
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name.toString()),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                // leading: Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     snapshot.data == BluetoothDeviceState.connected
                //         ? const Icon(Icons.bluetooth_connected)
                //         : const Icon(Icons.bluetooth_disabled),
                //     snapshot.data == BluetoothDeviceState.connected
                //         ? StreamBuilder<int>(
                //             stream: rssiStream(),
                //             builder: (context, snapshot) {
                //               return Text(
                //                   snapshot.hasData ? '${snapshot.data}dBm' : '',
                //                   style: Theme.of(context).textTheme.caption);
                //             })
                //         : Text('', style: Theme.of(context).textTheme.caption),
                //   ],
                // ),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text(device.name),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
         
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                print('What is this ${device.services.toString()}');
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
