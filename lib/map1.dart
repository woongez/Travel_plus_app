import 'package:geolocator/geolocator.dart';

// ...

class _MapSampleState extends State<MapSample> {
  // ...

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Move the camera to the current position
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    )));
  }
}
