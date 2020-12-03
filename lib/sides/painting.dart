const String _horseName = 'Horse';
const String _womanName = 'Woman';
const String _emptyName = 'Empty';
const String _medalName = 'Medal';
const String _mountainName = 'Mountain';
const String _houseName = 'House';
const String _shoulderName = 'Shoulder';
const String _hauntedName = 'Haunted';

const Painting _horse = Painting('horse.png', _horseName);
const Painting _woman = Painting('woman.png', _womanName);
const Painting _empty = Painting('empty.png', _emptyName);
const Painting _medal = Painting('medal.png', _medalName);
const Painting _mountain = Painting('mountain.png', _mountainName);
const Painting _house = Painting('house.png', _houseName);
const Painting _shoulder = Painting('shoulder.png', _shoulderName);
const Painting _haunted = Painting('haunted.png', _hauntedName);

class Painting {
  final String file;
  final String name;
  const Painting(this.file, this.name);

  static const List<Painting> list = [
    _horse,
    _woman,
    _empty,
    _medal,
    _mountain,
    _house,
    _shoulder,
    _haunted,
  ];

  static const Map<String, Painting> map = {
    _horseName: _horse,
    _womanName: _woman,
    _emptyName: _empty,
    _medalName: _medal,
    _mountainName: _mountain,
    _houseName: _house,
    _shoulderName: _shoulder,
    _hauntedName: _haunted,
  };
}

class PaintingData {
  int offset;
  int number;

  bool ready() {
    return this.number != null && this.offset != null;
  }
}
