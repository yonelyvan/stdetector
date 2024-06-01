import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../model/record.dart';

class WidgetRecord extends StatefulWidget {
  final Record record;
  final Function onSelected;
  final Function onUnselected;
  final Function onTouch;
  final bool editing;

  const WidgetRecord(
      {super.key,
      required this.record,
      required this.onSelected,
      required this.onUnselected,
      required this.onTouch,
      required this.editing});

  @override
  State<StatefulWidget> createState() {
    return WidgetRecordState();
  }
}

class WidgetRecordState extends State<WidgetRecord> {
  bool selected = false;

  /// Logger for debugging
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    try {
      if (!widget.editing) {
        selected = false;
      }
    } catch (error, stacktrace) {
      logger.e(error, stackTrace: stacktrace);
    }

    return GestureDetector(
      onLongPress: () {
        if (widget.editing) {
          setState(() {
            selected = false;
          });
        } else {
          widget.onSelected(widget.record);
          HapticFeedback.selectionClick();

          ///vibrate
          setState(() {
            selected = true;
          });
        }
      },
      onTap: () {
        if (widget.editing) {
          if (!selected) {
            setState(() {
              selected = true;
              widget.onSelected(widget.record);
            });
          } else {
            setState(() {
              selected = false;
              widget.onUnselected(widget.record);
            });
          }
        } else {
          setState(() {
            widget.onTouch(widget.record);
          });
        }
      },
      child: Card(
        color: selected ? Colors.blue : Colors.white70,
        child: ListTile(
          leading: const Icon(
            Icons.back_hand,
            color: Colors.grey,
          ),
          title: Text(
            widget.record.filename,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.record.dateToLocalFormat(),
              ),
              Text(
                widget.record.samples.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
