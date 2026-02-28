import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  bool _loading = false;
  String _selectedColor = '#4A1A6B';
  String _selectedDay = 'Venerdì';
  DateTime? _selectedDate;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _djCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '21:00 – 02:00');
  final _dinnerTimeCtrl = TextEditingController(text: '20:00');
  final _dinnerPriceCtrl = TextEditingController(text: '€45');
  final _entrancePriceCtrl = TextEditingController(text: '€18');
  final _dinnerSeatsCtrl = TextEditingController(text: '40');
  final _totalSeatsCtrl = TextEditingController(text: '200');
  final _tagsCtrl = TextEditingController();

  static const _days = [
    'Venerdì', 'Sabato', 'Domenica', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì'
  ];

  static const _colors = [
    '#8B1A1A', '#1A3A5C', '#3D6B3D', '#7A3B00', '#4A1A6B', '#1A4A4A',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _djCtrl.dispose();
    _timeCtrl.dispose();
    _dinnerTimeCtrl.dispose();
    _dinnerPriceCtrl.dispose();
    _entrancePriceCtrl.dispose();
    _dinnerSeatsCtrl.dispose();
    _totalSeatsCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: kPurple, surface: kCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _priceWithEuro(String s) =>
      s.startsWith('€') ? s : '€$s';

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _selectedDate == null) return;
    setState(() => _loading = true);
    try {
      await EventService.addEvent({
        'title': _titleCtrl.text.trim(),
        'date': _formatDate(_selectedDate!),
        'day': _selectedDay,
        'description': _descCtrl.text.trim(),
        'dj': _djCtrl.text.trim(),
        'time': _timeCtrl.text.trim(),
        'dinnerTime': _dinnerTimeCtrl.text.trim(),
        'dinnerPrice': _priceWithEuro(_dinnerPriceCtrl.text.trim()),
        'entrancePrice': _priceWithEuro(_entrancePriceCtrl.text.trim()),
        'dinnerSeats': int.tryParse(_dinnerSeatsCtrl.text) ?? 40,
        'totalSeats': int.tryParse(_totalSeatsCtrl.text) ?? 200,
        'dinnerBooked': 0,
        'totalBooked': 0,
        'tags': _tagsCtrl.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'color': _selectedColor,
      });
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Evento pubblicato! ✨'),
          backgroundColor: Color(0xFF1A3A1A),
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

  Widget _field(String hint, TextEditingController ctrl,
      {TextInputType? type, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(fontSize: 13, color: kText),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: labelSmall()),
      );

  @override
  Widget build(BuildContext context) {
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
              Text('Pubblica Nuovo Evento',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 26, fontWeight: FontWeight.w300, color: kText)),
              const Divider(color: kCardBorder),
              const SizedBox(height: 16),

              // Titolo
              _label('Titolo Evento *'),
              _field('es. Notte di Tango', _titleCtrl),
              const SizedBox(height: 14),

              // Data + Giorno
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Data *'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1020),
                          border: Border.all(color: kCardBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Seleziona data',
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: _selectedDate != null
                                  ? kText
                                  : const Color(0xFF3D2E4A)),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Giorno'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDay,
                      dropdownColor: kCard,
                      style: GoogleFonts.montserrat(
                          fontSize: 13, color: kText),
                      decoration: const InputDecoration(),
                      items: _days
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedDay = v ?? _selectedDay),
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 14),

              // Descrizione
              _label('Descrizione'),
              _field('Descrizione della serata...', _descCtrl, maxLines: 3),
              const SizedBox(height: 14),

              // DJ + Orario
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('Artista / DJ'), _field('Nome artista', _djCtrl)],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('Orario Serata'), _field('21:00 – 02:00', _timeCtrl)],
                )),
              ]),
              const SizedBox(height: 14),

              // Prezzi e posti
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Ingresso'), _field('€18', _entrancePriceCtrl)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Cena'), _field('€45', _dinnerPriceCtrl)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Posti Cena'),
                      _field('40', _dinnerSeatsCtrl, type: TextInputType.number)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Posti Tot.'),
                      _field('200', _totalSeatsCtrl, type: TextInputType.number)])),
              ]),
              const SizedBox(height: 14),

              // Tag
              _label('Tag (separati da virgola)'),
              _field('Tango, Live Music', _tagsCtrl),
              const SizedBox(height: 14),

              // Colore tema
              _label('Colore Tema'),
              Row(
                children: _colors.map((c) {
                  final color = Color(int.parse('0xFF${c.substring(1)}'));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == c
                              ? kPurple
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Pulsanti
              Row(children: [
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
                    onPressed: _loading ? null : _submit,
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
                        : Text('Pubblica Evento',
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
