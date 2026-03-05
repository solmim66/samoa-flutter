import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegister = false;
  bool _loading = false;
  String? _errorMessage;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _notify(String msg) {
    if (!mounted) return;
    setState(() => _errorMessage = msg);
  }

  Future<void> _handleGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _notify(AuthService.localizeError(e.code));
    } catch (e) {
      _notify('Errore login Google.');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleForgotPassword() async {
    final emailCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0E0A14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kCardBorder)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password dimenticata',
                  style: GoogleFonts.abrilFatface(
                      fontSize: 22, color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                'Inserisci la tua email. Ti invieremo un link per reimpostare la password.',
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.montserrat(
                    fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(hintText: 'La tua email'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text('Annulla',
                        style: GoogleFonts.montserrat(
                            color: Colors.white54, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(emailCtrl.text.trim()),
                    child: Text('Invia',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result.isEmpty) return;
    try {
      await AuthService.sendPasswordReset(result);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0E0A14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: kCardBorder)),
          title: Text('Email inviata',
              style: GoogleFonts.abrilFatface(color: Colors.white, fontSize: 20)),
          content: Text(
            'Se l\'indirizzo è registrato riceverai un\'email con il link per reimpostare la password.',
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      _notify(AuthService.localizeError(e.code));
    } catch (_) {
      _notify('Errore nell\'invio dell\'email.');
    }
  }

  Future<void> _handleSubmit() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    if (_isRegister) {
      final phone = _phoneCtrl.text.trim();
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (phone.isEmpty || digits.length < 9) {
        _notify('Inserisci un numero di cellulare valido.');
        return;
      }
      setState(() => _loading = true);
      final phoneExists = await AuthService.isPhoneAlreadyRegistered(phone);
      if (phoneExists) {
        if (mounted) setState(() => _loading = false);
        _notify('Numero di cellulare già registrato.');
        return;
      }
    } else {
      setState(() => _loading = true);
    }
    try {
      if (_isRegister) {
        await AuthService.registerWithEmail(
            _emailCtrl.text.trim(), _passwordCtrl.text,
            _nameCtrl.text.trim(), _phoneCtrl.text.trim());
        EmailService.sendWelcome(
          toName:  _nameCtrl.text.trim(),
          toEmail: _emailCtrl.text.trim(),
        ).catchError((_) {});
      } else {
        await AuthService.signInWithEmail(
            _emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _notify(AuthService.localizeError(e.code));
    } catch (e) {
      _notify('Errore di autenticazione.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.montserrat(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w700);

    return Dialog(
      backgroundColor: const Color(0xFF0E0A14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kCardBorder)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💃', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(_isRegister ? 'Registrati' : 'Bentornato',
                  style: GoogleFonts.abrilFatface(
                      fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                _isRegister
                    ? 'Crea il tuo account gratuito'
                    : 'Accedi per prenotare i tuoi eventi preferiti',
                style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // ── Google button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _handleGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    backgroundColor: const Color(0xFF1A1020),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const _GoogleIcon(),
                  label: Text('Accedi con Google',
                      style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Separatore ───────────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider(color: kCardBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('oppure',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const Expanded(child: Divider(color: kCardBorder)),
              ]),
              const SizedBox(height: 16),

              // ── Campi form ───────────────────────────────────────────────
              if (_isRegister) ...[
                TextField(
                  controller: _nameCtrl,
                  style: inputStyle,
                  decoration:
                      const InputDecoration(hintText: 'Nome e Cognome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  style: inputStyle,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Numero di cellulare *',
                    prefixText: '+39 ',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                style: inputStyle,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'La tua email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                style: inputStyle,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
                onSubmitted: (_) => _handleSubmit(),
              ),
              if (!_isRegister) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Password dimenticata?',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.white60,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // ── Messaggio di errore inline ────────────────────────────────
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C1010),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kError),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Pulsante submit ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSubmit,
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
                      : Text(
                          _isRegister ? 'Crea Account' : 'Accedi',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 1),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Toggle login/registrazione ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() { _isRegister = !_isRegister; _errorMessage = null; }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _isRegister ? 'Hai già un account? Accedi' : 'Non hai un account? Registrati',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2;
    paint.color = const Color(0xFF4285F4);
    canvas.drawCircle(Offset(r, r), r, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(r, r), r * 0.6, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(r, r * 0.4, r * 0.9, r * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
