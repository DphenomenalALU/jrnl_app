enum AppFlavor { dev, prod }

AppFlavor appFlavorFromDartDefine() {
  const raw = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  switch (raw) {
    case 'prod':
      return AppFlavor.prod;
    case 'dev':
    default:
      return AppFlavor.dev;
  }
}
