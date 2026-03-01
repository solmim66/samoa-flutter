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
import 'client_bookings_screen.dart';
import 'login_screen.dart';
import 'manager_bookings_screen.dart';

enum _Tab { events, bookings, myBookings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Tab _tab = _Tab.events;
  bool _showArchive = false;

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

  void _showEditEvent(EventModel event) {
    showDialog(
        context: context,
        builder: (_) => AddEventScreen(event: event));
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
            style: GoogleFonts.abrilFatface(
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Sfondo logo con sfumatura intensissima ──────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6FFFFFF), // bianco al 90% — logo visibile al 10%
                    Color(0xE6FFFFFF),
                    Color(0xE6FFFFFF),
                  ],
                ),
              ),
            ),
          ),
          // ── Contenuto ────────────────────────────────────────────────────────
          CustomScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Samoa Village',
                      style: GoogleFonts.abrilFatface(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 1)),
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
              ] else if (auth.isLoggedIn) ...[
                _NavBtn(
                    label: '🗓 Eventi',
                    active: _tab == _Tab.events,
                    onTap: () => setState(() => _tab = _Tab.events)),
                _NavBtn(
                    label: '🎟 Le mie prenotazioni',
                    active: _tab == _Tab.myBookings,
                    onTap: () => setState(() => _tab = _Tab.myBookings)),
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
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text(auth.isManager ? '🔑 Gestore' : '🎟 Cliente',
                            style: GoogleFonts.montserrat(
                                fontSize: 10, color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: AuthService.signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                      ),
                      child: Text('Esci',
                          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton(
                    onPressed: _showLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                    ),
                    child: Text('Accedi',
                        style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700)),
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
                            fontSize: 15,
                            color: kTextMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4)),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.abrilFatface(
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
                    Text('Tutti i Venerdì e Sabato sera e in occasione di festività',
                        style: GoogleFonts.abrilFatface(
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
                : _tab == _Tab.myBookings && auth.isLoggedIn && !auth.isManager
                    ? StreamBuilder<List<EventModel>>(
                        stream: EventService.eventsStream(),
                        builder: (context, snap) => ClientBookingsScreen(
                            user: auth.currentUser!,
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
                      final allEvents = snapshot.data ?? [];
                      final today = DateTime.now();
                      final todayDate = DateTime(today.year, today.month, today.day);
                      int byDate(EventModel a, EventModel b) {
                        final da = DateTime.tryParse(a.date);
                        final db = DateTime.tryParse(b.date);
                        if (da == null && db == null) return 0;
                        if (da == null) return 1;
                        if (db == null) return -1;
                        return da.compareTo(db);
                      }

                      final upcoming = allEvents.where((e) {
                        final d = DateTime.tryParse(e.date);
                        return d == null || !d.isBefore(todayDate);
                      }).toList()..sort(byDate);
                      final past = allEvents.where((e) {
                        final d = DateTime.tryParse(e.date);
                        return d != null && d.isBefore(todayDate);
                      }).toList()..sort(byDate);

                      Widget buildGrid(List<EventModel> events, {bool isPast = false}) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final cols = width < 600 ? 1 : width < 900 ? 2 : 3;

                            Widget cardFor(EventModel event) => EventCard(
                              event: event,
                              isManager: auth.isManager,
                              isPast: isPast,
                              onBook: () {
                                if (!auth.isLoggedIn) {
                                  _showLogin();
                                } else {
                                  _showBooking(event, auth.currentUser!);
                                }
                              },
                              onDelete: () => _confirmDelete(event),
                              onEdit: () => _showEditEvent(event),
                            );

                            final rows = <Widget>[];
                            for (int i = 0; i < events.length; i += cols) {
                              final rowEvents = events.skip(i).take(cols).toList();
                              final rowChildren = <Widget>[];
                              for (int j = 0; j < rowEvents.length; j++) {
                                if (j > 0) rowChildren.add(const SizedBox(width: 24));
                                rowChildren.add(Expanded(child: cardFor(rowEvents[j])));
                              }
                              for (int j = rowEvents.length; j < cols; j++) {
                                rowChildren.add(const SizedBox(width: 24));
                                rowChildren.add(const Expanded(child: SizedBox.shrink()));
                              }
                              if (rows.isNotEmpty) rows.add(const SizedBox(height: 24));
                              rows.add(Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: rowChildren,
                              ));
                            }
                            return Column(children: rows);
                          },
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (upcoming.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Text(
                                    auth.isManager
                                        ? 'Nessun evento. Crea il primo con "+ Nuovo Evento"!'
                                        : 'Nessun evento in programma al momento.',
                                    style: GoogleFonts.abrilFatface(
                                        fontSize: 24,
                                        fontStyle: FontStyle.italic,
                                        color: kTextMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              buildGrid(upcoming),

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
                                  icon: Icon(_showArchive ? Icons.expand_less : Icons.expand_more, size: 18),
                                  label: Text(
                                    _showArchive
                                        ? 'Nascondi archivio'
                                        : '📂 Archivio (${past.length} ${past.length == 1 ? "evento passato" : "eventi passati"})',
                                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ),
                              if (_showArchive) ...[
                                const SizedBox(height: 32),
                                Center(
                                  child: Text('EVENTI PASSATI',
                                      style: GoogleFonts.abrilFatface(
                                          fontSize: 28,
                                          color: const Color(0xFF1565C0),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 3)),
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: Color(0xFF1565C0), thickness: 2),
                                const SizedBox(height: 24),
                                buildGrid(past, isPast: true),
                              ],
                            ],
                          ],
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
                '© 2026 SAMOA VILLAGE — Tutti i diritti riservati',
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: const Color(0xFF3D2E4A), letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
          ),  // chiude CustomScrollView
        ],    // chiude Stack children
      ),      // chiude Stack (body)
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
          foregroundColor: Colors.white,
          backgroundColor:
              active ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
