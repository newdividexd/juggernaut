import 'package:flutter/material.dart';

const List<String> romanNumbers = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
const List<String> decimalNumbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

class NumberSelector extends StatefulWidget {
  final void Function(int number) _callback;
  final void Function(NumberSelectorState selector) _setSelector;

  NumberSelector(this._callback, this._setSelector);

  @override
  State<StatefulWidget> createState() {
    return NumberSelectorState();
  }
}

class NumberSelectorState extends State<NumberSelector> {
  bool roman = true;

  @override
  void initState() {
    super.initState();
    this.widget._setSelector(this);
  }

  void setView(bool roman) {
    this.setState(() {
      this.roman = roman;
    });
  }

  Widget buildButton(String number, int value, double separation, double width) {
    return Container(
      margin: EdgeInsets.fromLTRB(separation, 0, separation, 0),
      child: SizedBox(
        width: width,
        height: width * 0.8,
        child: Builder(
          builder: (context) => MaterialButton(
            color: Theme.of(context).cardColor,
            child: Text(number),
            onPressed: () => this.widget._callback(value),
          ),
        ),
      ),
    );
  }

  Widget buildRow(List<String> numbers, int offset, double separation, double width) {
    return Row(children: numbers.asMap().entries.map((e) => this.buildButton(e.value, e.key + 1 + offset, separation, width)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double separation = constraints.maxWidth * (0.2 / (5 * 2));
      double width = constraints.maxWidth * (0.8 / 5);
      List<String> numbers = this.roman ? romanNumbers : decimalNumbers;
      return Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          children: [
            this.buildRow(numbers.sublist(0, 5), 0, separation, width),
            Container(margin: EdgeInsets.only(top: separation)),
            this.buildRow(numbers.sublist(5, 10), 5, separation, width),
          ],
        ),
      );
    });
  }
}
