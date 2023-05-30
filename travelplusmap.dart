import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Travel Plus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> _excelData = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _loadExcelData(); // _incrementCounter 메서드에서 _loadExcelData 호출
  }

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    List<String> data = await _readExcelData();
    setState(() {
      _excelData = data;
    });
  }

  Future<List<String>> _readExcelData() async {
    try {
      var bytes = await rootBundle.load('assets/labeling_data_0521.xlsx');
      var excel = Excel.decodeBytes(bytes.buffer.asUint8List());
      var sheet = excel['Sheet1'];

      List<String> data = [];
      for (var row in sheet.rows) {
        if (row != null && row.length >= 4) {
          var cell = row[3]; // 'D' 열에 해당하는 셀
          data.add(cell?.value?.toString() ?? ''); // null 체크와 문자열 변환
        }
      }
      return data;
    } catch (e) {
      print('Error reading Excel data: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MapSample(),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _excelData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_excelData[index]),
                );
              },
            ),
          ),
        ],
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final List<Marker> _markers = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 15,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.5665, 126.9780),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: MarkerId("1"),
      draggable: true,
      onTap: () => print("Marker 1!"),
      position: LatLng(37.4537251, 126.7960716),
    ));
    _markers.add(Marker(
      markerId: MarkerId("2"),
      draggable: true,
      onTap: () => print("Marker 2!"),
      position: LatLng(37.123456, 126.654321),
    ));
  }

  void _updatePosition(CameraPosition _position) {
    var m = _markers.firstWhere(
          (p) => p.markerId.value == '1',
      orElse: () => Marker(
        markerId: MarkerId('1'),
        position: LatLng(0, 0),
        draggable: true,
        onTap: () => print('Marker!'),
      ),
    );
    _markers.remove(m);
    m = m.copyWith(
      positionParam: LatLng(_position.target.latitude, _position.target.longitude),
    );
    _markers.add(m);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        mapType: MapType.normal,
        markers: Set.from(_markers),
        initialCameraPosition: _kGooglePlex,
        myLocationButtonEnabled: false,
        onCameraMove: ((_position) => _updatePosition(_position)),
      ),
    );
  }
}