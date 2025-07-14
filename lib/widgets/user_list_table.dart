import 'package:flutter/material.dart';
import '../models/usermodels.dart';

class UserListTable extends StatelessWidget {
  final List<AppUser> users;
  final void Function(AppUser user) onEdit;
  final void Function(String userId) onDelete;

  const UserListTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // bisa di-scroll kalau overflow
      child: DataTable(
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('No HP')),
          DataColumn(label: Text('Username')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: List.generate(users.length, (index) {
          final user = users[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(user.nama)),
              DataCell(Text(user.email)),
              DataCell(Text(user.noHp)),
              DataCell(Text(user.username)),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(user.userId),
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
