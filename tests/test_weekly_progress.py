from fastapi.testclient import TestClient
from app import app, db
import uuid

client = TestClient(app)

def setup_week_data(username):
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    uuids = []
    for i, day in enumerate(days):
        row_uuid = str(uuid.uuid4())
        uuids.append(row_uuid)
        mock_data = {
            "uuid": row_uuid,
            "username": username,
            "height": 170,
            "weight": 70,
            "age": 30,
            "gender": "Female",
            "day": day,
            "sleep_quality": 5 + i,  # 5, 6, 7, 8, 9, 10, 11
            "bedtime": "22:30",
            "waketime": "06:30",
            "steps": 8000 + i * 100,
            "activity_level": "moderate",
            "disorders": "None",
            "stress": 4,
            "bmi": "Normal",
            "h_rate": 65,
            "goal": "Improve sleep",
            "growth_rate": "medium",
            "sleep_duration": 7,
            "group_id": "group-xyz",
            "habits": "[]"
        }
        db.insert_items(list(mock_data.keys()), list(mock_data.values()))
    return uuids

def cleanup_week_data(username, uuids):
    db.delete_items(where_values=["username"], values=[username])
    for row_uuid in uuids:
        db.delete_items(where_values=["uuid"], values=[row_uuid])

def test_weekly_progress():
    username = "weekuser"
    uuids = setup_week_data(username)
    try:
        response = client.get(f"/weekly-progress?username={username}")
        assert response.status_code == 200
        data = response.json()
        assert "weekly_progress" in data
        # Should be 7 values, 5 through 11
        assert data["weekly_progress"] == [['Monday', 5], ['Tuesday', 6], ['Wednesday', 7], ['Thursday', 8], ['Friday', 9], ['Saturday', 10], ['Sunday', 11]]
    finally:
        cleanup_week_data(username, uuids)

# PYTHONPATH=. pytest --log-cli-level=INFO tests/test_weekly_progress.py