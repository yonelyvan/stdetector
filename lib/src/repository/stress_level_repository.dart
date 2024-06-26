class StressLevelRepository {
  int _stressLevelGSR = 1;

  static final StressLevelRepository _instance =
      StressLevelRepository._internal();

  StressLevelRepository._internal();

  factory StressLevelRepository() {
    return _instance;
  }

  int getCurrentStressLevel() {
    int r = _stressLevelGSR;
    return r;
  }

  int getStressValueGSR() => _stressLevelGSR;

  void updateStressValueGSR(int v) {
    _stressLevelGSR = v;
  }
}
