import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _lat = 22.752944;
  double _lng = 75.8888324;
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late CameraPosition _currentPosition;

  @override
  initState() {
    super.initState();
    _currentPosition = CameraPosition(
      target: LatLng(_lat, _lng),
      zoom: 12,
    );
  }

  _locateMe() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    await location.getLocation().then((res) async {
      setState(() {
        _lat = res.latitude!;
        _lng = res.longitude!;
      });
      final GoogleMapController controller = await _controller.future;
      final _position = CameraPosition(
        target: LatLng(res.latitude!, res.longitude!),
        zoom: 12,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(_position));

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scientech App"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: _currentPosition,
          markers: {
            Marker(
              markerId: MarkerId('current'),
              position: LatLng(_lat, _lng),
            )
          },
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),

      ),
      floatingActionButton: InkWell(
        onTap: (){
          _locateMe();
        },
        child: Container(
          padding: EdgeInsets.all(24),
          height: 80,
          width: 600,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_lat.toString() +" - "+ _lng.toString()),
                //Icon(Icons.location_searching),
              ],
            ),
          ),
        ),
      ),
    );
  }
}