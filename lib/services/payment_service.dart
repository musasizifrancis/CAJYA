import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Flutterwave Payment Service for MTN Mobile Money
/// Using real sandbox credentials for testing
class PaymentService {
  // ✅ YOUR FLUTTERWAVE KEYS (Sandbox Testing)
  static const String PUBLIC_KEY = 'FLWPUBK_TEST-c59df7bc907c4e620548a61a80e2a7ad-X';
  static const String SECRET_KEY = 'FLWSECK_TEST-05fdae751dc8f8c859f4e7860904ec21-X';
  static const String FLUTTERWAVE_BASE_URL = 'https://api.flutterwave.com/v3';
  
  /// Initiate MTN Mobile Money payment
  static Future<Map<String, dynamic>> initiateWithdrawal({
    required String driverId,
    required String mtnNumber,
    required double amount,
    required String driverEmail,
    required String driverName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$FLUTTERWAVE_BASE_URL/transfers'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'account_number': mtnNumber.replaceFirst('+256', '0'), // Convert +256XXXXXXXXX to 0XXXXXXXXX
          'account_bank': '175', // MTN Mobile Money bank code for Uganda
          'amount': amount.toInt(),
          'currency': 'UGX',
          'reference': 'CAJYA-$driverId-${DateTime.now().millisecondsSinceEpoch}',
          'narration': 'CAJYA Driver Withdrawal',
          'callback_url': 'https://yourapp.com/payment/callback', // Update with your domain
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'transactionId': responseData['data']['id'],
          'status': 'pending',
          'message': 'Withdrawal initiated successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Payment failed',
          'error': responseData['data']?['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  /// Get transfer status (check if withdrawal was processed)
  static Future<Map<String, dynamic>> getTransferStatus(int transferId) async {
    try {
      final response = await http.get(
        Uri.parse('$FLUTTERWAVE_BASE_URL/transfers/$transferId'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'status': responseData['data']['status'],
          'amount': responseData['data']['amount'],
          'currency': responseData['data']['currency'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch transfer status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify payment using public key (for UI verification)
  static Future<bool> verifyPayment(String flutterReference) async {
    try {
      final response = await http.get(
        Uri.parse('$FLUTTERWAVE_BASE_URL/transactions/verify_by_reference?reference=$flutterReference'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['status'] == 'successful';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for MTN
  static String formatPhoneNumber(String phone) {
    // Accepts: +256XXXXXXXXX, 256XXXXXXXXX, 0XXXXXXXXX
    // Converts to: 0XXXXXXXXX
    phone = phone.replaceAll(' ', '').replaceAll('-', '');
    
    if (phone.startsWith('+256')) {
      return phone.replaceFirst('+256', '0');
    } else if (phone.startsWith('256')) {
      return phone.replaceFirst('256', '0');
    }
    return phone;
  }

  /// Validate MTN phone number
  static bool isValidMTNNumber(String phone) {
    final formatted = formatPhoneNumber(phone);
    // MTN Uganda: 0700-0799, 0750-0799
    final mtnPattern = RegExp(r'^0(7[0-9]{8})$');
    return mtnPattern.hasMatch(formatted);
  }

  /// Test connection with Flutterwave
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$FLUTTERWAVE_BASE_URL/merchants/verify'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
