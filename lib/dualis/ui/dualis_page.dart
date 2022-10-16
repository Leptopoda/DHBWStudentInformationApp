import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/dualis/ui/exam_results_page/exam_results_page.dart';
import 'package:dhbwstudentapp/dualis/ui/login/dualis_login_page.dart';
import 'package:dhbwstudentapp/dualis/ui/study_overview/study_overview_page.dart';
import 'package:dhbwstudentapp/dualis/ui/viewmodels/study_grades_view_model.dart';
import 'package:dhbwstudentapp/ui/pager_widget.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class DualisPage extends StatelessWidget {
  const DualisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StudyGradesViewModel viewModel =
        Provider.of<StudyGradesViewModel>(context);

    Widget widget;

    if (viewModel.loginState != LoginState.loggedIn) {
      widget = const DualisLoginPage();
    } else {
      widget = PropertyChangeProvider<StudyGradesViewModel, String>(
        value: viewModel,
        child: PagerWidget(
          pagesId: "dualis_pager",
          pages: <PageDefinition>[
            PageDefinition(
              text: L.of(context).pageDualisOverview,
              icon: const Icon(Icons.dashboard),
              builder: (BuildContext context) => const StudyOverviewPage(),
            ),
            PageDefinition(
              text: L.of(context).pageDualisExams,
              icon: const Icon(Icons.book),
              builder: (BuildContext context) => const ExamResultsPage(),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: widget,
    );
  }
}
