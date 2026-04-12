---
title: Stream Events via PutEvents in Real Time
impact: CRITICAL
impactDescription: 1-2 second recommendation adaptation
tags: track, putevents, real-time
---

## Stream Events via PutEvents in Real Time

Batching events to an end-of-day S3 bulk import means the model never sees a session as it unfolds — a seeker who just viewed and rejected five similar listings still gets the same five recommended. Streaming via the PutEvents API lets Personalize adapt recommendations within 1-2 seconds for recipes that support real-time updates, which is the difference between "the system learned from me" and "the system is broken". Bulk imports still have a place for historical backfill; they are not a replacement for live streaming.

**Incorrect (end-of-day S3 export, no in-session adaptation):**

```python
def append_event_to_daily_file(event: dict) -> None:
    with open(f"/tmp/events-{date.today()}.jsonl", "a") as f:
        f.write(json.dumps(event) + "\n")

# A nightly cron uploads the file to S3 and triggers CreateDatasetImportJob.
# Recommendations for today's sessions are based on yesterday's data.
```

**Correct (PutEvents stream, recommendations adapt within seconds):**

```python
personalize_events = boto3.client("personalize-events")

def emit_event(seeker_id: str, listing_id: str, event_type: str, request_id: str) -> None:
    personalize_events.put_events(
        trackingId=TRACKING_ID,
        userId=seeker_id,
        sessionId=f"session-{seeker_id}",
        eventList=[{
            "eventId": str(uuid4()),
            "sentAt": datetime.utcnow(),
            "eventType": event_type,
            "itemId": listing_id,
            "properties": json.dumps({"requestId": request_id}),
        }],
    )
```

Reference: [AWS Personalize — Recording Real-Time Events](https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html)
