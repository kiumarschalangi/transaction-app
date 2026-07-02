abstract final class AppStrings {
  // App identity
  static const String appName = 'RetroReq';
  static const String appTitle = 'Retro Terminal';
  static const String fontFamily = 'Courier';
  static const String copyright = '© 2025 · KIUMARS CHAHARLANGI';

  // AppBar / live indicator
  static const String liveLabel = 'LIVE';

  // Settings drawer
  static const String settingsTitle = 'SETTINGS';
  static const String lightModeLabel = 'LIGHT MODE';
  static const String asciiSwitchOn = '[====ON ]';
  static const String asciiSwitchOff = '[ OFF===]';
  static const String themePrefsKey = 'is_light_mode';

  // Request config section
  static const String urlHint = 'Enter URL  (e.g. https://…)';
  static const String dropdownArrow = '▼';
  static const String addRequestBody = 'ADD REQUEST BODY';
  static const String hideRequestBody = 'HIDE REQUEST BODY';
  static const String bodyExpandIcon = '+';
  static const String bodyCollapseIcon = '−';
  static const String requestBodyLabel = 'REQUEST BODY · JSON';
  static const String requestBodyHint = '{\n  "key": "value"\n}';
  static const String sendIcon = '▶';
  static const String sendRequest = 'SEND REQUEST';
  static const String transmitting = 'TRANSMITTING…';

  // Terminal container
  static const String apiTerminalTitle = 'API Terminal';
  static const String clearButton = 'CLEAR';
  static const String terminalPrompt = '> ';

  // Terminal log messages
  static const String systemOnline = '> SYSTEM ONLINE · AWAITING REQUEST';
  static const String terminalCleared = '> TERMINAL CLEARED';
  static const String noUrlError = '✕ NO URL PROVIDED';
  static const String invalidUrlError = '✕ INVALID URL FORMAT';
  static const String emptyResponseBody = '(empty response body)';
  static const String requestTimedOutLog = '✕ REQUEST TIMED OUT';
  static const String requestFailedLog = '✕ REQUEST FAILED';

  // HTTP client
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String requestTimedOut = 'Request timed out';
  static const String snackbarTimeout = 'Request timed out. Please try again.';
  static const String snackbarFailure = 'Request failed';

  // Dev screen
  static const String devToolsLabel = 'DEV TOOLS';
  static const String devToolsTitle = 'DEV TOOLS v1.0';
  static const String devModeBadge = 'DEBUG MODE — NOT FOR PRODUCTION';
  static const String devPresetsLabel = 'TEST PRESETS';
  static const String devUrlHint = 'Enter URL';
  static const String devRequestBodyHint = 'Request body (JSON)...';
  static const String responseTerminalTitle = 'Response Terminal';

  // Legacy / unused — kept for backwards compatibility
  static const String sendingToKafka = '> SENDING {type} TO KAFKA SERVICE...';
  static const String requestPayload = '> REQUEST PAYLOAD:';
  static const String response = '> RESPONSE: {response}';
  static const String requestComplete = '> {type} REQUEST COMPLETE';
  static const String requestTimeoutError = '> ERROR: Request timed out.';
  static const String error = '> ERROR';
  static const String appBarTitle = 'RETRO KAFKA PROJECT v1.0';
  static const String terminalTitle = 'TERMINAL';
  static const String deposit = 'DEPOSIT';
  static const String withdraw = 'WITHDRAW';
  static const String menuButton = '[MENU]';
}
