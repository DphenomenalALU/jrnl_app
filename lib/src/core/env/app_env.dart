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
