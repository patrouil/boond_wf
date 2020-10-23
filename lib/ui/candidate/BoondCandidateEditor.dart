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

import 'package:flutter/material.dart';

import 'BasicCandidateForm.dart';
import 'CandidateActionForm.dart';

class BoondCandidateEditor extends StatefulWidget {
  static final Logger _log = Logger('BoondCandidateEditor');

  /// Default Constructor
  BoondCandidateEditor({Key key}) : super(key: key) {
    _log.level = Level.FINEST;
  }

  @override
  State<StatefulWidget> createState() => _BoondCandidateEditorState();
}

class _BoondCandidateEditorState extends State<BoondCandidateEditor> {
  @override
  initState() {
    super.initState();
  }

  Widget buildWrapper(BuildContext _context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(flex: 50, child: Container(child: BasicCandidateForm())),
        Expanded(flex: 40, child: Container(child: CandidateActionForm())),
        //  Flexible(
        //   flex: 10,
        //  child: Container(child: CandidateDocumentEditor()),
      ],
    );
  }

  Widget buildWrapper2(BuildContext _context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BasicCandidateForm(),
        CandidateActionForm(),
      ],
    ));
  }

  @override
  Widget build(BuildContext c) {
    return buildWrapper2(c);
  }
}
