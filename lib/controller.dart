class EnteredPasscodeController {
  String _enteredPasscode = '';

  /// Clear entered passcode.
  void clear() => _enteredPasscode = '';

  /// Get entered passcode.
  String get passcode => _enteredPasscode;

  /// Set entered passcode.
  void set(String passcode) => _enteredPasscode = passcode;

  /// Append passcode.
  void append(String passcode) => _enteredPasscode += passcode;
}
