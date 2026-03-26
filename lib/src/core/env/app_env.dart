import 'app_flavor.dart';

class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.appName,
  });

  final AppFlavor flavor;
  final String appName;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}

AppEnv appEnvForFlavor(AppFlavor flavor) {
  return switch (flavor) {
    AppFlavor.dev => const AppEnv(flavor: AppFlavor.dev, appName: 'JRNL (Dev)'),
    AppFlavor.prod => const AppEnv(flavor: AppFlavor.prod, appName: 'JRNL'),
  };
}

