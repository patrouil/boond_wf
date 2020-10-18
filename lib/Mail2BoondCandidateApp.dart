/*
 * Copyright (c) patrick 10/2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 */

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'ui/Mail2BoondCandidateHomePage.dart';

class Mail2BoondCandidateApp extends StatefulWidget {
  final log = Logger('Mail2BoondCandidateApp');

  Mail2BoondCandidateApp() : super() {}

  @override
  State<StatefulWidget> createState() => _Mail2BoondCandidateAppState();
}

class _Mail2BoondCandidateAppState extends State<Mail2BoondCandidateApp> {
  final log = Logger('Mail2BoondCandidateApp');

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    this.log.fine("[build]");
    return MaterialApp(
      title: 'Boond Candidate Workflow',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Mail2BoondCandidateHomePage(title: 'Boond Candidate Workflow'),
    );
  }
}
