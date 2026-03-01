import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event; // se presente → modalità modifica

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  bool _loading = false;
  bool _uploading = false;
  double _uploadProgress = 0.0;
  String _selectedColor = '#4A1A6B';
  String _selectedDay = 'Venerdì';
  DateTime? _selectedDate;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _djCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '21:30 – 01:00');
  final _dinnerTimeCtrl = TextEditingController(text: '19:30');
  final _dinnerPriceCtrl = TextEditingController(text: '€. 18');
  final _entrancePriceCtrl = TextEditingController(text: '€. 8');
  final _dinnerSeatsCtrl = TextEditingController(text: '150');
  final _totalSeatsCtrl = TextEditingController(text: '300');
  final _tagsCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  static const _days = [
    'Venerdì', 'Sabato', 'Domenica', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì'
  ];

  static const _weekdayNames = {
    1: 'Lunedì', 2: 'Martedì', 3: 'Mercoledì', 4: 'Giovedì',
    5: 'Venerdì', 6: 'Sabato', 7: 'Domenica',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _djCtrl.text = e.dj;
      _timeCtrl.text = e.time;
      _dinnerTimeCtrl.text = e.dinnerTime;
      _dinnerPriceCtrl.text = e.dinnerPrice;
      _entrancePriceCtrl.text = e.entrancePrice;
      _dinnerSeatsCtrl.text = e.dinnerSeats.toString();
      _totalSeatsCtrl.text = e.totalSeats.toString();
      _tagsCtrl.text = e.tags.join(', ');
      _imageUrlCtrl.text = e.imageUrl;
      _selectedColor = e.color;
      _selectedDay = e.day;
      _selectedDate = DateTime.tryParse(e.date);
    }
  }

  void _updatePricesForDay(String day) {
    if (day == 'Sabato') {
      _entrancePriceCtrl.text = '€. 10';
      _dinnerPriceCtrl.text = '€. 20';
    } else if (day == 'Venerdì') {
      _entrancePriceCtrl.text = '€. 8';
      _dinnerPriceCtrl.text = '€. 18';
    }
  }

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
    _imageUrlCtrl.dispose();
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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D2B6B),      // blu scuro — giorno selezionato
            onPrimary: Colors.white,          // testo sul giorno selezionato
            surface: Colors.white,            // sfondo calendario
            onSurface: Color(0xFF0D2B6B),    // testo giorni
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final dayName = _weekdayNames[picked.weekday] ?? _selectedDay;
      setState(() {
        _selectedDate = picked;
        _selectedDay = dayName;
      });
      _updatePricesForDay(dayName);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _priceWithEuro(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? s : '€. $digits';
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _selectedDate == null) return;
    setState(() => _loading = true);
    final isEdit = widget.event != null;
    final data = {
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
      'tags': _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'color': _selectedColor,
      'imageUrl': _imageUrlCtrl.text.trim(),
    };
    try {
      if (isEdit) {
        await EventService.updateEvent(widget.event!.id, data);
      } else {
        await EventService.addEvent({...data, 'dinnerBooked': 0, 'totalBooked': 0});
      }
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Evento aggiornato! ✓' : 'Evento pubblicato! ✨'),
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

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() { _uploading = true; _uploadProgress = 0.0; });
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance.ref('events/images/$fileName');
      final task = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/${file.extension?.toLowerCase() == 'jpg' ? 'jpeg' : (file.extension?.toLowerCase() ?? 'jpeg')}'),
      );
      task.snapshotEvents.listen((snap) {
        if (mounted && snap.totalBytes > 0) {
          setState(() => _uploadProgress = snap.bytesTransferred / snap.totalBytes);
        }
      });
      await task;
      final url = await ref.getDownloadURL();
      if (mounted) setState(() { _imageUrlCtrl.text = url; _uploading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore upload: $e'), backgroundColor: kError));
      }
    }
  }

  Widget _field(String hint, TextEditingController ctrl,
      {TextInputType? type, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF558B2F)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  @override
  Widget build(BuildContext context) {
    final previewUrl = _imageUrlCtrl.text.trim();

    return Dialog(
      backgroundColor: const Color(0xFF4CAF50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E7D32))),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.event != null ? 'Modifica Evento' : 'Pubblica Nuovo Evento',
                  style: GoogleFonts.abrilFatface(
                      fontSize: 26, fontWeight: FontWeight.w300, color: Colors.black)),
              const Divider(color: Color(0xFF2E7D32)),
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
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(color: const Color(0xFF2E7D32)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? _displayDate(_selectedDate!)
                              : 'Seleziona data',
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: _selectedDate != null
                                  ? Colors.black
                                  : const Color(0xFF558B2F)),
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
                      dropdownColor: const Color(0xFFE8F5E9),
                      style: GoogleFonts.montserrat(
                          fontSize: 13, color: Colors.black),
                      decoration: const InputDecoration(),
                      items: _days
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedDay = v ?? _selectedDay;
                        _updatePricesForDay(_selectedDay);
                      }),
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
                  children: [_label('Orario Serata'), _field('21:30 – 01:00', _timeCtrl)],
                )),
              ]),
              const SizedBox(height: 14),

              // Prezzi e posti
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Ingresso'), _field('€. 8', _entrancePriceCtrl)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Cena'), _field('€. 18', _dinnerPriceCtrl)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Posti Cena'),
                      _field('150', _dinnerSeatsCtrl, type: TextInputType.number)])),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Posti Tot.'),
                      _field('300', _totalSeatsCtrl, type: TextInputType.number)])),
              ]),
              const SizedBox(height: 14),

              // Tag
              _label('Tag (separati da virgola)'),
              _field('Tango, Live Music', _tagsCtrl),
              const SizedBox(height: 14),

              // Immagine
              _label('Immagine'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pulsante carica file
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickAndUploadImage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        backgroundColor: const Color(0xFFE8F5E9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _uploading
                          ? SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: _uploadProgress > 0 ? _uploadProgress : null,
                                color: Colors.black,
                              ))
                          : const Icon(Icons.upload_file, size: 18),
                      label: Text(
                        _uploading
                            ? 'Caricamento… ${(_uploadProgress * 100).toStringAsFixed(0)}%'
                            : 'Carica Immagine dal computer',
                        style: GoogleFonts.montserrat(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Campo URL manuale
                  TextField(
                    controller: _imageUrlCtrl,
                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'oppure incolla un URL…',
                      hintStyle: GoogleFonts.montserrat(
                          fontSize: 13, color: const Color(0xFF558B2F)),
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
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  // Anteprima
                  if (previewUrl.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        previewUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          height: 120,
                          color: const Color(0xFFE8F5E9),
                          alignment: Alignment.center,
                          child: Text('URL non valido',
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, color: kError)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
                        : Text(widget.event != null ? 'Salva Modifiche' : 'Pubblica Evento',
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
