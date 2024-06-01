import 'dart:async';

import 'package:stdetector/src/repository/stress_level_repository.dart';

class StressLevelBase {}

class UpdateStressLevelGSR extends StressLevelBase {
  final int stressValueGSR;

  UpdateStressLevelGSR(this.stressValueGSR);
}

class UpdateStressLevelVoice extends StressLevelBase {
  final double stressValueVoice;

  UpdateStressLevelVoice(this.stressValueVoice);
}

class FetchEvent extends StressLevelBase {}

class StressLevelBlock {
  //variables
  StressLevelRepository repository = StressLevelRepository();

  //streams
  final StreamController<StressLevelBase> _input = StreamController();

  final StreamController<int> _outputGSR = StreamController();
  final StreamController<int> _outputCurrentStressLevel = StreamController();

  // :listen ui
  Stream<int> get stressLevelGSRStream => _outputGSR.stream;

  Stream<int> get currentStressLevelStream => _outputCurrentStressLevel.stream;

  StreamSink<StressLevelBase> get sendEvent => _input.sink;

  StressLevelBlock() {
    _input.stream.listen(_onEvent);
  }

  void dispose() {
    _input.close();
    _outputGSR.close();
    _outputCurrentStressLevel.close();
  }

  void _onEvent(StressLevelBase event) {
    if (event is UpdateStressLevelGSR) {
      repository.updateStressValueGSR(event.stressValueGSR);

      _outputGSR.add(repository.getStressValueGSR());
    }
    //send global stress value
    _outputCurrentStressLevel.add(repository.getCurrentStressLevel());
  }
}
