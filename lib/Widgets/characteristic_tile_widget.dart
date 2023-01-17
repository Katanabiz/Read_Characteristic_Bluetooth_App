import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'descriptor_tile_widget.dart';

class CharacteristicTileWidget extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTileWidget> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTileWidget(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('show me characteristic value list $characteristic');

    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                GestureDetector(
                  child: Text(
                      '0x${characteristic.uuid.toString().toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context).textTheme.caption?.color)),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '0x${characteristic.uuid.toString().toUpperCase()}'));
                    _showToast(context);
                  },
                ),
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: onReadPressed,
              ),
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
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