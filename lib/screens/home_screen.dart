import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import 'add_event_screen.dart';
import 'booking_screen.dart';
import 'login_screen.dart';
import 'manager_bookings_screen.dart';

enum _Tab { events, bookings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Tab _tab = _Tab.events;

  void _showLogin() {
    showDialog(
        context: context,
        builder: (_) => const LoginScreen());
  }

  void _showBooking(EventModel event, UserModel user) {
    showDialog(
        context: context,
        builder: (_) => BookingScreen(event: event, user: user));
  }

  void _showAddEvent() {
    showDialog(
        context: context,
        builder: (_) => const AddEventScreen());
  }

  Future<void> _confirmDelete(EventModel event) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kCardBorder)),
        title: Text('Elimina evento',
            style: GoogleFonts.cormorantGaramond(
                fontSize: 22, color: kText)),
        content: Text('Eliminare "${event.title}"?',
            style: GoogleFonts.montserrat(fontSize: 14, color: kTextSecond)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCC4444)),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await EventService.deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento eliminato.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xF00D0A14),
            elevation: 0,
            titleSpacing: 24,
            title: GestureDetector(
              onTap: () => setState(() => _tab = _Tab.events),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Sala Danza',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: kPurple,
                          letterSpacing: 2)),
                  const SizedBox(width: 10),
                  Text('& Spettacoli',
                      style: GoogleFonts.montserrat(
                          fontSize: 10, color: kTextMuted, letterSpacing: 3)),
                ],
              ),
            ),
            actions: [
              if (auth.isManager) ...[
                _NavBtn(
                    label: '🗓 Eventi',
                    active: _tab == _Tab.events,
                    onTap: () => setState(() => _tab = _Tab.events)),
                _NavBtn(
                    label: '📋 Prenotazioni',
                    active: _tab == _Tab.bookings,
                    onTap: () => setState(() => _tab = _Tab.bookings)),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: _showAddEvent,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9)),
                    child: Text('+ Nuovo Evento',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ),
              ],
              if (auth.isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(auth.currentUser!.name,
                            style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: kText,
                                fontWeight: FontWeight.w500)),
                        Text(auth.isManager ? '🔑 Gestore' : '🎟 Cliente',
                            style: GoogleFonts.montserrat(
                                fontSize: 10, color: kTextMuted)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: AuthService.signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextSecond,
                        side: const BorderSide(color: kCardBorder),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                      ),
                      child: Text('Esci',
                          style: GoogleFonts.montserrat(fontSize: 11)),
                    ),
                  ]),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton(
                    onPressed: _showLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPurple,
                      side: const BorderSide(color: kPurpleDark),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                    ),
                    child: Text('Accedi',
                        style: GoogleFonts.montserrat(fontSize: 13)),
                  ),
                ),
            ],
          ),

          // ── Hero ──────────────────────────────────────────────────────────
          if (_tab == _Tab.events)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1E1030))),
                ),
                child: Column(
                  children: [
                    Text('Prenota il tuo posto',
                        style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: kTextMuted,
                            letterSpacing: 4)),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 48, fontWeight: FontWeight.w300, color: kText),
                        children: [
                          const TextSpan(text: 'Serate ed '),
                          TextSpan(
                              text: 'Eventi',
                              style: const TextStyle(color: kPurple, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Venerdì e sabato sera, con eventi speciali nelle festività',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: kTextSecond)),
                  ],
                ),
              ),
            ),

          // ── Contenuto principale ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _tab == _Tab.bookings && auth.isManager
                ? StreamBuilder<List<EventModel>>(
                    stream: EventService.eventsStream(),
                    builder: (context, snap) => ManagerBookingsScreen(
                        events: snap.data ?? []),
                  )
                : StreamBuilder<List<EventModel>>(
                    stream: EventService.eventsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(color: kPurple),
                        ));
                      }
                      final events = snapshot.data ?? [];
                      if (events.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Text(
                              auth.isManager
                                  ? 'Nessun evento. Crea il primo con "+ Nuovo Evento"!'
                                  : 'Nessun evento in programma al momento.',
                              style: GoogleFonts.cormorantGaramond(
                                  fontSize: 24,
                                  fontStyle: FontStyle.italic,
                                  color: kTextMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final cols = width < 600
                                ? 1
                                : width < 900
                                    ? 2
                                    : 3;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: events.length,
                              itemBuilder: (context, i) {
                                final event = events[i];
                                return EventCard(
                                  event: event,
                                  isManager: auth.isManager,
                                  onBook: () {
                                    if (!auth.isLoggedIn) {
                                      _showLogin();
                                    } else {
                                      _showBooking(event, auth.currentUser!);
                                    }
                                  },
                                  onDelete: () => _confirmDelete(event),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF1E1030)))),
              child: Text(
                '© 2026 SALA DANZA & SPETTACOLI — Tutti i diritti riservati',
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: const Color(0xFF3D2E4A), letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active ? kPurple : kTextSecond,
          backgroundColor:
              active ? kPurple.withValues(alpha: 0.15) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, style: GoogleFonts.montserrat(fontSize: 12)),
      ),
    );
  }
}
