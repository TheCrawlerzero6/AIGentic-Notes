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
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            spacing: 2,
            children: [
              if (task.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                ),
              if ((task.description ?? "").isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withAlpha(120),
                    ),
                    Icon(
                      Icons.notifications,
                      size: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withAlpha(120),
                    ),
                    Icon(
                      Icons.loop,
                      size: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withAlpha(120),
                    ),
                  ].separatedBy(dot(context)),
                ),
            ],
          ),
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

Widget dot(BuildContext context) => Container(
  width: 4,
  height: 4,
  margin: const EdgeInsets.symmetric(horizontal: 3),
  decoration: BoxDecoration(
    color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(120),
    shape: BoxShape.circle,
  ),
);

extension SeparatedRow on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      if (i > 0) result.add(separator);
      result.add(this[i]);
    }
    return result;
  }
}
