/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';

typedef LabelGetter<T> = String Function(T value);
typedef IdGetter<T> = int Function(T value);

class BoondDropdownFormField<T> extends StatefulWidget {
  static final Logger log = Logger("BoondDropdownFormField");

  final ValueChanged<T> onChanged;
  final List<T> entries;
  final int selectedId;
  final Function onTap;
  final LabelGetter<T> labelOf;
  final IdGetter<T> idOf;

  final Widget hint;

  /// Default Constructor
  BoondDropdownFormField(
      {Key key,
      @required this.entries,
      this.selectedId,
      @required this.onChanged,
      this.hint,
      this.onTap,
      this.labelOf,
      this.idOf})
      : assert(entries != null),
        assert(selectedId != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _BoondDropdownFormFieldState<T>();
}

class _BoondDropdownFormFieldState<T> extends State<BoondDropdownFormField> {
  static final Logger log = Logger("BoondDropdownFormField");

  //List<DropdownMenuItem<T>> menuItems;

  @override
  initState() {
    //log.level = Level.FINEST;
    super.initState();
  }

  @override
  Widget build(BuildContext c) {
    T selected;
    log.fine("[build] building");

    List<DropdownMenuItem<T>> l = List<DropdownMenuItem<T>>();
    BoondDropdownFormField<T> parent = (this.widget);

    for (T element in parent.entries) {
      // element is of T type.
      // we do not use introspection. Thereby limited to a few class.

      int id = (parent.idOf != null) ? parent.idOf(element) : element.hashCode;
      String value = (parent.labelOf != null)
          ? parent.labelOf(element)
          : element.toString();

      l.add(DropdownMenuItem<T>(value: element, child: Text(value)));
      if (id == parent.selectedId) selected = element;
    }

    return DropdownButtonFormField<T>(
      items: l,
      value: selected,
      hint: (this.widget as BoondDropdownFormField<T>).hint,
      onChanged: _handleChange,
      onTap: _handleOnTap,
    );
  }

  void _handleChange(T selVal) {
    log.fine("[_handleChange] $selVal");

    (this.widget as BoondDropdownFormField<T>).onChanged(selVal);
  }

  void _handleOnTap() {
    log.fine("[_handleOnTap] ");

    (this.widget as BoondDropdownFormField<T>).onTap();
  }
}
