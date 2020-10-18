/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:shared_preferences_settings/shared_preferences_settings.dart';

///
/// Inspired from https://github.com/BarthaBRW/shared_preferences_settings
/// A collection of Widget for lazy programmer.
///

class TextFieldSettingsTile extends StatefulWidget {
  static final log = Logger('TextFieldSettingsTile');

  final String settingKey;
  final String title;
  final String defaultValue;
  final Icon icon;
  final TextInputType keyboardType;
  final String visibleIfKey;
  final String enabledIfKey;
  final bool visibleByDefault;
  final bool obscureText;

  TextFieldSettingsTile({
    @required this.settingKey,
    @required this.title,
    this.defaultValue,
    this.icon,
    this.keyboardType,
    this.visibleIfKey,
    this.enabledIfKey,
    this.visibleByDefault = true,
    this.obscureText = false,
  });

  @override
  State<StatefulWidget> createState() => _TextFieldSettingsTileState();
}

class _TextFieldSettingsTileState extends State<TextFieldSettingsTile> {
  static final _log = Logger('TextFieldSettingsTile');

  @override
  void initState() {
    super.initState();
    _log.level = Level.FINE;
    Future.delayed(Duration.zero, () {
      Settings().pingString(widget.settingKey, widget.defaultValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ListTile ti = ListTile(
        title: Text(widget.title),
        subtitle: Settings().onStringChanged(
            settingKey: widget.settingKey,
            defaultValue: widget.defaultValue,
            childBuilder: (BuildContext context, String value) {
              //             log.fine(
              //               "TextFieldSettingsTile build on change called  : ${value}");
              return TextField(
                controller: TextEditingController(text: value),
                //onChanged: (value) => _onChange(widget.settingKey, value),
                //onEditingComplete: () => _onCompleted(widget.settingKey),
                onSubmitted: (String value) =>
                    _onSubmitted(widget.settingKey, value),
                obscureText: widget.obscureText,
              );
            }),
        enabled: true);

    return ti;
  }

  void _onSubmitted(String key, String newValue) {
    _log.fine("_onSubmitted : $key  = $newValue");
    Settings().save(key, newValue);
  }
}
