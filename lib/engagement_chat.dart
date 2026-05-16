import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EngagementChat extends StatefulWidget {
  const EngagementChat({super.key, required this.firestore});

  final FirebaseFirestore firestore;

  @override
  State<EngagementChat> createState() => _EngagementChatState();
}

class _EngagementChatState extends State<EngagementChat> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    widget.firestore.collection('chat').add(<String, dynamic>{
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // @AETHER: To mitigate catastrophic read costs, we strictly limit the snapshot
    // query to the 20 most recent messages and order by timestamp descending.
    // We avoid unbounded listeners that would download the entire chat history.
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: widget.firestore
                .collection('chat')
                .orderBy('timestamp', descending: true)
                .limit(20)
                .snapshots(),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Chat error'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                      snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> data = docs[index].data();
                      return ListTile(
                        title: Text(data['text'] as String? ?? ''),
                        subtitle: const Text('Player'),
                      );
                    },
                  );
                },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (String _) => _sendMessage(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }
}
