import 'package:flutter/material.dart';

import 'package:juggernaut/sides/painting.dart';
import 'package:juggernaut/sides/sides.dart';

import 'package:juggernaut/sides/paintingHost/paintingHostWidget.dart';
import 'package:juggernaut/sides/paintingHost/paintingHostWidget2x4.dart';

import 'package:juggernaut/sides/numbers/numberSelector.dart';

abstract class ViewChanger {
  void setState(NumberSelectorState state);
}

class Numbers extends StatefulWidget {
  final SideHolder holder;
  final ViewChanger changer;

  Numbers(this.holder, this.changer);

  @override
  State<StatefulWidget> createState() {
    return NumbersState();
  }
}

class NumbersState extends State<Numbers> implements PaintingHolder {
  PaintingHostWidgetState state;
  bool roman;

  void onNumberSelected(int value) {
    Painting selected = this.state.getSelected();
    if (selected != null) {
      this.state.setNumber(selected, value);
      this.widget.holder.setNumber(selected, value);
    }
  }

  @override
  void onDataReady(Painting painting, PaintingData data) {}

  @override
  void setHost(PaintingHostWidgetState host) {
    this.state = host;
  }

  @override
  void reset() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PaintingHostWidget2x4(this.widget.holder, this, showLabels: true),
        NumberSelector(this.onNumberSelected, this.widget.changer.setState),
      ],
    );
  }

  setView(bool roman) {
    this.setState(() {
      this.roman = roman;
    });
  }
}
