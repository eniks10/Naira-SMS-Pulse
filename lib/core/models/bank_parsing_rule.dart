class BankParsingRule {
  final int bankId;
  final String senderName;
  final String amountRegex;
  final String dateRegex;
  final String descRegex;
  final String debitIndicator;

  BankParsingRule({
    required this.bankId,
    required this.senderName,
    required this.amountRegex,
    required this.dateRegex,
    required this.descRegex,
    required this.debitIndicator,
  });

  static BankParsingRule empty() {
    return BankParsingRule(
      bankId: -1,
      senderName: '',
      amountRegex: '',
      dateRegex: '',
      descRegex: '',
      debitIndicator: '',
    );
  }
}

// The "Starter Pack" Rules
final List<BankParsingRule> nigeriaBankRules = [
  BankParsingRule(
    bankId: 1,
    senderName: 'GTBank',
    // Look for "Amt:NGN" followed by numbers
    amountRegex: r'Amt:NGN\s*([\d,.]+)',
    // Look for "Dr" to confirm debit
    debitIndicator: 'Dr',
    // Date is usually after "Dt:"
    dateRegex: r'Dt:(\d{2}-[A-Za-z]{3}-\d{4})',
    // Description is between "Desc:" and "Bal:"
    descRegex: r'Desc:(.*?)(?:\sBal:|$)',
  ),

  // 2. Access Bank (Two formats usually)
  // Format: "Debit. Amt: N5,000.00. Desc: TRF..."
  BankParsingRule(
    bankId: 2,
    senderName: 'AccessBank',
    // Note: Access uses "N" instead of "NGN" sometimes
    amountRegex: r'Amt:\s*(?:N|NGN)\s*([\d,.]+)',
    debitIndicator: 'Debit',
    // Date is often DD/MM/YYYY
    dateRegex: r'(\d{2}/\d{2}/\d{4})',
    descRegex: r'Desc:(.*?)(?:\sAvail|$)',
  ),

  // 3. First Bank
  // Format: "Acct: ...123. Amt: 5,000.00 DR. Desc:..."
  BankParsingRule(
    bankId: 5,
    senderName: 'FirstBank',
    // First bank often doesn't put currency symbol, just "Amt:"
    amountRegex: r'Amt:\s*([\d,.]+)',
    debitIndicator: 'DR',
    dateRegex: r'(\d{2}-\d{2}-\d{4})',
    descRegex: r'Desc:(.*?)(?:\sBal:|$)',
  ),

  // 4. UBA
  // Format: "Txn: Debit. Acct:..123. Amt: N5,000.00..."
  // Inside your list of rules
  BankParsingRule(
    bankId: 4, // Or whatever ID UBA is
    senderName: 'UBA', // Matches "UBA" or "UBA Alert"
    // Regex Explanation:
    // Amt:       Look for literal "Amt:"
    // \s* Optional whitespace
    // [A-Z]* Optional Currency code (NGN/USD)
    // \s* Optional whitespace
    // ([\d,.]+)  Capture Group 1: Digits, commas, and dots
    amountRegex: r'Amt:\s*[A-Z]*\s*([\d,.]+)',

    // Not strictly needed if we use the SMS timestamp,
    // but if you really want to parse it: r'Date:(\d{2}-\d{2}-\d{4})'
    dateRegex: '',

    // Capture everything after "Des:" until "Date:" or end of line
    descRegex: r'Des:(.*?)(?=Date:|$)',

    // Indicator found in the logs for debits
    debitIndicator: 'Txn:DR', // Also checks for 'Txn:Debit' in logic if needed
  ),
  // BankParsingRule(
  //   bankId: 'uba',
  //   senderName: 'UBA',
  //   amountRegex: r'Amt:\s*N([\d,.]+)',
  //   debitIndicator: 'Debit',
  //   dateRegex: r'(\d{2}-[A-Za-z]{3}-\d{2})',
  //   descRegex: r'Desc:(.*?)(?:\sBal:|$)',
  // ),

  // 5. OPay (Very popular now)
  // Format: "You have sent N5,000.00 to..." or "Debit Alert..."
  // OPay is trickier, they change often. This is a best guess.
  BankParsingRule(
    bankId: 6,
    senderName: 'OPay',
    amountRegex: r'sent\s*N([\d,.]+)',
    debitIndicator: 'sent', // "You sent..." implies debit
    dateRegex: r'(\d{4}-\d{2}-\d{2})',
    descRegex: r'to\s(.*?)\.',
  ),

  // Add more banks here...
  BankParsingRule(
    bankId: 17, // Replace with your actual Keystone Bank ID
    senderName: 'KEYSTONE', // Usually "Keystone" or "KeystoneBank"
    // Regex Explanation:
    // Amt:NGN     Match literal "Amt:NGN"
    // \s* Optional whitespace
    // -?          Optional negative sign (we usually don't need it for the parsed value)
    // ([\d,.]+)   Capture Group 1: The actual number (e.g. 44,000.00)
    amountRegex: r'Amt:NGN\s*-?([\d,.]+)',

    // Capture everything after "Desc:" until "Date:" or a new line
    // (.*?)       Non-greedy capture of the description
    // (?=Date:|$) Lookahead: Stop when you see "Date:" or end of line
    descRegex: r'Desc:(.*?)(?=Date:|$)',

    // Date format: 24-12-2025 0:0
    // Captures the date part. You might need custom parsing logic for "0:0" time.
    dateRegex: r'Date:(\d{2}-\d{2}-\d{4})',

    // The indicator is simpler here.
    // The message starts with "Debit!" or "Credit!".
    // If your logic checks the whole body, checking for "Debit!" works.
    debitIndicator: r'Debit[!:?]|Txn:\s*Debit',
  ),
];
