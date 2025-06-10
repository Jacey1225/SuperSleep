from fastapi import FastAPI
from pydantic import BaseModel
from src.neuralnet.fnn import FNN
from src.neuralnet.NeuralNetFuncions import Normalize
from use_DB import DBConnection
import logging
import numpy as np
from advice.compare import CompareSleep
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

class UserData(BaseModel):
    username: str
    fName: str
    lName: str
    age: int
    gender: str
    height: int
    weight: int
    sleep_time: str
    wake_up_time: str
    stress: int
    bmi_category: str
    h_rate: int
    steps: int
    physical_activity: str
    disorders: str

def store_user_data(sleep_quality, user_data: UserData):
    db = DBConnection(table="sleepMembers")
    try:
        where_values = ["username", "fName", "lName",
                         "height", "weight", "age", 
                         "gender", "day", "sleep_quality",
                         "sleep_time", "wake_up_time", "h_rate",
                         "steps", "physical_activity", "stress",
                         "bmi_category", "disorders"]
        values = [user_data.username, user_data.fName, user_data.lName,
                  user_data.height, user_data.weight, user_data.age,
                  user_data.gender, datetime.now().strftime("%A"), sleep_quality,
                  user_data.sleep_time, user_data.wake_up_time, user_data.h_rate,
                  user_data.steps, user_data.physical_activity, user_data.stress,
                  user_data.bmi_category, user_data.disorders]

        db.insert_items(where_values, values)
        logger.info(f"Stored user data for {user_data.username} in database.")
    except Exception as e:
        logger.error(f"Error storing user data: {e}")

@app.get("/fetch-data")
async def fetch_data(user_data: UserData):
    adjustments = np.load("data/weights.npz")
    input_weights = adjustments['input_weights']
    input_biases = adjustments['input_biases']

    hidden1_weights = adjustments['hidden1_weights']
    hidden1_biases = adjustments['hidden1_biases']

    hidden2_weights = adjustments['hidden2_weights']
    hidden2_biases = adjustments['hidden2_biases']

    output_weights = adjustments['output_weights']
    output_biases = adjustments['output_biases']
    
    nn = FNN(
        input_size=len(user_data.model_dump()),
        hidden1_size=((len(user_data.model_dump()) + 1) // 2) + len(user_data.model_dump()),
        hidden2_size=((len(user_data.model_dump()) + 1) // 2) + len(user_data.model_dump()),
        output_size=1,
        input_weights=input_weights, input_biases=input_biases,
        hidden1_weights=hidden1_weights, hidden1_biases=hidden1_biases,
        hidden2_weights=hidden2_weights, hidden2_biases=hidden2_biases,
        output_weights=output_weights, output_biases=output_biases
    )

    user_data_dict = user_data.model_dump()
    normalize = Normalize(user_data_dict.values())
    normalize.convert_time_columns(["Sleep Time", "Wake-up Time"])
    normalize.not_digit()
    normalize.adjust_outliers()
    user_data_normalized = normalize.data
    nn.forward(user_data_normalized)
    predicted_sleep = nn.pred_value[0]
    logger.info(f"Predicted sleep quality: {predicted_sleep}")

    store_user_data(predicted_sleep, user_data_dict.values())

async def compare_sleep(user_data: UserData):
    return