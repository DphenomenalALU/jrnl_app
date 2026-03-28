import 'app_flavor.dart';

class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.appName,
    required this.useMockData,
  });

  final AppFlavor flavor;
  final String appName;
  final bool useMockData;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}

bool _mockFromDartDefine({required AppFlavor flavor}) {
  const raw = String.fromEnvironment('USE_MOCK_DATA');
  if (raw.isEmpty) return false;
  switch (raw.trim().toLowerCase()) {
    case '1':
    case 'true':
    case 'yes':
    case 'y':
    case 'on':
      return true;
    default:
      return false;
  }
}

AppEnv appEnvForFlavor(AppFlavor flavor) {
  return switch (flavor) {
    AppFlavor.dev => AppEnv(
        flavor: AppFlavor.dev,
        appName: 'JRNL (Dev)',
        useMockData: _mockFromDartDefine(flavor: flavor),
      ),
    AppFlavor.prod => AppEnv(
        flavor: AppFlavor.prod,
        appName: 'JRNL',
        useMockData: _mockFromDartDefine(flavor: flavor),
      ),
  };
}
