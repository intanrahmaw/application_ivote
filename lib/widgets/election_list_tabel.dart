import 'package:application_ivote/models/elecction_model.dart';
import 'package:flutter/material.dart';

class ElectionListTable extends StatelessWidget {
  final List<Election> elections;
  final void Function(Election election) onEdit;
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
      scrollDirection: Axis.horizontal, // scroll kalau data banyak
      child: DataTable(
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Judul')),
          DataColumn(label: Text('Deskripsi')),
          DataColumn(label: Text('Mulai')),
          DataColumn(label: Text('Selesai')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: List.generate(elections.length, (index) {
          final e = elections[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(e.judul)),
              DataCell(Text(e.deskripsi)),
              DataCell(Text(e.startTime.toString().split(' ')[0])), // format yyyy-mm-dd
              DataCell(Text(e.endTime.toString().split(' ')[0])),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(e),
                  ),
                  IconButton(
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
}
