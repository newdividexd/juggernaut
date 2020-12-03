import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class OffsetSelector extends StatelessWidget {
  final void Function(int number) _callback;

  OffsetSelector(this._callback);

  Widget buildButton(int number, double separation, double width, double height) {
    String text = (number > 0) ? '+$number' : '$number';
    return Container(
      margin: EdgeInsets.fromLTRB(separation, 0, separation, 0),
      child: SizedBox(
        width: width,
        height: height,
        child: Builder(
          builder: (context) => MaterialButton(
            color: Theme.of(context).cardColor,
            child: Text(text),
            onPressed: () => this._callback(number),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: LayoutBuilder(builder: (context, constraints) {
        double separation = constraints.maxWidth * (0.2 / (5 * 2));
        double width = constraints.maxWidth * (0.8 / 5);
        List<Widget> row = List<Widget>.generate(4, (i) {
          int number = i + 1;
          return Column(children: [
            this.buildButton(number, separation, width, width * 0.8),
            Container(margin: EdgeInsets.only(top: separation)),
            this.buildButton(-number, separation, width, width * 0.8),
          ]);
        });
        row.insert(
            0,
            Column(
              children: [this.buildButton(0, separation, width, width * 0.8 * 2 + separation)],
            ));
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: row);
      }),
    );
  }
}
