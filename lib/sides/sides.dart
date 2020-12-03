import 'package:juggernaut/sides/painting.dart';

abstract class Side {
  void reset();
  void setOffset(Painting painting, int value);
  void setNumber(Painting painting, int value);
  void setData(Painting painting, PaintingData data);
}

abstract class SideHolder {
  void setSide(Side side);
  void setOffset(Painting painting, int value);
  void setNumber(Painting painting, int value);
}
