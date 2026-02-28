import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  static final _col = FirebaseFirestore.instance.collection('bookings');

  static Stream<List<BookingModel>> bookingsStream() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
