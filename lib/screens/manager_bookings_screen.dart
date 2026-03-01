import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'booking_screen.dart';

class ManagerBookingsScreen extends StatefulWidget {
  final List<EventModel> events;

  const ManagerBookingsScreen({super.key, required this.events});

  @override
  State<ManagerBookingsScreen> createState() => _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState extends State<ManagerBookingsScreen> {
  bool _showArchive = false;

  static const _italianDays = [
    'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica'
  ];
  static const _italianMonths = [
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
  ];

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

  String _formatDateFull(DateTime d) {
    return '${_italianDays[d.weekday - 1]} ${d.day} ${_italianMonths[d.month - 1]} ${d.year}';
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

  void _editBooking(BuildContext ctx, BookingModel b, EventModel ev) {
    final clientUser = UserModel(
      uid: b.uid,
      email: b.email,
      name: b.customerName,
      role: 'customer',
    );
    showDialog(
      context: ctx,
      builder: (_) => BookingScreen(
        event: ev,
        user: clientUser,
        existingBooking: b,
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext ctx, BookingModel b) async {
    final ev = _getEvent(b.eventId);
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
            'Cancellare la prenotazione di "${b.customerName}" per "${ev?.title ?? "questo evento"}"?',
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
      await BookingService.cancelBooking(b);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Prenotazione cancellata.')));
      }
    }
  }

  Widget _buildCard(BookingModel b, EventModel? ev) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
                      style: GoogleFonts.montserrat(
                          fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    '${b.isDinner ? "🍽 Cena + Ingresso" : "🎟 Solo Ingresso"} — ${b.guests} ${b.guests > 1 ? "persone" : "persona"}',
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
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
                  if (b.status != 'cancellata') ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (b.status != 'presente') ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => BookingService.confirmArrival(b.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Conferma\nArrivo',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: ev != null
                                ? () => _editBooking(context, b, ev)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDD835),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Modifica',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _cancelBooking(context, b),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancella',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
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
                    style: GoogleFonts.montserrat(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(List<BookingModel> bookings) {
    // Raggruppa per eventId
    final Map<String, List<BookingModel>> grouped = {};
    for (final b in bookings) {
      grouped.putIfAbsent(b.eventId, () => []).add(b);
    }

    // Ordina i gruppi per data evento
    final sortedEventIds = grouped.keys.toList()
      ..sort((a, b) {
        final evA = _getEvent(a);
        final evB = _getEvent(b);
        final dateA = evA != null ? (DateTime.tryParse(evA.date) ?? DateTime(0)) : DateTime(0);
        final dateB = evB != null ? (DateTime.tryParse(evB.date) ?? DateTime(0)) : DateTime(0);
        return dateA.compareTo(dateB);
      });

    final widgets = <Widget>[];

    for (final eventId in sortedEventIds) {
      final ev = _getEvent(eventId);
      final eventBookings = grouped[eventId]!;

      // Separa cene e ingressi, ordinate alfabeticamente per nominativo
      final dinners = eventBookings.where((b) => b.isDinner).toList()
        ..sort((a, b) => a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));
      final entrances = eventBookings.where((b) => !b.isDinner).toList()
        ..sort((a, b) => a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));

      // Intestazione: giorno della settimana + data + titolo evento
      final eventDate = ev != null ? DateTime.tryParse(ev.date) : null;
      final dateLabel = eventDate != null ? _formatDateFull(eventDate) : 'Data sconosciuta';

      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel,
                style: GoogleFonts.abrilFatface(fontSize: 19, color: Colors.black)),
            if (ev != null)
              Text(ev.title,
                  style: GoogleFonts.montserrat(
                      fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
      ));

      // ── Cene ──────────────────────────────────────────────────────────────
      if (dinners.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
          child: Text('🍽 CENE — ${dinners.where((b) => b.status != "cancellata").length} ${dinners.where((b) => b.status != "cancellata").length == 1 ? "prenotazione" : "prenotazioni"} · ${dinners.where((b) => b.status != "cancellata").fold(0, (s, b) => s + b.guests)} persone',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
        ));
        for (final b in dinners) {
          widgets.add(_buildCard(b, ev));
          widgets.add(const SizedBox(height: 12));
        }
      }

      // ── Separatore cene / ingressi ─────────────────────────────────────────
      if (dinners.isNotEmpty && entrances.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Divider(color: Colors.black26, thickness: 1),
        ));
      }

      // ── Ingressi ──────────────────────────────────────────────────────────
      if (entrances.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
          child: Text('🎟 INGRESSI — ${entrances.where((b) => b.status != "cancellata").length} ${entrances.where((b) => b.status != "cancellata").length == 1 ? "prenotazione" : "prenotazioni"} · ${entrances.where((b) => b.status != "cancellata").fold(0, (s, b) => s + b.guests)} persone',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
        ));
        for (final b in entrances) {
          widgets.add(_buildCard(b, ev));
          widgets.add(const SizedBox(height: 12));
        }
      }
    }

    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService.bookingsStream(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];

        final upcoming = all.where((b) => !_isEventPast(b.eventId)).toList();
        final past = all.where((b) => _isEventPast(b.eventId)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Prenotazioni Ricevute',
                style: GoogleFonts.abrilFatface(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
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
                        color: Colors.black54),
                  ),
                ),
              )
            else
              _buildGroupedList(upcoming),

            // ── Archivio prenotazioni passate ──────────────────────────────────
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
                        fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              if (_showArchive) ...[
                const SizedBox(height: 32),
                Center(
                  child: Text('Prenotazioni passate',
                      style: GoogleFonts.abrilFatface(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Colors.black26,
                  thickness: 2,
                  indent: 24,
                  endIndent: 24,
                ),
                const SizedBox(height: 24),
                _buildGroupedList(past),
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
