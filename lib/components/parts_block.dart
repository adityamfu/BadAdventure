import 'package:flame/components.dart';

class PartsBlock extends PositionComponent {
  bool isPlatfrom;
  PartsBlock({position, size, this.isPlatfrom = false})
      : super(position: position, size: size) {
    // debugMode = true;
  }
}
