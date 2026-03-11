import 'table_model.dart';
import 'seat_model.dart';

class TableWithSeats {
  final TableModel table;
  final List<SeatModel> seats;

  TableWithSeats({
    required this.table,
    required this.seats,
  });
}