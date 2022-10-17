import 'package:dhbwstudentapp/common/util/cancellation_token.dart';
import 'package:dhbwstudentapp/dualis/model/credentials.dart';
import 'package:dhbwstudentapp/dualis/service/dualis_service.dart';
import 'package:dhbwstudentapp/dualis/service/dualis_website_model.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/access_denied_extract.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/login_redirect_url_extract.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/timeout_extract.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/urls_from_main_page_extract.dart';
import 'package:dhbwstudentapp/dualis/service/session.dart';
import 'package:dhbwstudentapp/schedule/service/schedule_source.dart';
import 'package:http/http.dart';

///
/// This class handles the dualis authentication. To make api calls first login
/// with the username and password and then use the [authenticatedGet] method.
///
class DualisAuthentication {
  DualisAuthentication();

  final RegExp _tokenRegex = RegExp("ARGUMENTS=-N([0-9]{15})");

  Credentials? _credentials;

  // TODO: [Leptopoda] make singletons :)

  DualisUrls? _dualisUrls;
  DualisUrls get dualisUrls => _dualisUrls ??= DualisUrls();

  String? _authToken;
  Session? _session;
  Session get session => _session ??= Session();

  LoginResult _loginState = LoginResult.loggedOut;
  LoginResult get loginState => _loginState;

  Future<LoginResult> login(
    Credentials credentials,
    CancellationToken? cancellationToken,
  ) async {
    _credentials = credentials;

    final loginResponse = await _makeLoginRequest(
      credentials,
      cancellationToken,
    );

    if (loginResponse == null ||
        loginResponse.statusCode != 200 ||
        !loginResponse.headers.containsKey("refresh")) {
      return _loginState = LoginResult.loginFailed;
    }

    // TODO: Test for login failed page

    final redirectUrl = const LoginRedirectUrlExtract().getUrlFromHeader(
      loginResponse.headers['refresh'],
      dualisEndpoint,
    );

    if (redirectUrl == null) {
      return _loginState = LoginResult.loginFailed;
    }

    final redirectPage = await session.get(
      redirectUrl,
      cancellationToken,
    );

    dualisUrls.mainPageUrl = const LoginRedirectUrlExtract().readRedirectUrl(
      redirectPage,
      dualisEndpoint,
    );

    if (dualisUrls.mainPageUrl == null) {
      return _loginState = LoginResult.loginFailed;
    }

    _updateAccessToken(dualisUrls.mainPageUrl!);

    final mainPage = await session.get(
      dualisUrls.mainPageUrl!,
      cancellationToken,
    );

    const UrlsFromMainPageExtract().parseMainPage(
      mainPage,
      dualisUrls,
      dualisEndpoint,
    );

    return _loginState = LoginResult.loggedIn;
  }

  Future<Response?> _makeLoginRequest(
    Credentials credentials, [
    CancellationToken? cancellationToken,
  ]) async {
    const loginUrl = "$dualisEndpoint/scripts/mgrqispi.dll";

    final data = {
      "usrname": credentials.username,
      "pass": credentials.password,
      "APPNAME": "CampusNet",
      "PRGNAME": "LOGINCHECK",
      "ARGUMENTS": "clino,usrname,pass,menuno,menu_type,browser,platform",
      "clino": "000000000000001",
      "menuno": "000324",
      "menu_type": "classic",
      "browser": "",
      "platform": "",
    };

    try {
      final loginResponse = await session.rawPost(
        loginUrl,
        data,
        cancellationToken,
      );
      return loginResponse;
    } on ServiceRequestFailed {
      return null;
    }
  }

  ///
  /// Use this method to make GET requests to the dualis service.
  ///
  /// This method handles the authentication cookie and token. If the session
  /// timed out, it will renew the session by logging in again
  ///
  Future<String?> authenticatedGet(
    String url,
    CancellationToken? cancellationToken,
  ) async {
    assert(_credentials != null);

    final result = await session.get(
      _fillUrlWithAuthToken(url),
      cancellationToken,
    );

    if (result == null) return null;

    cancellationToken?.throwIfCancelled();

    if (!const TimeoutExtract().isTimeoutErrorPage(result) &&
        !const AccessDeniedExtract().isAccessDeniedPage(result)) {
      return result;
    }

    final loginResult = await login(_credentials!, cancellationToken);

    if (loginResult == LoginResult.loggedIn) {
      return session.get(
        _fillUrlWithAuthToken(url),
        cancellationToken,
      );
    }

    return null;
  }

  Future<void> logout([
    CancellationToken? cancellationToken,
  ]) async {
    final logoutRequest = session.get(dualisUrls.logoutUrl, cancellationToken);

    _session = null;
    _dualisUrls = null;
    _loginState = LoginResult.loggedOut;

    await logoutRequest;
  }

  ///
  /// After the login sequence call this method with an url which contains the
  /// new authentication token. The url of every subsequent api call must be
  /// wrapped in a [fillUrlWithAuthToken()] call
  ///
  void _updateAccessToken(String urlWithNewToken) {
    final tokenMatch = _tokenRegex.firstMatch(urlWithNewToken);

    if (tokenMatch != null) {
      _authToken = tokenMatch.group(1);
    }
  }

  ///
  /// The dualis urls contain an authentication token which changes with every new login.
  /// When an api call is made with an old authentication token it will result in a
  /// permission denied error. So before every api call you have to fill in the
  /// updated api token
  ///
  String _fillUrlWithAuthToken(String url) {
    final match = _tokenRegex.firstMatch(url);
    if (match != null) {
      return url.replaceRange(
        match.start,
        match.end,
        "ARGUMENTS=-N$_authToken",
      );
    }

    return url;
  }

  set loginCredentials(Credentials credentials) {
    _credentials = credentials;
  }

  Future<LoginResult> loginWithPreviousCredentials(
    CancellationToken cancellationToken,
  ) async {
    assert(_credentials != null);
    return login(_credentials!, cancellationToken);
  }
}
