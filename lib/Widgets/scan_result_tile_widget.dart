import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTileWidget extends StatelessWidget {
  const ScanResultTileWidget({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          result.device.name.toString(),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          result.device.id.toString(),
          style: Theme.of(context).textTheme.caption,
        )
      ],
    );
  }

  // Widget _buildAdvRow(BuildContext context, String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text(title, style: Theme.of(context).textTheme.caption),
  //         const SizedBox(
  //           width: 12.0,
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style:
  //                 Theme.of(context).textTheme.caption?.apply(color: Colors.red),
  //             softWrap: true,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String getNiceHexArray(List<int> bytes) {
    print(
        'what is this [${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]');
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      print('This is Manufacture data $data');

      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ').toString();
  }

  @override
  Widget build(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return ExpansionTile(
        // Received Signal Strength Indicator   relative quality level
        title: _buildTitle(context),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.lightBlue),
          onPressed: (result.advertisementData.connectable) ? onTap : null,
          child: const Text('CONNECT'),
        ),
        // children: <Widget>[
        //   _buildAdvRow(context, 'Complete Local Name',
        //       result.advertisementData.localName),
        //   _buildAdvRow(context, 'Tx Power Level',
        //       '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        //   _buildAdvRow(
        //       context,
        //       'Manufacturer Data',
        //       getNiceManufacturerData(
        //           result.advertisementData.manufacturerData)),
        //   _buildAdvRow(
        //       context,
        //       'Service UUIDs',
        //       (result.advertisementData.serviceUuids.isNotEmpty)
        //           ? result.advertisementData.serviceUuids
        //               .join(', ')
        //               .toUpperCase()
        //           : 'N/A'),
        //   _buildAdvRow(context, 'Service Data',
        //       getNiceServiceData(result.advertisementData.serviceData)),
        // ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
