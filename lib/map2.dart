import 'package:geolocator/geolocator.dart';

// ...

class _MapSampleState extends State<MapSample> {
  // ...

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;

    // Request permission to access the location
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool locationEnabled = await Geolocator.openLocationSettings();
      if (!locationEnabled) {
        return;
      }
    }

    PermissionStatus permission = await Geolocator.requestPermission();
    if (permission == PermissionStatus.denied) {
      permission = await Geolocator.requestPermission();

