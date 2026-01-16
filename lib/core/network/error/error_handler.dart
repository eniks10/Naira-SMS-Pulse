import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  //Handle SupaBase Exception
  static AppErrors handleSupabaseException(dynamic error) {
    if (error is AuthException) {
      return _handleAuthException(error);
    } else if (error is PostgrestException) {
      return _handlePosPostgrestException(error);
    } else if (error is StorageException) {
      return _handleStorageException(error);
    }
    return AppErrors.server(
      errorMessage: error,
      userMessage: 'An unexpected error occurred. Please try again.',
      originalException: error is Exception
          ? error
          : Exception(error.toString()),
    );
  }

  static AppErrors _handleAuthException(AuthException error) {
    // Log the error for debugging
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // A. Invalid Credentials (Login)
    if (message.contains('invalid login credentials')) {
      return AppErrors.authentication(
        errorMessage: 'Invalid Credentials: ${error.message}',
        userMessage: 'Incorrect email or password.',
        originalException: error,
      );
    }

    // B. User Already Exists (Sign Up)
    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        (statusCode == '422' && message.contains('email'))) {
      // Supabase sometimes sends 422 for this
      return AppErrors.validation(
        errorMessage: 'Duplicate Email: ${error.message}',
        userMessage:
            'This email is already associated with an account. Try signing in.',
        originalException: error,
      );
    }

    // C. Validation (Weak Password, Bad Email)
    if (message.contains('password should be') ||
        message.contains('validation failed') ||
        statusCode == '422') {
      return AppErrors.validation(
        errorMessage: 'Validation Error: ${error.message}',
        userMessage: error
            .message, // Usually safe to show "Password must be 6 chars" directly
        originalException: error,
      );
    }

    // D. Rate Limiting (Too many requests)
    if (statusCode == '429' || message.contains('rate limit')) {
      return AppErrors(
        // Or AppErrors.server if you prefer
        errorMessage: 'Rate Limit: ${error.message}',
        userMessage:
            'Too many attempts. Please wait a moment before trying again.',
        originalException: error,
        errorType: ErrorType.client,
      );
    }

    // E. Default Auth Fallback
    return AppErrors.authentication(
      errorMessage: 'Auth Error: ${error.message}',
      userMessage: 'Authentication failed. Please try again.',
      originalException: error,
    );
  }

  static AppErrors _handlePosPostgrestException(PostgrestException error) {
    final code = error.code; // Postgres Error Codes (e.g., '23505')

    switch (code) {
      // Unique Violation (e.g., trying to save a duplicate username)
      case '23505':
        return AppErrors(
          errorMessage: 'Duplicate Entry: ${error.message}',
          userMessage: 'This record already exists.',
          originalException: error,
          code: code,
          errorType: ErrorType.validation,
        );

      // Foreign Key Violation (e.g., trying to save a Transaction for a non-existent User)
      case '23503':
        return AppErrors(
          errorMessage: 'Foreign Key Constraint: ${error.message}',
          userMessage: 'Operation failed due to invalid reference.',
          originalException: error,
          code: code,
          errorType: ErrorType.client,
        );

      // Connection/Network issues often show up as specific low-level codes or null details
      // You might need to check if the error details imply a socket error.

      // Row Level Security (RLS) Policy Violation
      case '42501':
        return AppErrors(
          errorMessage: 'RLS Policy Violation: ${error.message}',
          userMessage: 'You do not have permission to access this data.',
          originalException: error,
          code: code,
          errorType: ErrorType.authorization,
        );

      // Default DB Fallback
      default:
        return AppErrors.server(
          errorMessage: 'Database Error ($code): ${error.message}',
          userMessage: 'Something went wrong with the database.',
          originalException: error,
          code: code,
        );
    }
  }

  static AppErrors _handleStorageException(StorageException error) {
    return AppErrors.server(
      errorMessage: 'Storage Error: ${error.message}',
      userMessage: 'Failed to upload or retrieve file.',
      originalException: error,
      code: error.statusCode,
    );
  }

  static AppErrors handleCompleteErrors(dynamic error) {
    if (error is AppErrors) return error;

    if (error is TimeoutException ||
        error is SocketException ||
        error.toString().toLowerCase().contains('socketexception') ||
        error.toString().toLowerCase().contains('connection refused')) {
      return _handleNetworkException(error);
    }

    if (error is AuthException ||
        error is PostgrestException ||
        error is StorageException) {
      return handleSupabaseException(error);
    }

    return AppErrors(
      errorMessage: error.toString(),
      userMessage: 'An unexpected error occurred. Please try again.',
      errorType: ErrorType.unknown,
      originalException: error is Exception
          ? error
          : Exception(error.toString()),
    );
  }

  static AppErrors _handleNetworkException(dynamic error) {
    if (error is TimeoutException) {
      return AppErrors.network(
        errorMessage: 'Connection Timeout: $error',
        userMessage: 'The request took too long. Please check your connection.',
        originalException: Exception(error.toString()),
      );
    }

    // Default to SocketException (No Internet)
    return AppErrors.network(
      errorMessage: 'Network Error: $error',
      userMessage: 'No internet connection. Please check your settings.',
      originalException: error is Exception
          ? error
          : Exception(error.toString()),
    );
  }
}
