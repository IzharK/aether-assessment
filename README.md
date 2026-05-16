# Project Aether

## Firebase Read-Cost Mitigation Strategy
To prevent a catastrophic Firebase billing spike when 10,000 players chat simultaneously, we must never bind unbounded `collection(...).snapshots()` listeners to the client. Instead, we execute a single `get()` to fetch the initial batch of messages and only subscribe to a strongly bounded listener (e.g., `limit(20)`) for new messages appended after the connection timestamp. For true hyper-scale, we would abandon direct collection stream listeners entirely and instead maintain a single, server-aggregated "latest_messages" document that 10,000 clients can listen to, collapsing 10,000 query evaluations into a single predictable document read per update.
