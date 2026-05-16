import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'raid_service.dart';
import 'world_boss_timer.dart';

void main() {
  // Use FakeFirebaseFirestore for the local assessment build.
  final FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();

  // Initialize the RaidService with our fake firestore.
  final RaidService raidService = RaidService(firestore: fakeFirestore);

  // Initialize test data for the UI
  fakeFirestore.collection('events').doc('dragon_raid').set(<String, dynamic>{
    'slots_filled': 0,
    'max_slots': 15,
  });

  runApp(AetherApp(raidService: raidService));
}

class AetherApp extends StatelessWidget {
  const AetherApp({super.key, required this.raidService});

  final RaidService raidService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Aether',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: AetherDashboard(raidService: raidService),
    );
  }
}

class AetherDashboard extends StatelessWidget {
  const AetherDashboard({super.key, required this.raidService});

  final RaidService raidService;

  Future<void> _handleJoinRaid(BuildContext context) async {
    // Generate a pseudo-random user ID for the demo
    final String userId = 'user_\${DateTime.now().millisecondsSinceEpoch}';

    // Call the transaction-backed join method
    final bool success = await raidService.joinRaid(userId: userId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Successfully joined the raid!'
                : 'Raid is full or failed to join.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aether Command Center'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // The 100ms Global Pulse component
            const WorldBossTimer(),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _handleJoinRaid(context),
              icon: const Icon(Icons.flash_on),
              label: const Text('JOIN RAID'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
