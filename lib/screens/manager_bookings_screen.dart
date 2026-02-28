import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class ManagerBookingsScreen extends StatelessWidget {
  final List<EventModel> events;

  const ManagerBookingsScreen({super.key, required this.events});

  EventModel? _getEvent(String id) {
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService.bookingsStream(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '📬 Prenotazioni Ricevute (${bookings.length})',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: kPurple),
              ),
            ),
            if (bookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    'Nessuna prenotazione ancora.',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: kTextMuted),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: bookings.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final b = bookings[i];
                  final ev = _getEvent(b.eventId);
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCard,
                      border: Border.all(color: kCardBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.customerName,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: kText)),
                              const SizedBox(height: 4),
                              Text('✉️ ${b.email}',
                                  style: labelSmall()),
                              const SizedBox(height: 2),
                              Text(
                                '📅 ${ev?.title ?? "Evento"} — ${ev != null ? _formatDate(DateTime.tryParse(ev.date)) : ""}',
                                style: labelSmall(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${b.isDinner ? "🍽 Cena + Ingresso" : "🎟 Solo Ingresso"} — ${b.guests} ${b.guests > 1 ? "persone" : "persona"}',
                                style: labelSmall(),
                              ),
                              if (b.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('📝 ${b.notes}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: kTextMuted,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: kSuccess.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('✓ Confermata',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      letterSpacing: 1,
                                      color: kSuccess)),
                            ),
                            const SizedBox(height: 8),
                            Text(_formatDate(b.createdAt),
                                style: labelSmall(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
