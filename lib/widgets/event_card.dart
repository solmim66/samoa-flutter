import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import 'availability_bar.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final bool isManager;
  final VoidCallback onBook;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.isManager,
    required this.onBook,
    required this.onDelete,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _hovered = false;

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

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final gradient = getEventGradient(event.color);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: kCard,
          border: Border.all(color: kCardBorder),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hovered
              ? [const BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 8))]
              : [],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (immagine o gradiente) ─────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: event.imageUrl.isEmpty
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      )
                    : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  if (event.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        event.imageUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradient,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (event.imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (event.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: event.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tag.toUpperCase(),
                            style: GoogleFonts.montserrat(
                                fontSize: 10, color: kText, letterSpacing: 1)),
                      )).toList(),
                    ),
                  if (event.tags.isNotEmpty) const SizedBox(height: 10),
                  Text('${event.day} — ${_formatDate(event.date)}',
                      style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: kText.withValues(alpha: 0.6),
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Text(event.title,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: kText,
                          height: 1.2)),
                  const SizedBox(height: 6),
                  Text('🎵 ${event.dj}  ·  🕘 ${event.time}',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, color: kText.withValues(alpha: 0.7))),
                ],
              ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrizione
                  Text(event.description,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFB09878),
                          height: 1.5)),
                  const SizedBox(height: 16),

                  // Barra disponibilità
                  AvailabilityBar(booked: event.totalBooked, total: event.totalSeats),
                  const SizedBox(height: 16),

                  // Box prezzi
                  Row(
                    children: [
                      Expanded(child: _PriceBox(
                        label: 'Solo Ingresso',
                        price: event.entrancePrice,
                        soldOut: false,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _PriceBox(
                        label: 'Cena  (${event.dinnerSeats - event.dinnerBooked} posti)',
                        price: event.dinnerSoldOut ? 'Esaurito' : event.dinnerPrice,
                        soldOut: event.dinnerSoldOut,
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pulsante
                  if (!widget.isManager)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: event.soldOut ? null : widget.onBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: event.soldOut ? kCardBorder : null,
                          foregroundColor: event.soldOut ? const Color(0xFF555555) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          event.soldOut ? 'Evento Esaurito' : 'Prenota Ora',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 1),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFCC4444),
                          side: const BorderSide(color: Color(0xFF4A1A1A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('🗑 Elimina Evento',
                            style: GoogleFonts.montserrat(fontSize: 13)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String price;
  final bool soldOut;

  const _PriceBox(
      {required this.label, required this.price, required this.soldOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1020),
        border: Border.all(color: kCardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: kTextMuted,
                  letterSpacing: 1),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(price,
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: soldOut ? const Color(0xFF555555) : kGold)),
        ],
      ),
    );
  }
}
