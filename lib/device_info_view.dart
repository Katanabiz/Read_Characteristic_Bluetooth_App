import 'dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceInfoView extends StatefulWidget {
  DeviceInfoView({Key? key, required this.title}) : super(key: key);

  final String title;
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  DeviceInfoViewState createState() => DeviceInfoViewState();
}

class DeviceInfoViewState extends State<DeviceInfoView> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
        print('9999999999999999999999999 $device');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name.isNotEmpty) {
          _addDeviceTolist(result.device);
        }
        print('0000000000000000000000 ${result.device}');
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Text(device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.lightBlue),
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } on PlatformException catch (e) {
                    if (e.code != 'already_connected') {
                      rethrow;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                },
                child: const Text('CONNECT'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  void readBtn(chr) async {
    await chr.value.listen((value) {
      widget.readValues[chr.uuid] = value;
    });
    await chr.read();
  }

  List<ButtonTheme> _buildReadButton(BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = <ButtonTheme>[];
    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
                child: const Text('READ',
                    style: TextStyle(color: Colors.lightGreen)),
                onPressed: () => readBtn(characteristic)),
          ),
        ),
      );
    }
    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Widget> containers = <Widget>[];
    var sendingData = [];
    Map<Guid, List<int>> wdData = <Guid, List<int>>{};

    ReadValue(characteristic) async {
      if (characteristic != null) {
        await characteristic.value.listen((value) {
          wdData[characteristic.uuid] = value;
        });
        await characteristic.read();
      }
      return characteristic;
    }

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(DummyData.lookup1(characteristic.uuid.toString()),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    (widget.readValues[characteristic.uuid] == null)
                        ? const Text('')
                        : Text(
                            'Value: ${String.fromCharCodes(widget.readValues[characteristic.uuid]!)}')
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );

        //ReadValue(characteristic);
        readBtn(characteristic);
        {
          var jsondata = {
            "serviceName": characteristic.uuid.toString(),
            "serviceValue": widget.readValues[characteristic.uuid].toString(),
            "name": DummyData.lookup1(characteristic.uuid.toString()),
            "value": widget.readValues[characteristic.uuid] != null
                ? String.fromCharCodes(widget.readValues[characteristic.uuid]!)
                : ""
          };

          sendingData.add(jsondata);
        }
      }
      print('6666666666666666666666 ${sendingData}');
      containers.add(
        ExpansionTile(
            title: Text(DummyData.lookup1(service.uuid.toString())),
            children: characteristicsWidget),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildView(),
      );
}
