import 'bootstrap.dart';
import 'src/core/env/app_flavor.dart';

Future<void> main() async {
  await bootstrap(flavor: AppFlavor.dev);
}

