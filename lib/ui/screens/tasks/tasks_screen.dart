import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks & Chores')),
      body: ListView(
        padding: EdgeInsets.all(context.spaces.md),
        children: const [
          ListTile(leading: Icon(Icons.lightbulb), title: Text('Proactive suggestions appear here')),
          Divider(),
          ListTile(leading: Icon(Icons.check_box_outline_blank), title: Text('Example Task')), 
          ListTile(leading: Icon(Icons.cleaning_services_outlined), title: Text('Example Chore')), 
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_task),
      ),
    );
  }
}


