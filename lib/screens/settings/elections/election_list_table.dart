import 'package:application_ivote/models/elections_model.dart';
import 'package:flutter/material.dart';

class ElectionListTable extends StatelessWidget {
  final List<Elections> elections;
  final void Function(Elections election) onEdit;
  final void Function(String electionId) onDelete;

  const ElectionListTable({
    super.key,
    required this.elections,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Judul')),
          DataColumn(label: Text('Mulai')),
          DataColumn(label: Text('Selesai')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: List.generate(elections.length, (index) {
          final e = elections[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(e.judul)),
              DataCell(Text(_formatDate(e.startTime))),
              DataCell(Text(_formatDate(e.endTime))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    e.isActive ? 'Aktif' : 'Tidak Aktif',
                    style: TextStyle(
                      color: e.isActive ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(e),
                  ),
                  IconButton(
                    tooltip: 'Hapus',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(e.electionId),
                  ),
                ],
              )),
            ],
          );
        }),
      ),
    );
  }

  /// Format tanggal yyyy-mm-dd
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
}
