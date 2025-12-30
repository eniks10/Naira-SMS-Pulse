import 'package:dio/dio.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';

class ErrorHandler {
  // Handle DioException
  static AppErrors handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return handleNetworkError(
          error: error,
          errormessage: 'Connection timed out ${error.message}',
          userMessage:
              'The request is taking too long. Please check your connection and try again.',
        );

      case DioExceptionType.badResponse:
        return _handleServerError(error);

      case DioExceptionType.connectionError:
        return handleNetworkError(
          error: error,
          errormessage: 'Connection Failed${error.message}',
          userMessage:
              'Unable to connect to the server. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return handleNetworkError(
          error: error,
          errormessage: 'Certificate Error ${error.message}',
          userMessage: 'Security certificate error. Please try again later.',
        );

      case DioExceptionType.cancel:
        return handleNetworkError(
          error: error,
          errormessage: 'Request Cancelled ${error.message}',
          userMessage: 'Request was cancelled.',
        );

      case DioExceptionType.unknown:
        return handleNetworkError(
          error: error,
          errormessage: 'Unknown Error${error.type}',
          userMessage: 'An unexpected error occurred. Please try again.',
        );
    }
  }

  //Handle Network Errors(No status code cause they don't reach the server)
  static AppErrors handleNetworkError({
    required DioException error,
    required String errormessage,
    required String userMessage,
  }) {
    return AppErrors(
      errorMessage: errormessage,
      userMessage: userMessage,
      errorType: ErrorType.network,
      originalException: error,
    );
  }

  //Handle BadRequest(Server Errors)
  static AppErrors _handleServerError(DioException error) {
    final statuscode = error.response?.statusCode;

    String errorMessage = 'Unhandled Status Code: $statuscode';
    String userMessage = 'Something went wrong. Please try again.';
    ErrorType errorType = ErrorType.unknown;

    switch (statuscode) {
      //Bad Request(Dev Error; backend cannot understand the request due to wrong parameter names; invalid query parameter and more)
      case 400:
        errorMessage = 'Bad Request${error.message}';
        userMessage =
            "Something went wrong. Please update the app or try again.";
        errorType = ErrorType.client;
        break;

      //Unathorized(Token Expired and co; so the is not recognised at all)
      case 401:
        errorMessage = 'UnAuthorized${error.message}';
        userMessage = 'Session expired, sign in again';
        errorType = ErrorType.authentication;
        break;

      //Forbidden(User is recognised; but trying to perform an action he doesnt have clearance to do or see)
      case 403:
        errorMessage = 'Forbidden${error.message}';
        userMessage = 'You do not have permission to perform this action';
        errorType = ErrorType.authorization;
        break;

      // Not Found(backend understands the request but cannot find the page e.g /user/999 when such Id doesn't exist)
      case 404:
        errorMessage = 'Not Found${error.message}';
        userMessage = 'The request resource was not found';
        errorType = ErrorType.client;
        break;

      // Conflict(Like Email already exist)
      case 409:
        String message = 'Conflict detected. Please try again';
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic>) {
          message =
              responseData['message'] ?? 'Conflict detected. Please try again';
        }
        errorMessage = 'Conflict${error.message}';
        userMessage = message;
        errorType = ErrorType.validation;
        break;

      //A bit like 400 but the backend understand the request but the request has invalid variables or the data passed doesnt obey the rules et by backend(like /String and you give /int Or -5 in aplace acceting int or password is just % characters instread of 8)
      case 422:
        errorMessage = 'Unprocessable Entity${error.message}';
        userMessage = 'Invalid data provided. Please check your input.';
        errorType = ErrorType.validation;
        break;

      //Too may Request
      case 429:
        errorMessage = 'Too many Request${error.message}';
        userMessage = 'Too many Requests';
        errorType = ErrorType.client;
        break;

      //Server Errors
      //Interneal Server Error
      case 500:
        errorMessage = 'Internal Server Error${error.message}';
        userMessage =
            'Something went wrong on our servers. Please try again later';
        errorType = ErrorType.server;
        break;

      case 501:
      case 503:
      case 504:
        errorMessage = 'Server Down${error.message}';
        userMessage =
            'The Serveice is temporarily down. Please try again later';
        errorType = ErrorType.server;
        break;
    }
    return AppErrors(
      errorMessage: errorMessage,
      userMessage: userMessage,
      errorType: errorType,
      code: statuscode.toString(),
      originalException: error,
    );
  }
}
