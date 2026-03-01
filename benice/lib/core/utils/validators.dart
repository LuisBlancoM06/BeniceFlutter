import 'package:flutter/services.dart';

/// Centralized input validators and formatters for the entire app.
class Validators {
  Validators._();

  // ── Regex patterns ──────────────────────────────────────────────────

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final _phoneRegex = RegExp(r'^\+?\d{9,15}$');
  static final _postalCodeRegex = RegExp(r'^\d{5}$');
  static final _onlyLettersSpaces = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
  static final _urlRegex = RegExp(
    r'^https?://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  // ── Max lengths ─────────────────────────────────────────────────────

  static const int maxName = 100;
  static const int maxFullName = 100;
  static const int maxEmail = 254;
  static const int maxPhone = 15;
  static const int maxAddress = 200;
  static const int maxCity = 100;
  static const int maxPostalCode = 5;
  static const int maxPassword = 128;
  static const int maxNotes = 500;
  static const int maxMessage = 1000;
  static const int maxSubject = 200;
  static const int maxPromoCode = 30;
  static const int maxProductName = 150;
  static const int maxProductDesc = 2000;
  static const int maxBrand = 100;
  static const int maxUrl = 500;
  static const int maxReason = 1000;
  static const int maxSearch = 100;
  static const int maxReviewComment = 1000;
  static const int maxPrice = 10; // e.g. 99999.99
  static const int maxStock = 6; // e.g. 999999

  // ── Field validators ────────────────────────────────────────────────

  static String? required(String? value, [String msg = 'Campo requerido']) {
    if (value == null || value.trim().isEmpty) return msg;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu nombre';
    if (value.trim().length < 2) return 'Mínimo 2 caracteres';
    if (value.trim().length > maxName) return 'Máximo $maxName caracteres';
    if (!_onlyLettersSpaces.hasMatch(value.trim())) {
      return 'Solo letras y espacios permitidos';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (value.trim().length < 2) return 'Mínimo 2 caracteres';
    if (value.trim().length > maxFullName) {
      return 'Máximo $maxFullName caracteres';
    }
    if (!_onlyLettersSpaces.hasMatch(value.trim())) {
      return 'Solo letras y espacios permitidos';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu email';
    if (value.trim().length > maxEmail) return 'Email demasiado largo';
    if (!_emailRegex.hasMatch(value.trim())) return 'Email inválido';
    return null;
  }

  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > maxEmail) return 'Email demasiado largo';
    if (!_emailRegex.hasMatch(value.trim())) return 'Email inválido';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono';
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) return 'Teléfono inválido';
    return null;
  }

  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) return 'Teléfono inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    if (value.length > maxPassword) return 'Máximo $maxPassword caracteres';
    return null;
  }

  static String? passwordConfirm(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu dirección';
    if (value.trim().length < 5) return 'Dirección demasiado corta';
    if (value.trim().length > maxAddress) {
      return 'Máximo $maxAddress caracteres';
    }
    return null;
  }

  static String? addressOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > maxAddress) {
      return 'Máximo $maxAddress caracteres';
    }
    return null;
  }

  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa la ciudad';
    if (value.trim().length > maxCity) return 'Máximo $maxCity caracteres';
    if (!_onlyLettersSpaces.hasMatch(value.trim())) {
      return 'Solo letras y espacios';
    }
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el código postal';
    }
    if (!_postalCodeRegex.hasMatch(value.trim())) {
      return 'C.P. debe ser 5 dígitos';
    }
    return null;
  }

  static String? notes(String? value) {
    // Optional field, just check max length
    if (value != null && value.length > maxNotes) {
      return 'Máximo $maxNotes caracteres';
    }
    return null;
  }

  static String? message(String? value) {
    if (value == null || value.trim().isEmpty) return 'Escribe un mensaje';
    if (value.trim().length < 10) return 'Mínimo 10 caracteres';
    if (value.trim().length > maxMessage) {
      return 'Máximo $maxMessage caracteres';
    }
    return null;
  }

  static String? subject(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el asunto';
    if (value.trim().length > maxSubject) {
      return 'Máximo $maxSubject caracteres';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Número inválido';
    if (parsed <= 0) return 'Debe ser mayor que 0';
    if (parsed > 99999.99) return 'Precio demasiado alto';
    return null;
  }

  static String? priceOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Número inválido';
    if (parsed < 0) return 'No puede ser negativo';
    if (parsed > 99999.99) return 'Precio demasiado alto';
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Entero inválido';
    if (parsed < 0) return 'No puede ser negativo';
    if (parsed > 999999) return 'Stock demasiado alto';
    return null;
  }

  static String? discountPercent(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Número inválido';
    if (parsed < 1 || parsed > 100) return 'Debe ser entre 1 y 100';
    return null;
  }

  static String? promoCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el código';
    if (value.trim().length > maxPromoCode) {
      return 'Máximo $maxPromoCode caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'Solo letras, números, guiones y guiones bajos';
    }
    return null;
  }

  static String? productName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    if (value.trim().length > maxProductName) {
      return 'Máximo $maxProductName caracteres';
    }
    return null;
  }

  static String? productDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    if (value.trim().length < 10) return 'Mínimo 10 caracteres';
    if (value.trim().length > maxProductDesc) {
      return 'Máximo $maxProductDesc caracteres';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (value.trim().length > maxUrl) return 'URL demasiado larga';
    if (!_urlRegex.hasMatch(value.trim())) return 'URL inválida (usa https://)';
    return null;
  }

  static String? reason(String? value) {
    if (value == null || value.trim().isEmpty) return 'Indica el motivo';
    if (value.trim().length < 10) return 'Mínimo 10 caracteres';
    if (value.trim().length > maxReason) {
      return 'Máximo $maxReason caracteres';
    }
    return null;
  }

  static String? brand(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (value.trim().length > maxBrand) return 'Máximo $maxBrand caracteres';
    return null;
  }

  // ── Input formatters ────────────────────────────────────────────────

  /// Only digits
  static TextInputFormatter digitsOnly() =>
      FilteringTextInputFormatter.digitsOnly;

  /// Only digits and + (for phone numbers)
  static TextInputFormatter phoneChars() =>
      FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-()]'));

  /// Only letters and spaces (for names, cities)
  static TextInputFormatter lettersAndSpaces() =>
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'));

  /// Decimal number (for prices)
  static TextInputFormatter decimalNumber() =>
      FilteringTextInputFormatter.allow(RegExp(r'[\d.]'));

  /// Alphanumeric + hyphens/underscores (for promo codes)
  static TextInputFormatter alphanumericCode() =>
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]'));

  /// Max length limiter
  static TextInputFormatter maxLength(int length) =>
      LengthLimitingTextInputFormatter(length);

  /// No leading/trailing whitespace
  static TextInputFormatter noLeadingSpaces() =>
      FilteringTextInputFormatter.deny(RegExp(r'^\s'));
}
