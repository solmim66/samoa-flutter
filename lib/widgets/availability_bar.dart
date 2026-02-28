import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AvailabilityBar extends StatelessWidget {
  final int booked;
  final int total;

  const AvailabilityBar({super.key, required this.booked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? booked / total : 0.0;
    final available = total - booked;
    final soldOut = booked >= total;

    const Color green = Color(0xFF2E7D32);   // verde intenso 100%
    const Color blue  = Color(0xFF1565C0);   // blu intenso 100%

    final Color barColor = soldOut ? kError : blue;

    final String label = soldOut ? 'ESAURITO' : '$available rimasti';

    final Color labelColor = soldOut ? kError : green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('DISPONIBILITÀ',
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: blue, letterSpacing: 1,
                    fontWeight: FontWeight.w600)),
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: labelColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            backgroundColor: kCardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
