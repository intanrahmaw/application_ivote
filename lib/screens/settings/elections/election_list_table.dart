import 'package:application_ivote/models/elections_model.dart';
import 'package:flutter/material.dart';

class ElectionListTable extends StatelessWidget {
  final List<Elections> elections;
  final void Function(Elections election) onEdit;

  const ElectionListTable({
    super.key,
    required this.elections,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateColor.resolveWith((states) => Colors.deepPurple.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
          columnSpacing: 30,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Judul')),
            DataColumn(label: Text('Deskripsi')),
            DataColumn(label: Text('Mulai')),
            DataColumn(label: Text('Selesai')),
            DataColumn(label: Center(child: Text('Status'))),
            DataColumn(label: Center(child: Text('Aksi'))),
          ],
          rows: List.generate(elections.length, (index) {
            final e = elections[index];
            final rowColor = index.isEven
                ? Colors.transparent
                : Colors.grey.withOpacity(0.05);

            return DataRow(
              color: WidgetStateProperty.resolveWith((states) => rowColor),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(e.judul, overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(e.deskripsi ?? '-', overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(Text(_formatDate(e.startTime))),
                DataCell(Text(_formatDate(e.endTime))),
                DataCell(
                  Center(
                    child: Chip(
                      label: Text(e.isActive ? 'Aktif' : 'Selesai'),
                      backgroundColor: e.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: e.isActive
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                        onPressed: () => onEdit(e),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
