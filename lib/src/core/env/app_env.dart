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

bool _emulatorsFromDartDefine({required AppFlavor flavor}) {
  const raw = String.fromEnvironment('USE_FIREBASE_EMULATORS');
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

String _emulatorHostFromDartDefine() {
  const raw = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
  if (raw.trim().isEmpty) return 'localhost';
  return raw.trim();
}

AppEnv appEnvForFlavor(AppFlavor flavor) {
  const useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
  return switch (flavor) {
    AppFlavor.dev => const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'JRNL (Dev)',
        useMockData: useMockData,
      ),
    AppFlavor.prod => const AppEnv(
        flavor: AppFlavor.prod,
        appName: 'JRNL',
        useMockData: false,
      ),
  };
}
