import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_tile_widget.dart';

class ServiceTileWidget extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTileWidget> characteristicTiles;

  const ServiceTileWidget(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    print('show me service list {$service}');
    //print('show me list $characteristicTiles');
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            GestureDetector(
              child: Text('0x${service.uuid.toString().toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context).textTheme.caption?.color)),
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text: '0x${service.uuid.toString().toUpperCase()}'));
                _showToast(context);
              },
            ),
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Object copied '),
      ),
    );
  }
}