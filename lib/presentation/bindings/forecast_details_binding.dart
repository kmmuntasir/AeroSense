import 'package:aero_sense/presentation/controllers/forecast_details_controller.dart';
import 'package:get/get.dart';

class ForecastDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForecastDetailsController>(
      () => ForecastDetailsController(),
    );
  }
}
