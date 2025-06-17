import pytest
from fastapi.testclient import TestClient
from app import app, db
from datetime import datetime

client = TestClient(app)

@pytest.fixture(scope="module", autouse=True)
def setup_group_users():
    group_id = "test-group-123"
    users = [
        {
            "uuid": "uuid1",
            "username": "user1",
            "height": 170,
            "weight": 70,
            "age": 25,
            "gender": "Female",
            "day": datetime.now().strftime("%A"),
            "sleep_quality": 8,
            "bedtime": "22:30",
            "waketime": "06:30",
            "steps": 8000,
            "activity_level": "moderate",
            "disorders": "None",
            "stress": 4,
            "bmi": "Normal",
            "h_rate": 65,
            "goal": "Improve sleep",
            "growth_rate": "medium",
            "sleep_duration": 7,
            "group_id": group_id,
            "habits": "[]"
        },
        {
            "uuid": "uuid2",
            "username": "user2",
            "height": 180,
            "weight": 80,
            "age": 28,
            "gender": "Male",
            "day": datetime.now().strftime("%A"),
            "sleep_quality": 7,
            "bedtime": "23:00",
            "waketime": "07:00",
            "steps": 9000,
            "activity_level": "high",
            "disorders": "None",
            "stress": 3,
            "bmi": "Normal",
            "h_rate": 70,
            "goal": "Better rest",
            "growth_rate": "fast",
            "sleep_duration": 6,
            "group_id": group_id,
            "habits": "[]"
        }
    ]
    # Insert users
    for user in users:
        db.insert_items(list(user.keys()), list(user.values()))
    yield
    # Cleanup
    for user in users:
        db.delete_items(where_values=["uuid"], values=[user["uuid"]])

def test_top_friends_returns_group_members():
    response = client.get("/top-friends", params={"group_id": "test-group-123"})
    assert response.status_code == 200
    data = response.json()
    assert "leaderboard" in data
    leaderboard = data["leaderboard"]
    # Should contain at least both users
    usernames = [entry[0] for entry in leaderboard]
    assert "user1" in usernames
    assert "user2" in usernames

# PYTHONPATH=. pytest --log-cli-level=INFO tests/test_group_functions.py
