import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class ManagerBookingsScreen extends StatefulWidget {
  final List<EventModel> events;

  const ManagerBookingsScreen({super.key, required this.events});

  @override
  State<ManagerBookingsScreen> createState() => _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState extends State<ManagerBookingsScreen> {
  bool _showArchive = false;

  EventModel? _getEvent(String id) {
    try {
      return widget.events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  bool _isEventPast(String eventId) {
    final ev = _getEvent(eventId);
    if (ev == null) return false;
    final d = DateTime.tryParse(ev.date);
    if (d == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return d.isBefore(todayDate);
  }

  Widget _buildList(List<BookingModel> bookings) {
    return ListView.separated(
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
            color: const Color(0xFF1565C0),
            border: Border.all(color: const Color(0xFF0D47A1)),
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
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('✉️ ${b.email}',
                        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '📅 ${ev?.title ?? "Evento"} — ${ev != null ? _formatDate(DateTime.tryParse(ev.date)) : ""}',
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${b.isDinner ? "🍽 Cena + Ingresso" : "🎟 Solo Ingresso"} — ${b.guests} ${b.guests > 1 ? "persone" : "persona"}',
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    if (b.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('📝 ${b.notes}',
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic)),
                    ],
                    if (b.status != 'cancellata' && b.status != 'presente') ...[
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => BookingService.confirmArrival(b.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.how_to_reg, size: 16),
                        label: Text('Conferma Arrivo',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: b.status),
                  const SizedBox(height: 8),
                  Text(_formatDate(b.createdAt),
                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService.bookingsStream(),
      builder: (context, snapshot) {
        final all = (snapshot.data ?? [])
          ..sort((a, b) {
            final evA = _getEvent(a.eventId);
            final evB = _getEvent(b.eventId);
            final dateA = evA != null ? (DateTime.tryParse(evA.date) ?? DateTime(0)) : DateTime(0);
            final dateB = evB != null ? (DateTime.tryParse(evB.date) ?? DateTime(0)) : DateTime(0);
            final dateCompare = dateA.compareTo(dateB);
            if (dateCompare != 0) return dateCompare;
            return a.customerName.compareTo(b.customerName);
          });

        final upcoming = all.where((b) => !_isEventPast(b.eventId)).toList();
        final past = all.where((b) => _isEventPast(b.eventId)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '📬 Prenotazioni Ricevute (${upcoming.length})',
                style: GoogleFonts.abrilFatface(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: kPurple),
              ),
            ),

            if (upcoming.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Nessuna prenotazione in arrivo.',
                    style: GoogleFonts.abrilFatface(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: kTextMuted),
                  ),
                ),
              )
            else
              _buildList(upcoming),

            // ── Archivio prenotazioni passate ─────────────────────────────────
            if (past.isNotEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showArchive = !_showArchive),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(_showArchive ? Icons.expand_less : Icons.expand_more, size: 18),
                  label: Text(
                    _showArchive
                        ? 'Nascondi archivio'
                        : '📂 Archivio (${past.length} ${past.length == 1 ? "prenotazione passata" : "prenotazioni passate"})',
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              if (_showArchive) ...[
                const SizedBox(height: 32),
                Center(
                  child: Text('PRENOTAZIONI PASSATE',
                      style: GoogleFonts.abrilFatface(
                          fontSize: 28,
                          color: const Color(0xFF1565C0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3)),
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF1565C0),
                  thickness: 2,
                  indent: 24,
                  endIndent: 24,
                ),
                const SizedBox(height: 24),
                _buildList(past),
              ],
            ],

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'presente':
        bg = const Color(0xFF00897B);
        fg = Colors.white;
        label = '✔ Presente';
        break;
      case 'modificata':
        bg = const Color(0xFFFDD835);
        fg = Colors.black;
        label = '✎ Modificata';
        break;
      case 'cancellata':
        bg = const Color(0xFFCC4444);
        fg = Colors.white;
        label = '✕ Cancellata';
        break;
      default:
        bg = const Color(0xFF2E7D32);
        fg = Colors.white;
        label = '✓ Confermata';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}
