import 'package:flutter/material.dart';
import 'package:application_ivote/models/usermodels.dart';

class UserListTable extends StatelessWidget {
  final List<AppUser> users;
  final Function(AppUser user) onEdit;
  final Function(String userId) onDelete;

  const UserListTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // agar tabel bisa digeser jika kepanjangan
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('No HP')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: List.generate(users.length, (index) {
          final user = users[index];
          return DataRow(cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(user.nama)),
            DataCell(Text(user.email)),
            DataCell(Text(user.noHp)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => onEdit(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(user.userId),
                ),
              ],
            )),
          ]);
        }),
      ),
    );
  }
}
