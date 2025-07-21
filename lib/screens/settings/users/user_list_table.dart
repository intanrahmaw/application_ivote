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
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.deepPurple.shade50,
          ),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          columnSpacing: 38,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('No. HP')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Center(child: Text('Aksi'))),
          ],
          rows: List<DataRow>.generate(users.length, (index) {
            final user = users[index];
            final rowColor = index.isEven
                ? Colors.grey.withOpacity(0.05)
                : Colors.transparent;

            return DataRow(
              color: MaterialStateProperty.resolveWith((states) => rowColor),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.nama ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(user.noHp ?? '-')),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      user.email ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                        tooltip: 'Edit User',
                        splashRadius: 20,
                        onPressed: () => onEdit(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                        tooltip: 'Hapus User',
                        splashRadius: 20,
                        onPressed: () => onDelete(user.userId!),
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
}
