/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';

import 'Mail2BoondMenuManager.dart';

class Mail2BoondCandidateAppBar extends AppBar {
  //Logger _log = Logger('Mail2BoondCandidateAppBar');

  Mail2BoondCandidateAppBar(title)
      : super(
          leading: Mail2BoondMenuManager(),
          title: Text(title),
          toolbarOpacity: 0.5,
          actions: [],
        );
}
