import 'bootstrap.dart';
import 'src/core/env/app_flavor.dart';

import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'src/core/presentation/theme/app_colors.dart';
import 'src/core/presentation/widgets/jrnl_bottom_nav.dart';

Future<void> main() async {
  await bootstrap(flavor: appFlavorFromDartDefine());
}
