import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/ui/onboarding/viewmodels/mannheim_view_model.dart';
import 'package:dhbwstudentapp/ui/onboarding/viewmodels/onboarding_view_model_base.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class MannheimPage extends StatelessWidget {
  const MannheimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Center(
            child: Text(
              L.of(context).onboardingMannheimTitle,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Divider(),
        ),
        Text(
          L.of(context).onboardingMannheimDescription,
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: SelectMannheimCourseWidget(),
          ),
        ),
      ],
    );
  }
}

class SelectMannheimCourseWidget extends StatelessWidget {
  const SelectMannheimCourseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<OnboardingStepViewModel, String>(
      builder: (
        BuildContext context,
        OnboardingStepViewModel? model,
        Set<Object>? _,
      ) {
        final viewModel = model as MannheimViewModel?;

        switch (viewModel?.loadingState) {
          case LoadCoursesState.loading:
            return _buildLoadingIndicator();
          case LoadCoursesState.loaded:
            return _buildCourseList(context, viewModel!);
          case LoadCoursesState.failed:
          default:
            return _buildLoadingError(context, viewModel);
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCourseList(BuildContext context, MannheimViewModel viewModel) {
    return Material(
      color: Colors.transparent,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: viewModel.courses?.length ?? 0,
        itemBuilder: (BuildContext context, int index) =>
            _buildCourseListTile(viewModel, index, context),
      ),
    );
  }

  ListTile _buildCourseListTile(
    MannheimViewModel viewModel,
    int index,
    BuildContext context,
  ) {
    // TODO: [Leptopoda] why is nullsafety garanttueed here but checked above ¿?
    final isSelected = viewModel.selectedCourse == viewModel.courses![index];

    return ListTile(
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.secondary,
            )
          : null,
      title: Text(
        viewModel.courses![index].name,
        style: isSelected
            ? TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              )
            : null,
      ),
      subtitle: Text(viewModel.courses![index].title),
      onTap: () => viewModel.setSelectedCourse(viewModel.courses![index]),
    );
  }

  Widget _buildLoadingError(
    BuildContext context,
    MannheimViewModel? viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(L.of(context).onboardingMannheimLoadCoursesFailed),
          Padding(
            padding: const EdgeInsets.all(16),
            child: MaterialButton(
              onPressed: viewModel?.loadCourses,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
