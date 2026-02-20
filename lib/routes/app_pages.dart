import 'package:get/get.dart';
import '../presentation/pages/home/home_page.dart';

class AppPages {
  static const initial = '/home';

  static final routes = [
    GetPage(
      name: '/home',
      page: () => const HomePage(),
    ),
  ];
}
