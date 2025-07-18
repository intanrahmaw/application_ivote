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
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Penting agar DataTable mengikuti bentuk Card
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          // 2. Styling yang ditingkatkan
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
            DataColumn(label: Text('Mulai')),
            DataColumn(label: Text('Selesai')),
            DataColumn(label: Center(child: Text('Status'))),
            DataColumn(label: Center(child: Text('Aksi'))),
          ],
          rows: List.generate(elections.length, (index) {
            final e = elections[index];
            // 3. Tambahkan warna selang-seling untuk keterbacaan (Zebra Stripes)
            final rowColor = index.isEven
                ? Colors.transparent
                : Colors.grey.withOpacity(0.05);

            return DataRow(
              color: WidgetStateProperty.resolveWith((states) => rowColor),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250), // Batasi lebar judul
                    child: Text(e.judul, overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(Text(_formatDate(e.startTime))),
                DataCell(Text(_formatDate(e.endTime))),
                DataCell(
                  Center(
                    child: Chip(
                      label: Text(e.isActive ? 'Aktif' : 'Tidak Aktif'),
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
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                        onPressed: () => onDelete(e.electionId),
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

  /// Format tanggal yyyy-MM-dd
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}