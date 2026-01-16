//Client majorly front dev issue with the url/ required paprameters and other
//Validation major in the app by the user. Chnage what you wrote and the issue leaves(conflicts etc)
enum ErrorType {
  server,
  authentication,
  authorization,
  network,
  client,
  unknown,
  validation,
}

class AppErrors implements Exception {
  final String errorMessage;
  final String userMessage;
  final ErrorType errorType;
  final String? code;
  final Exception? originalException;
  final Map<String, dynamic>? details;

  AppErrors({
    required this.errorMessage,
    required this.userMessage,
    required this.errorType,
    this.code,
    this.originalException,
    this.details,
  });

  factory AppErrors.server({
    required String errorMessage,
    String? userMessage,
    String? code,
    Exception? originalException,
  }) {
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage ?? 'A Server Error Occured',
      errorType: ErrorType.server,
      code: code,
      originalException: originalException,
    );
  }

  factory AppErrors.network({
    required String errorMessage,
    String? userMessage,
    Exception? originalException,
    String? code,
  }) {
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage ?? 'Check your Internet Connection',
      errorType: ErrorType.network,
    );
  }

  factory AppErrors.authentication({
    required String errorMessage,
    String? userMessage,
    Exception? originalException,
    Map<String, dynamic>? details,
  }) {
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage ?? 'Authnetication Failed',
      errorType: ErrorType.authentication,
    );
  }

  factory AppErrors.authorization({
    required String errorMessage,
    String? userMessage,
    Exception? originalException,
    Map<String, dynamic>? details,
  }) {
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage ?? 'Unauthorized User',
      errorType: ErrorType.authorization,
    );
  }

  factory AppErrors.validation({
    required String errorMessage,
    String? userMessage,
    Exception? originalException,
    Map<String, dynamic>? details,
  }) {
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage ?? 'Ivalid Inputs',
      errorType: ErrorType.validation,
    );
  }
}
