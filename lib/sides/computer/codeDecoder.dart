import 'package:flutter/material.dart';
import 'package:juggernaut/sides/painting.dart';

abstract class CodeHolder {
  void setDecoder(CodeDecoderState decoder);
}

class CodeDecoder extends StatefulWidget {
  final CodeHolder holder;

  CodeDecoder(this.holder);

  @override
  State<StatefulWidget> createState() {
    return CodeDecoderState(this.holder);
  }
}

class CodeDecoderState extends State<CodeDecoder> {
  final List<MapEntry<Painting, int>> _code = List();

  int selected;

  CodeDecoderState(CodeHolder holder) {
    holder.setDecoder(this);
  }

  @override
  void initState() {
    super.initState();
    this.reset();
  }

  void onOffsetSelected(Painting painting) {
    this.setState(() {
      int index = this._code.indexWhere((entry) => entry.key == painting);
      if (index == -1) {
        index = this.selected;
      }
      this.setDigit(index, painting, PaintingData());
      if (index == this.selected && this.selected < 3) {
        this.selected++;
      }
    });
  }

  void onDataReady(Painting painting, PaintingData data) {
    this.setState(() {
      int index = this._code.indexWhere((entry) => entry.key == painting);
      if (index != -1) {
        this._code[index] = MapEntry(painting, data.number + data.offset);
      }
    });
  }

  void reset() {
    this.setState(() {
      this._code.clear();
      this.selected = 0;
      for (int i = 0; i < 4; i++) {
        this._code.add(MapEntry(null, null));
      }
    });
  }

  void setDigit(int index, Painting painting, PaintingData data) {
    int digit = data.ready() ? data.number + data.offset : null;
    this._code[index] = MapEntry(painting, digit);
  }

  Widget buildDigit(int index, Painting painting, int digit, double width) {
    Widget image;
    if (painting != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset('assets/images/' + painting.file),
      );
    } else {
      image = LayoutBuilder(
        builder: (context, constraints) => Icon(
          Icons.crop_free,
          size: constraints.maxWidth,
        ),
      );
    }
    return GestureDetector(
      onTap: () => this.setState(() => this.selected = index),
      child: SizedBox(
        width: width,
        child: Card(
          elevation: (this.selected == index) ? 10 : 1,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: DragTarget<MapEntry<Painting, PaintingData>>(
              builder: (context, candidateData, rejectedData) {
                String text = digit == null ? '' : digit.toString();
                return Column(
                  children: [
                    image,
                    SizedBox(height: 5),
                    Text(text),
                  ],
                );
              },
              onAccept: (entry) {
                this.setState(() => this.setDigit(index, entry.key, entry.value));
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth / 5;
          var entries = this._code.asMap().entries;
          var children = entries.map((e) {
            int index = e.key;
            Painting painting = e.value.key;
            int digit = e.value.value;
            return this.buildDigit(index, painting, digit, width);
          }).toList();
          children.insert(
            0,
            SizedBox(
              width: width,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) => Icon(
                          Icons.dialpad,
                          size: constraints.maxWidth,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('Code'),
                    ],
                  ),
                ),
              ),
            ),
          );
          return Row(children: children);
        },
      ),
    );
  }
}
