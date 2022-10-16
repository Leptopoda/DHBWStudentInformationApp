import 'package:dhbwstudentapp/common/util/cancellation_token.dart';
import 'package:dhbwstudentapp/common/util/date_utils.dart';
import 'package:dhbwstudentapp/dualis/model/credentials.dart';
import 'package:dhbwstudentapp/dualis/service/dualis_scraper.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/parsing_utils.dart';
import 'package:dhbwstudentapp/schedule/model/schedule.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_query_result.dart';
import 'package:dhbwstudentapp/schedule/service/schedule_source.dart';

class DualisScheduleSource extends ScheduleSource {
  final DualisScraper _dualisScraper;

  DualisScheduleSource(this._dualisScraper, Credentials credentials) {
    _dualisScraper.loginCredentials = credentials;
  }

  @override
  Future<ScheduleQueryResult> querySchedule(
    DateTime from,
    DateTime to, [
    CancellationToken? cancellationToken,
  ]) async {
    cancellationToken ??= CancellationToken();

    DateTime current = from.startOfMonth;

    var schedule = const Schedule();
    final allErrors = <ParseError>[];

    if (!_dualisScraper.isLoggedIn()) {
      await _dualisScraper.loginWithPreviousCredentials(cancellationToken);
    }

    while (to.isAfter(current) && !cancellationToken.isCancelled) {
      try {
        final monthSchedule = await _dualisScraper.loadMonthlySchedule(
          current,
          cancellationToken,
        );

        schedule.merge(monthSchedule);
      } on OperationCancelledException {
        rethrow;
      } on ParseException catch (ex, trace) {
        allErrors.add(ParseError(ex, trace));
      } catch (e, trace) {
        print(trace);
        throw ScheduleQueryFailedException(e, trace);
      }

      current = current.nextMonth;
    }

    cancellationToken.throwIfCancelled();

    schedule = schedule.trim(from, to);

    return ScheduleQueryResult(schedule, allErrors);
  }

  @override
  bool canQuery() {
    return _dualisScraper.isLoggedIn();
  }
}
