import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:juggernaut/sides/painting.dart';
import 'package:juggernaut/sides/sides.dart';

import 'package:juggernaut/sides/paintingHost/paintingHostWidget.dart';
import 'package:juggernaut/sides/paintingHost/paintingHostWidget2x4.dart';

import 'package:juggernaut/sides/computer/offsetSelector.dart';
import 'package:juggernaut/sides/computer/codeDecoder.dart';

class Computer extends StatefulWidget {
  final SideHolder holder;

  Computer(this.holder);

  @override
  State<StatefulWidget> createState() {
    return ComputerState();
  }
}

class ComputerState extends State<Computer> implements PaintingHolder, CodeHolder {
  PaintingHostWidgetState _host;
  CodeDecoderState _decoder;

  @override
  void setHost(PaintingHostWidgetState host) {
    this._host = host;
  }

  void onOffsetSelected(int value) {
    Painting selected = this._host.getSelected();
    if (selected != null) {
      this._decoder.onOffsetSelected(selected);
      this._host.setOffset(selected, value);
      this.widget.holder.setOffset(selected, value);
    }
  }

  void onNumberSelected(Painting painting, int value) {
    this._host.setNumber(painting, value);
  }

  @override
  void setDecoder(CodeDecoderState decoder) {
    this._decoder = decoder;
  }

  @override
  void onDataReady(Painting painting, PaintingData data) {
    this._decoder.onDataReady(painting, data);
  }

  @override
  void reset() {
    this._decoder?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PaintingHostWidget2x4(this.widget.holder, this, enableDrag: true),
        OffsetSelector(this.onOffsetSelected),
        CodeDecoder(this),
      ],
    );
  }
}
