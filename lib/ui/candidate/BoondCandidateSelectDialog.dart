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

import 'package:logging/logging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Colors, ListTile, SimpleDialog, showDialog, Card;

import 'package:boond_api/boond_api.dart' as boond
    show CandidateSearch, CandidateSearchData;

class BoondCandidateSelectDialog {
  static final Logger log = Logger("BoondCandidateSelectDialog");

  static Future<boond.CandidateSearchData> selectCandidate({
    bool immediate = false,
    @required BuildContext context,
    @required boond.CandidateSearch candidates,
  }) async {
    log.fine("[selectCandidate]");
    return showDialog<boond.CandidateSearchData>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext c) {
          return _BoondCandidateSelectWidget(candidates: candidates);
        });
  }
}

class _BoondCandidateSelectWidget extends StatefulWidget {
  static final Logger log = BoondCandidateSelectDialog.log;

  final boond.CandidateSearch candidates;

  _BoondCandidateSelectWidget({Key key, this.candidates}) : super(key: key) {
    // log.level = Level.FINE;
  }

  @override
  State<StatefulWidget> createState() => __BoondCandidateSelectWidgetState();
}

class __BoondCandidateSelectWidgetState
    extends State<_BoondCandidateSelectWidget> {
  static final Logger log = Logger(BoondCandidateSelectDialog.log.name);

  List<ListTile> _buildListItems(BuildContext _context) {
    List<Widget> r = List<ListTile>();

    this.widget.candidates.data.forEach((boond.CandidateSearchData element) {
      r.add(Card(
        child: ListTile(
          enabled: true,
          dense: true,
          shape: RoundedRectangleBorder(),
          title: Text(
            "${element.attributes.firstName} ${element.attributes.lastName}",
            softWrap: false,
          ),
          subtitle: Text(
            element.attributes.email1,
            softWrap: false,
          ),
          onTap: () {
            Navigator.pop(_context, element);
          },
        ),
      ));
    });

    return r;
  }

  @override
  Widget build(BuildContext context) {
    log.fine("[build]");

    return SimpleDialog(
        title: const Text(
          'Select Candidate',
          textAlign: TextAlign.center,
        ),
        elevation: 5,
        children: [
          Container(
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(border: Border.all()),
            constraints: BoxConstraints.expand(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5),
            color: Colors.white,
            child: ListView(
              children: _buildListItems(context),
            ),
          ),
        ]);
  }
}
