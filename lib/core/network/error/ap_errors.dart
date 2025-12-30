// import 'package:naira_sms_pulse/core/network/error/app_errors.dart';

// enum ErrType {
//   server,
//   network,
//   authentication,
//   authorization,
//   validation,
//   unknown,
// }

// class ApErrors implements Exception {
//   final String errorMessage;
//   final String userMessage;
//   final String? code;
//   final ErrType errType;
//   final Exception? originalException;
//   final Map<String, dynamic>? details;

//   ApErrors({
//     required this.errorMessage,
//     required this.userMessage,
//     this.code,
//     required this.errType,
//     this.originalException,
//     this.details,
//   });

//   factory ApErrors.server({
//     required String errorMessage,
//     String? userMessage,
//     String? code,
//     Exception? originalException,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Server Error; Try again later',
//       errType: ErrType.server,
//       code: code,
//       originalException: originalException,
//     );
//   }

//   factory ApErrors.network({
//     required String errorMessage,
//     String? userMessage,
//     String? code,
//     Exception? originalException,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Check your internet connection',
//       errType: ErrType.network,
//       code: code,
//       originalException: originalException,
//     );
//   }

//   factory ApErrors.authentication({
//     required String errorMessage,
//     String? userMessage,
//     Map<String, dynamic>? details,
//     Exception? originalException,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Authentication Failed',
//       errType: ErrType.authentication,
//       details: details,
//       originalException: originalException,
//     );
//   }

//   factory ApErrors.authorization({
//     required String errorMessage,
//     String? userMessage,
//     Map<String, dynamic>? details,
//     Exception? originalException,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Unauthorized User',
//       errType: ErrType.authorization,
//       details: details,
//       originalException: originalException,
//     );
//   }

//   factory ApErrors.validation({
//     required String errorMessage,
//     String? userMessage,
//     Map<String, dynamic>? details,
//     Exception? originalException,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Invalid Inputs',
//       errType: ErrType.validation,
//       details: details,
//       originalException: originalException,
//     );
//   }

//   factory ApErrors.unknown({
//     required String errorMessage,
//     String? userMessage,
//     Map<String, dynamic>? details,
//     Exception? originalException,
//     String? code,
//   }) {
//     return ApErrors(
//       errorMessage: errorMessage,
//       userMessage: userMessage ?? 'Unknown Error',
//       errType: ErrType.unknown,
//       details: details,
//       originalException: originalException,
//       code: code,
//     );
//   }
// }
