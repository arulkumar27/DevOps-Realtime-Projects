from flask import Flask, jsonify, render_template, request
from datetime import datetime, timezone
import os
import socket
import uuid

app = Flask(__name__)

APP_NAME = "BlackTunes"
REGION = os.getenv("AWS_REGION", "ap-south-1")
ENVIRONMENT = os.getenv("ENVIRONMENT", "PRIMARY")
RELEASE_VERSION = os.getenv("RELEASE_VERSION", "1.0.0")

TRACKS = [
    {
        "id": 1,
        "title": "Midnight Drive",
        "artist": "Arul Beats",
        "album": "Neon Roads",
        "genre": "Electronic",
        "duration": "3:42",
        "accent": "#7c3aed"
    },
    {
        "id": 2,
        "title": "Mazhai Neram",
        "artist": "Chennai Waves",
        "album": "Monsoon Sessions",
        "genre": "Tamil Indie",
        "duration": "4:08",
        "accent": "#2563eb"
    },
    {
        "id": 3,
        "title": "Cloud Nine",
        "artist": "DevOps Rhythm",
        "album": "Infinite Scale",
        "genre": "Lo-fi",
        "duration": "2:56",
        "accent": "#0891b2"
    },
    {
        "id": 4,
        "title": "Iravu",
        "artist": "BlackTunes Collective",
        "album": "After Dark",
        "genre": "Ambient",
        "duration": "3:31",
        "accent": "#db2777"
    },
    {
        "id": 5,
        "title": "Failover",
        "artist": "Multi Region",
        "album": "Always Available",
        "genre": "Synthwave",
        "duration": "4:15",
        "accent": "#ea580c"
    },
    {
        "id": 6,
        "title": "Salem Sunrise",
        "artist": "Western Ghats",
        "album": "Home",
        "genre": "Acoustic",
        "duration": "3:18",
        "accent": "#16a34a"
    }
]


def utc_timestamp():
    return datetime.now(timezone.utc).isoformat()


@app.context_processor
def inject_platform_data():
    return {
        "app_name": APP_NAME,
        "environment": ENVIRONMENT,
        "region": REGION,
        "release_version": RELEASE_VERSION,
        "hostname": socket.gethostname()
    }


@app.route("/")
def home():
    return render_template(
        "index.html",
        featured_tracks=TRACKS[:4],
        all_tracks=TRACKS
    )


@app.get("/api/tracks")
def list_tracks():
    query = request.args.get("search", "").strip().lower()
    genre = request.args.get("genre", "").strip().lower()

    results = TRACKS

    if query:
        results = [
            track for track in results
            if query in track["title"].lower()
            or query in track["artist"].lower()
            or query in track["album"].lower()
        ]

    if genre:
        results = [
            track for track in results
            if track["genre"].lower() == genre
        ]

    return jsonify({
        "count": len(results),
        "tracks": results,
        "served_by": {
            "environment": ENVIRONMENT,
            "region": REGION
        }
    })


@app.get("/api/tracks/<int:track_id>")
def get_track(track_id):
    track = next(
        (item for item in TRACKS if item["id"] == track_id),
        None
    )

    if track is None:
        return jsonify({
            "error": "track_not_found",
            "message": "The requested track does not exist."
        }), 404

    return jsonify(track)


@app.post("/api/events")
def record_event():
    payload = request.get_json(silent=True) or {}

    return jsonify({
        "event_id": str(uuid.uuid4()),
        "event_type": payload.get("event_type", "unknown"),
        "track_id": payload.get("track_id"),
        "status": "accepted",
        "processed_at": utc_timestamp(),
        "processed_by": REGION
    }), 202


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "application": APP_NAME,
        "environment": ENVIRONMENT,
        "region": REGION,
        "version": RELEASE_VERSION,
        "timestamp": utc_timestamp()
    }), 200


@app.get("/ready")
def readiness():
    return jsonify({
        "status": "ready",
        "hostname": socket.gethostname(),
        "region": REGION
    }), 200


@app.get("/status")
def platform_status():
    return jsonify({
        "application": APP_NAME,
        "environment": ENVIRONMENT,
        "region": REGION,
        "hostname": socket.gethostname(),
        "release_version": RELEASE_VERSION,
        "track_count": len(TRACKS),
        "timestamp": utc_timestamp()
    }), 200


@app.errorhandler(404)
def not_found(_error):
    return jsonify({
        "error": "not_found",
        "message": "The requested BlackTunes resource was not found."
    }), 404


@app.errorhandler(500)
def internal_error(_error):
    return jsonify({
        "error": "internal_server_error",
        "message": "BlackTunes could not process the request."
    }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
