/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectButton extends StatefulWidget {
  static final Logger log = Logger("ConnectButton");
  final Icon icon;
  final String tooltip;
  final bool Function() isConnected;
  final void Function() onConnect;

  /// Default Constructor
  ConnectButton(
      {Icon this.icon,
      String this.tooltip,
      bool Function() this.isConnected,
      void Function() this.onConnect})
      : super() {
    //log.level = Level.FINE;
    log.fine("[ConnectButton] constructor");
  }

  @override
  State<StatefulWidget> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  // a bit tricky, but ShapeDecoration colors are const
  // and I need to make it different upon connection status.
  static final ShapeDecoration greyShape = ShapeDecoration(
    color: Colors.grey,
    shape: CircleBorder(),
  );
  static final ShapeDecoration greenShape = ShapeDecoration(
    color: Colors.green,
    shape: CircleBorder(),
  );

  String getToolTip() {
    if (this.widget.tooltip != null) return this.widget.tooltip;
    return (super.widget.isConnected() ? "connect" : "disconnect");
  }

  @override
  Widget build(BuildContext c) {
    bool connectStatus = super.widget.isConnected();

    return Ink(
        decoration: (connectStatus ? greenShape : greyShape),
        //width: super.widget.icon.size * 3,
        //height: super.widget.icon.size * 3,
        child: IconButton(
          // alignment: Alignment.center,
          icon: super.widget.icon,
          tooltip: this.getToolTip(),
          onPressed: super.widget.onConnect,
        ));
  }
}
