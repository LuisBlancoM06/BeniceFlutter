import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Resultado del pago con Stripe
class StripePaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;

  StripePaymentResult({
    required this.success,
    this.paymentIntentId,
    this.error,
  });
}

/// Servicio para procesar pagos con Stripe API directamente.
/// Usado en plataformas donde el SDK nativo de Stripe no está disponible (Windows/Linux).
class StripePaymentService {
  static const String _baseUrl = 'https://api.stripe.com/v1';

  /// Crea un token de Stripe a partir de los datos de tarjeta.
  /// Usa la publishable key (seguro para el cliente).
  static Future<StripePaymentResult> createCardToken({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tokens'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.stripePublishableKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'card[number]': cardNumber.replaceAll(' ', ''),
          'card[exp_month]': expMonth,
          'card[exp_year]': expYear,
          'card[cvc]': cvc,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return StripePaymentResult(success: true, paymentIntentId: data['id']);
      } else {
        final errorMsg = data['error']?['message'] ?? 'Error al crear token';
        return StripePaymentResult(success: false, error: errorMsg);
      }
    } catch (e) {
      return StripePaymentResult(
        success: false,
        error: 'Error de conexión: $e',
      );
    }
  }

  /// Crea y confirma un PaymentIntent con el token de la tarjeta.
  /// NOTA: En producción esto debe hacerse desde un servidor/Edge Function.
  /// Aquí se usa la secret key directamente porque es un entorno de test.
  static Future<StripePaymentResult> createAndConfirmPayment({
    required String tokenId,
    required int amountInCents,
    String currency = 'eur',
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      // 1. Crear PaymentIntent
      final body = <String, String>{
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_data[type]': 'card',
        'payment_method_data[card][token]': tokenId,
        'confirm': 'true',
        'return_url': 'https://benice.flutter/checkout/success',
      };

      if (description != null) {
        body['description'] = description;
      }

      if (metadata != null) {
        metadata.forEach((key, value) {
          body['metadata[$key]'] = value;
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final status = data['status'];
        if (status == 'succeeded') {
          return StripePaymentResult(
            success: true,
            paymentIntentId: data['id'],
          );
        } else if (status == 'requires_action') {
          return StripePaymentResult(
            success: false,
            error:
                'Este pago requiere autenticación adicional (3D Secure). '
                'Por favor, usa otra tarjeta de prueba.',
          );
        } else {
          return StripePaymentResult(
            success: false,
            error: 'Estado del pago: $status',
          );
        }
      } else {
        final errorMsg = data['error']?['message'] ?? 'Error al procesar pago';
        return StripePaymentResult(success: false, error: errorMsg);
      }
    } catch (e) {
      return StripePaymentResult(
        success: false,
        error: 'Error de conexión: $e',
      );
    }
  }

  /// Flujo completo: crear token + crear y confirmar PaymentIntent
  static Future<StripePaymentResult> processPayment({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    required double amount,
    String currency = 'eur',
    String? description,
    Map<String, String>? metadata,
  }) async {
    // Paso 1: Crear token con los datos de la tarjeta
    final tokenResult = await createCardToken(
      cardNumber: cardNumber,
      expMonth: expMonth,
      expYear: expYear,
      cvc: cvc,
    );

    if (!tokenResult.success) {
      return tokenResult;
    }

    // Paso 2: Crear y confirmar PaymentIntent
    final amountInCents = (amount * 100).round();
    return createAndConfirmPayment(
      tokenId: tokenResult.paymentIntentId!,
      amountInCents: amountInCents,
      currency: currency,
      description: description,
      metadata: metadata,
    );
  }
}
