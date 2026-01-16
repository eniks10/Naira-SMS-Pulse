import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';

class MiningJob {
  final List<SmsMessage> messages;
  final List<BankParsingRule> rules;

  MiningJob({required this.messages, required this.rules});
}
