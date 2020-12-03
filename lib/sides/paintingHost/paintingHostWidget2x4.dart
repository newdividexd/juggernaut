import 'package:flutter/material.dart';

import 'package:juggernaut/sides/painting.dart';
import 'package:juggernaut/sides/sides.dart';
import 'package:juggernaut/sides/paintingHost/paintingHostWidget.dart';

class PaintingHostWidget2x4 extends PaintingHostWidget {
  PaintingHostWidget2x4(SideHolder sHolder, PaintingHolder pHolder, {bool showLabels = false, bool enableDrag = false})
      : super(sHolder, pHolder, showLabels, enableDrag);

  @override
  State<StatefulWidget> createState() {
    return PaintingHostWidget2x4State();
  }
}

class PaintingHostWidget2x4State extends PaintingHostWidgetState {
  Widget buildEntry(MapEntry<Painting, PaintingData> entry, double width) {
    return SizedBox(
      width: width,
      child: this.buildPainting(entry.key, entry.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    var entries = this.getEntries();
    return Padding(
      padding: EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth / 4;
          return Column(
            children: [
              Row(children: entries.sublist(0, 4).map((e) => this.buildEntry(e, width)).toList()),
              Row(children: entries.sublist(4, 8).map((e) => this.buildEntry(e, width)).toList()),
            ],
          );
        },
      ),
    );
  }
}
