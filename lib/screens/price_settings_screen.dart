import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/price_settings_model.dart';
import '../services/price_settings_service.dart';
import '../theme/app_theme.dart';

class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({super.key});

  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  bool _loading = true;
  bool _saving = false;

  late final TextEditingController _fridayEntranceCtrl;
  late final TextEditingController _fridayDinnerCtrl;
  late final TextEditingController _saturdayEntranceCtrl;
  late final TextEditingController _saturdayDinnerCtrl;
  late final TextEditingController _otherEntranceCtrl;
  late final TextEditingController _otherDinnerCtrl;

  @override
  void initState() {
    super.initState();
    _fridayEntranceCtrl = TextEditingController();
    _fridayDinnerCtrl = TextEditingController();
    _saturdayEntranceCtrl = TextEditingController();
    _saturdayDinnerCtrl = TextEditingController();
    _otherEntranceCtrl = TextEditingController();
    _otherDinnerCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final prices = await PriceSettingsService.load();
    if (!mounted) return;
    setState(() {
      _fridayEntranceCtrl.text = prices.fridayEntrance;
      _fridayDinnerCtrl.text = prices.fridayDinner;
      _saturdayEntranceCtrl.text = prices.saturdayEntrance;
      _saturdayDinnerCtrl.text = prices.saturdayDinner;
      _otherEntranceCtrl.text = prices.otherEntrance;
      _otherDinnerCtrl.text = prices.otherDinner;
      _loading = false;
    });
  }

  String _priceWithEuro(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? s : '€. $digits';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = PriceSettings(
      fridayEntrance: _priceWithEuro(_fridayEntranceCtrl.text.trim()),
      fridayDinner: _priceWithEuro(_fridayDinnerCtrl.text.trim()),
      saturdayEntrance: _priceWithEuro(_saturdayEntranceCtrl.text.trim()),
      saturdayDinner: _priceWithEuro(_saturdayDinnerCtrl.text.trim()),
      otherEntrance: _priceWithEuro(_otherEntranceCtrl.text.trim()),
      otherDinner: _priceWithEuro(_otherDinnerCtrl.text.trim()),
    );
    try {
      await PriceSettingsService.save(settings);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Prezzi salvati! ✓'),
          backgroundColor: Color(0xFF1A3A1A),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $e'), backgroundColor: kError));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _fridayEntranceCtrl.dispose();
    _fridayDinnerCtrl.dispose();
    _saturdayEntranceCtrl.dispose();
    _saturdayDinnerCtrl.dispose();
    _otherEntranceCtrl.dispose();
    _otherDinnerCtrl.dispose();
    super.dispose();
  }

  Widget _field(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF558B2F)),
        filled: true,
        fillColor: const Color(0xFFE8F5E9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(text,
            style: GoogleFonts.abrilFatface(fontSize: 16, color: Colors.black)),
      );

  Widget _priceRow(
      TextEditingController entranceCtrl, TextEditingController dinnerCtrl) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Ingresso'),
          _field('€. 8', entranceCtrl),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Cena + Ingresso'),
          _field('€. 18', dinnerCtrl),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF4CAF50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E7D32))),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _loading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Colors.black),
                  ))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Impostazioni Prezzi',
                        style: GoogleFonts.abrilFatface(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            color: Colors.black)),
                    const Divider(color: Color(0xFF2E7D32)),
                    const SizedBox(height: 16),

                    _sectionTitle('Venerdì'),
                    _priceRow(_fridayEntranceCtrl, _fridayDinnerCtrl),
                    const SizedBox(height: 20),

                    _sectionTitle('Sabato'),
                    _priceRow(_saturdayEntranceCtrl, _saturdayDinnerCtrl),
                    const SizedBox(height: 20),

                    _sectionTitle('Altri giorni'),
                    _priceRow(_otherEntranceCtrl, _otherDinnerCtrl),
                    const SizedBox(height: 28),

                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFF2E7D32)),
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
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('Salva Prezzi',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      letterSpacing: 1)),
                        ),
                      ),
                    ]),
                  ],
                ),
        ),
      ),
    );
  }
}
