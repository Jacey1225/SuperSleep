import pytest
from fastapi.testclient import TestClient
from app import app, db
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

client = TestClient(app)

@pytest.fixture(scope="module", autouse=True)
def setup_test_user():
    username = "testuser"
    uuid = "test-uuid-123"
    today = datetime.now().strftime("%A")
    mock_data = {
        "uuid": uuid,
        "username": username,
        "height": 170,
        "weight": 70,
        "age": 30,
        "gender": "Female",
        "day": today,
        "sleep_quality": 5,
        "bedtime": "22:30",
        "waketime": "06:30",
        "steps": 8000,
        "activity_level": 60,
        "disorders": "None",
        "stress": 4,
        "bmi": "Normal",
        "h_rate": 65,
        "goal": "Improve sleep",
        "growth_rate": "2 weeks",
        "sleep_duration": 7,
        "group_id": "group-xyz",
        "habits": "{}"
    }
    db.insert_items(list(mock_data.keys()), list(mock_data.values()))
    yield

    select_value = "*"
    where_values = ["username"]
    values = [username]
    logger.info(f"Current user data before cleanup: {db.select_items(select_value, where_values, values)}")
    # Cleanup: remove test user data from the database
    db.delete_items(where_values=["username"], values=[username])

def test_micro_habits():
    username = "testuser"
    response = client.get(f"/micro-habits?username={username}")
    assert response.status_code == 200
    data = response.json()

    assert "micro_habits" in data or "error" in data
    if "micro_habits" in data:
        assert isinstance(data["micro_habits"], dict) or isinstance(data["micro_habits"], list)

    

# PYTHONPATH=. pytest --log-cli-level=INFO tests/test_micro_habits_api.py