import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/task.dart';
import 'radio_checkbox.dart';

class TaskItemTile extends StatelessWidget {
  final Task task;

  final VoidCallback onToggle;
  const TaskItemTile({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.grey.withAlpha(100),
        borderRadius: BorderRadius.circular(2),
        child: ListTile(
          leading: RadioCheckbox(
            value: task.isCompleted,
            color: Theme.of(context).textTheme.bodyLarge!.color!,
            borderColor: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withAlpha(160),
            onTap: onToggle,
          ),
          minTileHeight: 64,
          title: Text(task.title),
          subtitle: task.dueDate != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 2,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 12),
                    Text(
                      DateFormat("EEE, d 'de' MMM", 'es').format(task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.access_time_filled, size: 12),
                    Text(
                      DateFormat('HH:mm').format(task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : null,
          // trailing: IconButton(
          //   onPressed: () => {},
          //   icon: Icon(Icons.favorite_outline),
          // ),
          onTap: () {
            context.push("/tasks/${task.id}");
          },
        ),
      ),
    );
  }
}
