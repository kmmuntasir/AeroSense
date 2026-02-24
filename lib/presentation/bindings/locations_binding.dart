import 'package:get/get.dart';
import 'package:aero_sense/presentation/controllers/locations_controller.dart';

class LocationsBinding extends Bindings {
  @override
  void dependencies() {
    // LocationController: permanent=true via LocationBinding
    // WeatherController: registered by DashboardBinding (reachable from nav)
    Get.lazyPut<LocationsController>(() => LocationsController());
  }
}
