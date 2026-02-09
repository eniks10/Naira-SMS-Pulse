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
    bankId: 1, // GTBank ID
    senderName: 'GTBank', // Matches sender "GTBank"
    // Regex Explanation:
    // Amt:\s*NGN   -> Matches "Amt:" followed by whitespace and "NGN"
    // ([\d,.]+)    -> Capture Group 1: The actual amount (e.g., "6,000.00")
    //
    // Note: We don't hardcode "DR" here because sometimes it's on a new line.
    amountRegex: r'Amt:\s*NGN([\d,.]+)',

    // The indicator found in your text to confirm this is a Debit.
    // Your samples show "DR" either on the same line or the next line.
    debitIndicator: 'DR',

    // Regex Explanation:
    // Date:\s* -> Matches "Date:" followed by whitespace
    // (\d{4}-\d{2}-\d{2}) -> Capture Group 1: YYYY-MM-DD (e.g., 2026-01-16)
    dateRegex: r'Date:\s*(\d{4}-\d{2}-\d{2})',

    // Regex Explanation:
    // Desc:\s* -> Matches "Desc:" start
    // ([\s\S]*?)   -> Capture Group 1: Match EVERYTHING (including newlines) lazily...
    // (?=Avail Bal:|$) -> ...until we hit "Avail Bal:" or the end of the text.
    descRegex: r'Desc:\s*([\s\S]*?)(?=Avail Bal:|$)',
  ),

  BankParsingRule(
    bankId: 2, // AccessBank ID
    senderName: 'AccessBank', // Matches "AccessBank", "AccessBNK", etc.
    // Regex Explanation:
    // Amt:\s* -> Matches "Amt:" and optional space
    // (?:N|NGN)    -> Non-capturing group: Matches either "N" or "NGN"
    // \s* -> Optional space
    // ([\d,.]+)    -> Capture Group 1: The amount digits
    amountRegex: r'Amt:\s*(?:N|NGN)\s*([\d,.]+)',

    // "Debit" appears explicitly at the start of your sample
    debitIndicator: 'Debit',

    // Regex Explanation:
    // Date:\s* -> Matches "Date:"
    // (\d{2}/\d{2}/\d{4}) -> Capture Group 1: Matches DD/MM/YYYY (26/01/2026)
    dateRegex: r'Date:\s*(\d{2}/\d{2}/\d{4})',

    // Regex Explanation:
    // Desc:\s* -> Start at "Desc:"
    // (.*?)        -> Capture everything lazily...
    // (?=\s*Date:) -> ...until we see "Date:" (Lookahead)
    // We stop at Date because in your sample, Date comes right after Desc.
    descRegex: r'Desc:\s*(.*?)(?=\s*Date:|$)',
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

  BankParsingRule(
    bankId: 15,
    senderName: 'WemaBank', // Matches "WemaBank" or "ALAT"
    // Regex Explanation:
    // (?:DR|Amt)   -> Non-capturing group: Matches either "DR" or "Amt" (Credits usually use Amt or CR)
    // :\s*NGN      -> Matches colon, optional space, and "NGN"
    // \s* -> Optional space
    // ([\d,.]+)    -> Capture Group 1: The amount (e.g., "10,100.00")
    amountRegex: r'(?:DR|Amt|CR):\s*NGN\s*([\d,.]+)',

    // The sample starts immediately with "DR:", so that's our debit flag.
    debitIndicator: 'DR:',

    // Regex Explanation:
    // (\d{2}-\d{2}-\d{4}) -> Matches DD-MM-YYYY (e.g., 12-01-2026)
    // found at the end of your sample.
    dateRegex: r'(\d{2}-\d{2}-\d{4})',

    // Regex Explanation:
    // Desc\s*:     -> Matches "Desc" followed by optional space and colon (Sample has "Desc :")
    // (.*?)        -> Lazy capture of description text...
    // (?=\s*Bal)   -> ...until it sees "Bal" (Lookahead).
    descRegex: r'Desc\s*:(.*?)(?=\s*Bal)',
  ),
];
