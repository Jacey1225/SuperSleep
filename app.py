from fastapi import FastAPI
from pydantic import BaseModel
from src.neuralnet.fnn import FNN
from src.neuralnet.NeuralNetFuncions import Normalize
from use_DB import DBConnection
import logging
import numpy as np
from advice.compare import CompareSleep

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

class UserData(BaseModel):
    age: int
    gender: str
    sleep_time: str
    wake_up_time: str
    steps: int
    calories: int
    physical_activity: str
    dietary_habits: str
    disorders: str
    medication: str

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
        input_size=10,
        hidden1_size=15,
        hidden2_size=10,
        output_size=1,
        input_weights=input_weights, input_biases=input_biases,
        hidden1_weights=hidden1_weights, hidden1_biases=hidden1_biases,
        hidden2_weights=hidden2_weights, hidden2_biases=hidden2_biases,
        output_weights=output_weights, output_biases=output_biases
    )

    data = {
        "Age": user_data.age,
        "Gender": user_data.gender,
        "Sleep Time": user_data.sleep_time,
        "Wake-up Time": user_data.wake_up_time,
        "Steps": user_data.steps,
        "Calories": user_data.calories,
        "Physical Activity": user_data.physical_activity,
        "Dietary Habits": user_data.dietary_habits,
        "Sleep Disorders": user_data.disorders,
        "Medication Usage": user_data.medication
    }
    normalize = Normalize(user_data)
    normalize.convert_time_columns(["Sleep Time", "Wake-up Time"])
    normalize.not_digit()
    normalize.adjust_outliers()
    user_data_normalized = normalize.data
    nn.forward(user_data_normalized)
    predicted_sleep = nn.output[0][0]
    logger.info(f"Predicted sleep quality: {predicted_sleep}")