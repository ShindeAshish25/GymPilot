import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text('Gym Name'),
            subtitle: Text('Power Fitness Gym'),
            trailing: Icon(Icons.edit),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.image),
            title: Text('Gym Logo'),
            subtitle: Text('gym_logo.png'),
            trailing: Icon(Icons.upload),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Address'),
            subtitle: Text('Pune, India'),
            trailing: Icon(Icons.edit),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notification Settings'),
            subtitle: const Text('Receive alerts for overdue payments'),
            value: true,
            onChanged: (bool value) {},
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.subscriptions),
            title: Text('Subscription Plan'),
            subtitle: Text('PRO (Expires: 31 Dec 2026)'),
            trailing: Chip(
              label: Text('Upgrade', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {},
            child: const Text('Log Out'),
          )
        ],
      ),
    );
  }
}
