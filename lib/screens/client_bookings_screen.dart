import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'booking_screen.dart';

class ClientBookingsScreen extends StatefulWidget {
  final UserModel user;
  final List<EventModel> events;

  const ClientBookingsScreen({
    super.key,
    required this.user,
    required this.events,
  });

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  bool _showArchive = false;

  EventModel? _getEvent(String id) {
    try {
      return widget.events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  bool _isEventPast(String eventId) {
    final ev = _getEvent(eventId);
    if (ev == null) return false;
    final d = DateTime.tryParse(ev.date);
    if (d == null) return false;
    final today = DateTime.now();
    return d.isBefore(DateTime(today.year, today.month, today.day));
  }

  Future<void> _cancelBooking(BuildContext ctx, BookingModel booking) async {
    final ev = _getEvent(booking.eventId);
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kCardBorder)),
        title: Text('Cancella prenotazione',
            style: GoogleFonts.abrilFatface(fontSize: 20, color: kText)),
        content: Text(
            'Vuoi cancellare la prenotazione per "${ev?.title ?? "questo evento"}"?',
            style: GoogleFonts.montserrat(fontSize: 13, color: kTextSecond)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFCC4444)),
            child: const Text('Cancella'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await BookingService.cancelBooking(booking);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Prenotazione cancellata.')));
      }
    }
  }

  void _editBooking(BuildContext ctx, BookingModel booking, EventModel event) {
    showDialog(
      context: ctx,
      builder: (_) => BookingScreen(
        event: event,
        user: widget.user,
        existingBooking: booking,
      ),
    );
  }

  Widget _buildCard(BookingModel b, {required bool canEdit}) {
    final ev = _getEvent(b.eventId);
    final isCancelled = b.status == 'cancellata';

    return Builder(builder: (ctx) {
      return Opacity(
        opacity: isCancelled ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCancelled ? const Color(0xFF1A1020) : kCard,
            border: Border.all(
                color: isCancelled
                    ? const Color(0xFF4A1A1A)
                    : const Color(0xFF2E1E3A)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ev?.title ?? 'Evento',
                            style: GoogleFonts.abrilFatface(
                                fontSize: 18, color: kText)),
                        const SizedBox(height: 4),
                        Text(
                          '📅 ${ev != null ? _formatDate(ev.date) : ""}  ·  🕘 ${ev?.time ?? ""}',
                          style: GoogleFonts.montserrat(
                              fontSize: 12, color: kTextSecond, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${b.isDinner ? "🍽 Cena + Ingresso" : "🎟 Solo Ingresso"} — ${b.guests} ${b.guests > 1 ? "persone" : "persona"}',
                          style: GoogleFonts.montserrat(
                              fontSize: 12, color: kTextSecond, fontWeight: FontWeight.w600),
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
                  _StatusBadge(status: b.status),
                ],
              ),

              // ── Pulsanti modifica/cancella (solo future non cancellate e non presenti) ──
              if (canEdit && !isCancelled && b.status != 'presente') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: ev != null ? () => _editBooking(ctx, b, ev) : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4A853),
                          side: const BorderSide(color: Color(0xFF5A4000)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('✏ Modifica',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(ctx, b),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCC4444),
                          side: const BorderSide(color: Color(0xFF4A1A1A)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('🗑 Cancella',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildList(List<BookingModel> bookings, {required bool canEdit}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCard(bookings[i], canEdit: canEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService.bookingsByUidStream(widget.user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(60),
            child: CircularProgressIndicator(color: kPurple),
          ));
        }

        final all = snapshot.data ?? [];
        all.sort((a, b) {
          final evA = _getEvent(a.eventId);
          final evB = _getEvent(b.eventId);
          final dateA = evA != null ? (DateTime.tryParse(evA.date) ?? DateTime(0)) : DateTime(0);
          final dateB = evB != null ? (DateTime.tryParse(evB.date) ?? DateTime(0)) : DateTime(0);
          return dateA.compareTo(dateB);
        });

        final upcoming = all.where((b) => !_isEventPast(b.eventId)).toList();
        final past = all.where((b) => _isEventPast(b.eventId)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '🎟 Le mie prenotazioni (${upcoming.length})',
                style: GoogleFonts.abrilFatface(
                    fontSize: 26, fontWeight: FontWeight.w400, color: kPurple),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _buildList(upcoming, canEdit: true),

            // ── Archivio ──────────────────────────────────────────────────
            if (past.isNotEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showArchive = !_showArchive),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(
                      _showArchive ? Icons.expand_less : Icons.expand_more,
                      size: 18),
                  label: Text(
                    _showArchive
                        ? 'Nascondi archivio'
                        : '📂 Archivio (${past.length} ${past.length == 1 ? "prenotazione passata" : "prenotazioni passate"})',
                    style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
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
                    endIndent: 24),
                const SizedBox(height: 24),
                _buildList(past, canEdit: false),
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
        bg = Colors.black;
        fg = const Color(0xFFFDD835);
        label = '✔ Presente';
        break;
      case 'modificata':
        bg = const Color(0xFFFDD835);
        fg = Colors.black;
        label = 'Modificata';
        break;
      case 'cancellata':
        bg = const Color(0xFFCC4444);
        fg = Colors.white;
        label = 'Cancellata';
        break;
      default:
        bg = const Color(0xFF2E7D32);
        fg = Colors.white;
        label = 'Confermata';
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
