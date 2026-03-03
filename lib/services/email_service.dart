import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // ── Configura questi valori dopo aver creato l'account EmailJS ────────────
  static const _serviceId  = 'service_0782ncn';
  static const _templateId = 'template_0sgawk9';
  static const _publicKey  = 'ayYRb1YrRS4Moq2zJ';
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> sendBookingConfirmation({
    required String toName,
    required String toEmail,
    required String eventName,
    required String eventDay,
    required String eventDate,
    required String option,
    required int guests,
    required int total,
    String notes = '',
  }) async {
    final optionLabel = option == 'dinner' ? 'Cena + Ingresso' : 'Solo Ingresso';

    final body = jsonEncode({
      'service_id':  _serviceId,
      'template_id': _templateId,
      'user_id':     _publicKey,
      'template_params': {
        'to_name':    toName,
        'to_email':   toEmail,
        'event_name': eventName,
        'event_day':  eventDay,
        'event_date': eventDate,
        'option':     optionLabel,
        'guests':     guests.toString(),
        'total':      'euro $total',
        'notes':      notes.isEmpty ? 'Nessuna' : notes,
      },
    });

    await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }
}
