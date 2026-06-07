enum AppMode {
  live,
  demo;

  bool get isLive => this == AppMode.live;

  bool get isDemo => this == AppMode.demo;

  String get label {
    switch (this) {
      case AppMode.live:
        return 'Live';
      case AppMode.demo:
        return 'Demo';
    }
  }
}
