import 'dart:convert';

import 'package:crypto/crypto.dart';

const _hashPrefix = 'sha256:';

/// Hash a password with SHA-256 and return it prefixed with `sha256:`.
String hashPassword(String password) {
  final hash = sha256.convert(utf8.encode(password)).toString();
  return '$_hashPrefix$hash';
}

/// Return `true` when [inputPassword] matches [storedHash].
///
/// Supports both hashed (`sha256:...`) and legacy plain-text passwords.
bool verifyPassword(String storedHash, String inputPassword) {
  if (storedHash.startsWith(_hashPrefix) &&
      storedHash.length > _hashPrefix.length + 16) {
    return storedHash == hashPassword(inputPassword);
  }
  return storedHash == inputPassword;
}

/// Return `true` when the password is at least 8 characters long and contains
/// both a letter and a digit.
bool isStrongPassword(String password) {
  if (password.length < 8) return false;
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  return hasLetter && hasDigit;
}
