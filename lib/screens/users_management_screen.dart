import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  Stream<List<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  Future<void> _showForm(BuildContext context,
      {Map<String, dynamic>? user}) async {
    final nameCtrl =
        TextEditingController(text: user?['name'] ?? '');
    final emailCtrl =
        TextEditingController(text: user?['email'] ?? '');
    final phoneCtrl =
        TextEditingController(text: user?['phone'] ?? '');
    final formKey = GlobalKey<FormState>();
    final isNew = user == null;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kCardBorder)),
        title: Text(
          isNew ? 'Nuovo utente' : 'Modifica utente',
          style: GoogleFonts.abrilFatface(fontSize: 20, color: kText),
        ),
        content: SizedBox(
          width: 360,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Nome', Icons.person),
                const SizedBox(height: 12),
                _field(emailCtrl, 'Email', Icons.email,
                    keyboard: TextInputType.emailAddress,
                    readOnly: !isNew),
                const SizedBox(height: 12),
                _field(phoneCtrl, 'Telefono', Icons.phone,
                    keyboard: TextInputType.phone, required: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annulla',
                style: GoogleFonts.montserrat(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPurple),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              };
              final col =
                  FirebaseFirestore.instance.collection('users');
              if (isNew) {
                await col.add(data);
              } else {
                await col.doc(user!['id']).update(data);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isNew ? 'Aggiungi' : 'Salva',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kCardBorder)),
        title: Text('Elimina utente',
            style: GoogleFonts.abrilFatface(fontSize: 20, color: kText)),
        content: Text(
          'Eliminare "${user['name'] ?? user['email']}"?\nL\'account di accesso resterà attivo.',
          style: GoogleFonts.montserrat(fontSize: 14, color: kTextSecond),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annulla',
                style: GoogleFonts.montserrat(color: kTextMuted)),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFCC4444)),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Elimina',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user['id'])
          .delete();
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text,
      bool required = true,
      bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      readOnly: readOnly,
      style: GoogleFonts.montserrat(color: kText, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: kTextMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: kTextMuted, size: 18),
        filled: true,
        fillColor: const Color(0xFF1A1020),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kCardBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kCardBorder)),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Utenti registrati',
                    style: GoogleFonts.abrilFatface(
                        fontSize: 28, color: kText)),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.person_add,
                      color: Colors.white, size: 18),
                  label: Text('Aggiungi',
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  onPressed: () => _showForm(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: kCardBorder),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _usersStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: kPurple));
                  }
                  final users = snap.data ?? [];
                  if (users.isEmpty) {
                    return Center(
                      child: Text('Nessun utente registrato.',
                          style: GoogleFonts.montserrat(
                              color: kTextMuted, fontSize: 15)),
                    );
                  }
                  return LayoutBuilder(
                    builder: (ctx, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: kCardBorder, height: 1),
                        itemBuilder: (ctx, i) {
                          final u = users[i];
                          final name = (u['name'] ?? '').toString();
                          final email = (u['email'] ?? '').toString();
                          final phone = (u['phone'] ?? '').toString();
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            leading: CircleAvatar(
                              backgroundColor: kPurple.withOpacity(0.2),
                              child: Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : email.isNotEmpty
                                        ? email[0].toUpperCase()
                                        : '?',
                                style: GoogleFonts.montserrat(
                                    color: kPurple,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(
                              name.isNotEmpty ? name : email,
                              style: GoogleFonts.montserrat(
                                  color: kText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            subtitle: Text(
                              isWide
                                  ? '$email${phone.isNotEmpty ? '  ·  $phone' : ''}'
                                  : email,
                              style: GoogleFonts.montserrat(
                                  color: kTextMuted, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Modifica',
                                  icon: const Icon(Icons.edit_outlined,
                                      color: kTextSecond, size: 20),
                                  onPressed: () =>
                                      _showForm(context, user: u),
                                ),
                                IconButton(
                                  tooltip: 'Elimina',
                                  icon: const Icon(Icons.delete_outline,
                                      color: Color(0xFFCC4444), size: 20),
                                  onPressed: () =>
                                      _confirmDelete(context, u),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
