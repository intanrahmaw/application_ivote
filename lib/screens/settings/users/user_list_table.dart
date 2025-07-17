import 'package:flutter/material.dart';
import 'package:application_ivote/models/users_model.dart';

class UserListTable extends StatelessWidget {
  final List<Users> users;
  final Function(Users user) onEdit;
  final Function(String userId) onDelete;

  const UserListTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 24,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.deepPurple.shade100),
      border: TableBorder.all(color: Colors.grey.shade300),
      columns: const [
        DataColumn(label: Text('No')),
        DataColumn(label: Text('Nama')),
        DataColumn(label: Text('Ho Hp')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: List<DataRow>.generate(users.length, (index) {
        final user = users[index];
        return DataRow(
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(user.nama ?? '-')),
            DataCell(Text(user.noHp ?? '-')),
            DataCell(Text(user.email ?? '-')),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                  tooltip: 'Edit User',
                  onPressed: () => onEdit(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  tooltip: 'Hapus User',
                  onPressed: () => onDelete(user.userId!),
                ),
              ],
            )),
          ],
        );
      }),
    );
  }
}
