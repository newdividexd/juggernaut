import 'package:flutter/material.dart';
import 'package:juggernaut/sides/painting.dart';
import 'package:juggernaut/sides/sides.dart';

abstract class PaintingHolder {
  void reset();
  void setHost(PaintingHostWidgetState host);
  void onDataReady(Painting painting, PaintingData data) {}
}

abstract class PaintingHostWidget extends StatefulWidget {
  final SideHolder sideHolder;
  final PaintingHolder paintingHolder;
  final bool showLabels;
  final bool enableDrag;

  PaintingHostWidget(this.sideHolder, this.paintingHolder, this.showLabels, this.enableDrag);
}

abstract class PaintingHostWidgetState extends State<PaintingHostWidget> implements Side {
  final Map<Painting, PaintingData> _paintings = Map();

  Painting _slected;

  @override
  void initState() {
    super.initState();
    this.reset();
    this.widget.sideHolder.setSide(this);
    this.widget.paintingHolder.setHost(this);
  }

  Painting getSelected() {
    return this._slected;
  }

  @override
  void reset() {
    this.setState(() {
      this.widget.paintingHolder?.reset();
      this._slected = null;
      for (Painting painting in Painting.list) {
        this._paintings[painting] = PaintingData();
      }
    });
  }

  @override
  void setNumber(Painting painting, int value) {
    this.setState(() {
      this._paintings[painting].number = value;
      this._checkPainting(painting);
    });
  }

  @override
  void setOffset(Painting painting, int value) {
    this.setState(() {
      this._paintings[painting].offset = value;
      this._checkPainting(painting);
    });
  }

  @override
  void setData(Painting painting, PaintingData data) {
    this.setState(() {
      this._paintings[painting].offset = data.offset;
      this._paintings[painting].number = data.number;
      this._checkPainting(painting);
    });
  }

  void _checkPainting(Painting painting) {
    PaintingData data = this._paintings[painting];
    if (data.ready()) {
      this.widget.paintingHolder.onDataReady(painting, data);
    }
  }

  List<MapEntry<Painting, PaintingData>> getEntries() {
    return this._paintings.entries.toList();
  }

  Icon _getNumberIcon(PaintingData data) {
    if (data.offset != null && data.number == null) {
      return Icon(Icons.image, color: Colors.red);
    } else if (data.offset != null && data.number != null) {
      return Icon(Icons.image, color: Colors.green);
    } else {
      return Icon(Icons.image);
    }
  }

  Widget buildPainting(Painting painting, PaintingData data) {
    double elevation = (this._slected == painting) ? 10 : 1;
    String number = (data.number != null) ? data.number.toString() : '';
    String offset = (data.offset != null) ? data.offset.toString() : '';

    return GestureDetector(
      onTap: () => this.setState(() => this._slected = painting),
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.all(5),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              if (this.widget.showLabels) Text(painting.name),
              if (this.widget.showLabels) SizedBox(height: 5),
              LayoutBuilder(
                builder: (context, constraints) {
                  var image = ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset('assets/images/' + painting.file),
                  );
                  if (this.widget.enableDrag) {
                    return Draggable<MapEntry<Painting, PaintingData>>(
                      data: MapEntry(painting, this._paintings[painting]),
                      child: image,
                      feedback: SizedBox(width: constraints.maxWidth, child: image),
                    );
                  } else {
                    return image;
                  }
                },
              ),
              SizedBox(height: 5),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [this._getNumberIcon(data), Text(number)],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Icon(Icons.iso), Text(offset)],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
