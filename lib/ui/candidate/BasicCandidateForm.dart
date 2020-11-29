/*
 * Copyright (c) patrouil 2020.
 *  This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 *  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TextFormField, InputDecoration;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider;

import 'package:boond_api/boond_api.dart' as boond
    show
        AppDictionnaryGet,
        AppDictAvailability,
        CandidateGet,
        CandidateSearch,
        CandidateSearchData;

import '../../entity/MailNavigatorMessage.dart';
import '../../widget/BoondDropdownFormField.dart';

import '../../business/BoondCandidateBloc.dart';
import '../../business/BoondCandidateUIEvent.dart';
import '../../business/BoondCandidateUIState.dart';
import 'BoondCandidateSelectDialog.dart';

class BasicCandidateForm extends StatefulWidget {
  static final Logger log = Logger("BasicCandidateForm");

  /// Default Constructor
  BasicCandidateForm() : super() {
    //log.level = Level.FINEST;
  }

  @override
  State<StatefulWidget> createState() => _BasicCandidateFormState();
}

class _BasicCandidateFormState extends State<BasicCandidateForm> {
  static final Logger log = BasicCandidateForm.log;

  static final List<boond.AppDictAvailability> _emptyAvailabilityList = [
    boond.AppDictAvailability(id: 0, value: "")
  ];

  final _formKey = GlobalKey<FormState>();

  boond.CandidateGet currentCandidate;

  Widget _buildCivilite(BuildContext c) {
    List<boond.AppDictAvailability> avail;

    BoondCandidateBloc candidateBloc = BlocProvider.of<BoondCandidateBloc>(c);
    boond.AppDictionnaryGet d = candidateBloc?.model?.application_dict;

    avail = d?.data?.setting?.civility ?? _emptyAvailabilityList;
    assert(avail != null);
    Widget w = BoondDropdownFormField<boond.AppDictAvailability>(
      entries: avail,
      selectedId: this.currentCandidate?.data?.attributes?.civility ?? 0,
      onChanged: (boond.AppDictAvailability v) {
        this.currentCandidate.data.attributes.civility = v.id;
      },
      idOf: (dynamic e) => e.id,
      labelOf: (dynamic e) => e.value,
    );
    return w;
  }

  Widget _buildFirstName(BuildContext c) {
    String v = this.currentCandidate?.data?.attributes?.firstName;
    Widget w = TextFormField(
      controller: TextEditingController(text: v),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(labelText: 'Firstname'),
      onChanged: (String v) {
        this.currentCandidate.data.attributes.firstName = v.trim();
      },
    );
    return w;
  }

  Widget _buildLastName(BuildContext c) {
    String v = this.currentCandidate?.data?.attributes?.lastName;
    log.fine("[_buildLastName] build $v");

    Widget w = TextFormField(
      controller: TextEditingController(text: v),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(labelText: 'Lastname'),
      onChanged: (String v) {
        log.fine("[_buildLastName] onChanged $v");
        this.currentCandidate.data.attributes.lastName = v.trim().toUpperCase();
      },
    );
    return w;
  }

  Widget _buildEmail(BuildContext c) {
    log.fine("[_buildEmail] builder");

    String v = this.currentCandidate?.data?.attributes?.email1;
    log.fine("[_buildEmail] calling formfield $v");

    Widget w = TextFormField(
      controller: TextEditingController(text: v),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email'),
      maxLines: 1,
      validator: (String value) {
        if (value == null || value.isEmpty) return "email is mandatory";
        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Not a valid email';
        }
        return null;
      },
      onChanged: (String v) {
        this.currentCandidate.data.attributes.email1 = v.trim();
      },
    );
    return w;
  }

  Widget _buildPhone(BuildContext c) {
    String v = this.currentCandidate?.data?.attributes?.phone1;
    log.fine("[_buildPhone] builder $v");

    Widget w = TextFormField(
      controller: TextEditingController(text: v),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: 'Phone number'),
      onChanged: (String v) {
        this.currentCandidate.data.attributes.phone1 = v.trim();
      },
    );
    return w;
  }

  Widget _buildStatus(BuildContext c) {
    List<boond.AppDictAvailability> avail;

    log.fine("[_buildStatus] builder");

    BoondCandidateBloc candidateBloc = BlocProvider.of<BoondCandidateBloc>(c);
    boond.AppDictionnaryGet d = candidateBloc?.model?.application_dict;

    log.fine("[_buildStatus] builder app dict a $d ");

    avail = d?.data?.setting?.state?.candidate ?? _emptyAvailabilityList;

    int v = this.currentCandidate?.data?.attributes?.state ?? 0;

    log.fine("[_buildStatus] default is a ${v} ");

    Widget w = BoondDropdownFormField<boond.AppDictAvailability>(
      entries: avail,
      selectedId: v,
      hint: const Text("Status"),
      onChanged: (boond.AppDictAvailability v) {
        log.fine("[_buildStatus] changing to ${v.value} ");
        this.currentCandidate.data.attributes.state = v.id;
      },
      idOf: (dynamic e) => e.id,
      labelOf: (dynamic e) => e.value,
    );

    return w;
  }

  Widget _buildFormWrapper(BuildContext _context) {
    return Form(
      key: _formKey,
      onChanged: _handleFormChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Table(
            // border: TableBorder(bottom: BorderSide(), verticalInside: BorderSide()),
            columnWidths: {
              0: FractionColumnWidth(0.4),
              1: FractionColumnWidth(0.6)
            },
            children: <TableRow>[
              TableRow(children: [
                Column(children: [
                  _buildStatus(_context),
                  _buildCivilite(_context),
                  _buildPhone(_context),
                ]),
                Column(children: [
                  _buildFirstName(_context),
                  _buildLastName(_context),
                  _buildEmail(_context),
                ])
              ]),
            ],
          )),
    );
  }

  Widget _buildDragWrapper(Widget parentW, BuildContext _context) {
    return DragTarget<MailNavigatorMessage>(
      //
      builder: (BuildContext _context, List<MailNavigatorMessage> candidateData,
          List<dynamic> rejectedData) {
        return parentW;
      },
      //
      onAccept: (MailNavigatorMessage data) async {
        String senderName = data.fromFullName;
        String senderMail = data.fromEmail;
        log.fine(" [_buildDragWrapper.onAccept] dragdrop accept $senderMail");

        BoondCandidateBloc boondBloc =
            BlocProvider.of<BoondCandidateBloc>(_context);
        if (!boondBloc.isConnected()) {
          boondBloc.add(BoondCandidateUIEventWarning(
              warningMessage: "please connect first"));
          return;
        }

        /// apply a first search on drag n drop event
        boond.CandidateSearch canList = await boondBloc.searchByEmailAndName([
          ["keywordsType=emails", "keywords=$senderMail"],
          ["keywordsType=fullName", "keywords=$senderName"]
        ]);
        //// if an empty or single result eceived.
        /// then a normal Event/sate workflow if triggered
        if (canList == null ||
            canList.data.isEmpty ||
            canList?.data?.length == 1) {
          boondBloc.add(BoondCandidateUIEventLookupRequest(criteria: [
            ["keywordsType=emails", "keywords=$senderMail"],
            ["keywordsType=fullName", "keywords=$senderName"]
          ]));
        } else {
          /// otherwise open a CandidateSelector dialog.
          /// and push a Loaded request for the selected Candidate.
          boond.CandidateSearchData selectCan =
              await BoondCandidateSelectDialog.selectCandidate(
                  candidates: canList, context: _context);
          if (selectCan != null) {
            boondBloc.add(
                BoondCandidateUIEventLoadRequest(candidateId: selectCan.id));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext _context) {
    log.fine("[build] begin");
    return BlocBuilder<BoondCandidateBloc, BoondCandidateUIState>(
        //bloc: BlocProvider.of<BoondCandidateBloc>(context),
        buildWhen:
            (BoondCandidateUIState previousState, BoondCandidateUIState state) {
      final List<Type> criteria = [
        BoondCandidateUIStateLookupDone(candidateFound: null).runtimeType,
        BoondCandidateUIStateLoaded(candidate: null).runtimeType,
        BoondCandidateUIStateDisconnected().runtimeType,
        BoondCandidateUIStateConnected(infoMessage: null).runtimeType,
        BoondCandidateUIStateMergeSender(
                senderFullName: null, senderEmail: null)
            .runtimeType,
        BoondCandidateUIStateSaved(candidate: null).runtimeType,
      ];
      log.fine("[build] condition <${state}>");
      // if build will be trigger. Get in sync with candidate value.
      if (criteria.contains(state.runtimeType)) {
        BoondCandidateBloc b =
            BlocProvider.of<BoondCandidateBloc>(this.context);
        this.currentCandidate = b.editedCandidate;
      }
      if (state is BoondCandidateUIStateMergeSender)
        _handleMergeEmail(state, _context);

      return criteria.contains(state.runtimeType);
    }, //
        builder: (BuildContext c, BoondCandidateUIState s) {
      log.fine("[build] builder ${s.runtimeType.toString()}");

      if (s is BoondCandidateUIStateSelectRequest) {
        log.fine("[build] builder select request");

        BoondCandidateSelectDialog.selectCandidate(
                candidates: s.listToSelectIn, context: c)
            .then((boond.CandidateSearchData d) {
          log.fine("[build] selectCandidate ${d.id}");

          BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(c);
          if (b != null)
            b.add(BoondCandidateUIEventLoadRequest(candidateId: d.id));
        });
      }
      Widget w = _buildFormWrapper(c);

      return _buildDragWrapper(w, _context);
    }); //;;
  }

  void _handleFormChanged() {
    log.fine("[_handleFormChanged] form changed");
    if (this._formKey.currentState.validate()) {
      BoondCandidateBloc b = BlocProvider.of<BoondCandidateBloc>(this.context);

      b.add(BoondCandidateUIEventEditing(candidate: this.currentCandidate));
    }
  }

  void _handleMergeEmail(
      BoondCandidateUIStateMergeSender state, BuildContext c) {
    boond.CandidateGet can = this.currentCandidate;

    assert(can != null);
    can.data.attributes.lastName = state.senderFullName;
    can.data.attributes.email1 = state.senderEmail;
  }
}
