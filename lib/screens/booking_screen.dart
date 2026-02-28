import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  final EventModel event;
  final UserModel user;

  const BookingScreen({super.key, required this.event, required this.user});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _option = 'entrance'; // 'entrance' | 'dinner'
  int _guests = 1;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        '', 'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
        'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  int get _unitPrice => _option == 'dinner'
      ? widget.event.dinnerPriceInt
      : widget.event.entrancePriceInt;

  int get _total => _unitPrice * _guests;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await EventService.confirmBooking(
        eventId: widget.event.id,
        bookingData: {
          'eventId': widget.event.id,
          'customerName': widget.user.name,
          'email': widget.user.email,
          'uid': widget.user.uid,
          'option': _option,
          'guests': _guests,
          'notes': _notesCtrl.text.trim(),
          'status': 'confirmed',
        },
        guests: _guests,
        isDinner: _option == 'dinner',
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '✓ Prenotazione confermata per "${widget.event.title}"!'),
          backgroundColor: const Color(0xFF1A3A1A),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $e'), backgroundColor: kError));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Dialog(
      backgroundColor: const Color(0xFF0E0A14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kCardBorder)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              const Divider(color: kCardBorder),
              Text('PRENOTAZIONE',
                  style: labelSmall(letterSpacing: 2)),
              const SizedBox(height: 6),
              Text(event.title,
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 28, fontWeight: FontWeight.w300, color: kText)),
              const SizedBox(height: 4),
              Text('${event.day} — ${_formatDate(event.date)}',
                  style: labelSmall()),
              const Divider(color: kCardBorder),
              const SizedBox(height: 16),

              // ── Utente ───────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                      fontSize: 13, color: const Color(0xFFB09878)),
                  children: [
                    const TextSpan(text: 'Prenotazione per: '),
                    TextSpan(
                      text: '${widget.user.name} (${widget.user.email})',
                      style: const TextStyle(
                          color: kText, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Selezione opzione ─────────────────────────────────────────
              Text('Scegli la tua opzione', style: labelSmall()),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _OptionCard(
                    icon: '🎟',
                    label: 'Solo Ingresso',
                    price: event.entrancePrice,
                    subtitle: '',
                    selected: _option == 'entrance',
                    disabled: false,
                    onTap: () => setState(() => _option = 'entrance'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _OptionCard(
                    icon: '🍽',
                    label: 'Cena + Ingresso',
                    price: event.dinnerSoldOut ? 'Esaurito' : event.dinnerPrice,
                    subtitle: event.dinnerSoldOut ? '' : 'Cena ore ${event.dinnerTime}',
                    selected: _option == 'dinner',
                    disabled: event.dinnerSoldOut,
                    onTap: () {
                      if (!event.dinnerSoldOut) {
                        setState(() => _option = 'dinner');
                      }
                    },
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // ── Numero persone ────────────────────────────────────────────
              Text('Numero di persone', style: labelSmall()),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CircleBtn(
                    icon: '−',
                    onTap: () => setState(
                        () => _guests = (_guests - 1).clamp(1, 10)),
                  ),
                  const SizedBox(width: 16),
                  Text('$_guests',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 28, color: kText)),
                  const SizedBox(width: 16),
                  _CircleBtn(
                    icon: '+',
                    onTap: () => setState(
                        () => _guests = (_guests + 1).clamp(1, 10)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Note ──────────────────────────────────────────────────────
              Text('Note speciali', style: labelSmall()),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: GoogleFonts.montserrat(fontSize: 13, color: kText),
                decoration: const InputDecoration(
                    hintText: 'Allergie, richieste speciali…'),
              ),
              const SizedBox(height: 20),

              // ── Totale ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1020),
                  border: Border.all(color: kCardBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Totale ($_guests ${_guests > 1 ? "persone" : "persona"})',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, color: kTextSecond),
                    ),
                    Text('€$_total',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: kGold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Pulsanti ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextSecond,
                        side: const BorderSide(color: kCardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Annulla',
                          style: GoogleFonts.montserrat(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Conferma Prenotazione',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String icon, label, price, subtitle;
  final bool selected, disabled;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? kPurple : kCardBorder,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
          color: selected ? kPurple.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: disabled
                        ? const Color(0xFF444444)
                        : selected
                            ? kPurple
                            : const Color(0xFFB09878)),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(price,
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: disabled ? const Color(0xFF555555) : kGold)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: GoogleFonts.montserrat(
                      fontSize: 10, color: kTextMuted)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kCardBorder),
        ),
        child: Center(
          child: Text(icon,
              style: const TextStyle(color: kPurple, fontSize: 20)),
        ),
      ),
    );
  }
}
