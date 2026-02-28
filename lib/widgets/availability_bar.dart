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

    final Color barColor = soldOut
        ? kError
        : pct > 0.8
            ? kWarning
            : kPurpleDark;

    final String label = soldOut
        ? 'ESAURITO'
        : '$available rimasti';

    final Color labelColor = soldOut
        ? kError
        : pct > 0.8
            ? kWarning
            : kSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('DISPONIBILITÀ',
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: kTextMuted, letterSpacing: 1)),
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
