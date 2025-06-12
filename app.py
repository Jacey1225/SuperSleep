from fastapi import FastAPI
from pydantic import BaseModel
from src.neuralnet.fnn import FNN
from src.neuralnet.NeuralNetFuncions import Normalize
from use_DB import DBConnection
import logging
import numpy as np
from advice.compare import CompareSleep
from datetime import datetime
from src.advice.geminiAPI import PromptPlan
import pandas as pd

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

db = DBConnection(table="sleepMembers")

# MARK: Minor User Info

@app.get("/set-goals")
async def goals(uuid, goal, growth_rate):
    where_values = ["uuid", "goal", "growth_rate", "day"]
    values = [uuid, goal, growth_rate, datetime.now().strftime("%A")]
    try:
        db.insert_items(where_values, values)
        logger.info(f"Stored goals for user {uuid} in database.")
    except Exception as e:
        logger.error(f"Error storing goals: {e}")

@app.get('/get-device-data')
async def get_device_data(uuid):
    return

# MARK: Helper Functions

def process_bmi(height, weight): #pounds and inches
    height_squared = height ** 2
    bmi = (weight / height_squared) * 703
    if bmi > 18.5 and bmi < 24.9:
        return "Normal"
    elif bmi >= 25 and bmi < 29.9:
        return "Overweight"
    elif bmi >= 30:
        return "Obese"
    else:
        return "Normal"
    
# MARK: Target Function ^
@app.get('/basic-info')
async def basic_info(uuid: str, name: str, age: int, gender: str, weight: int, height: int):
    bmi = process_bmi(height, weight)
    where_values = ["uuid", "day"]
    values_to_update = ["username", "age", "gender", "weight", "height", "bmi"]
    values = [uuid, datetime.now().strftime("%A"), name, age, gender, weight, height, bmi] 
    try:
        db.update_items(where_values, values_to_update, values, uuid)
        logger.info(f"Updated basic info for user {uuid} in database.")
    except Exception as e:
        logger.error(f"Error updating basic info: {e}")

@app.get('/additional-info')
async def additional_info(uuid: str, sleep_duration: str, sleep_time: str, wake_time: str, activity: str, stress:int, disorders: str):
    where_values = ["uuid", "day"]
    values_to_update = ["sleep_duration", "sleep_time", "wake_time", "activity", "stress", "disorders"]
    values = [uuid, datetime.now().strftime("%A"), sleep_duration, sleep_time, wake_time, activity, stress, disorders]
    try:
        db.update_items(where_values, values_to_update, values)
        logger.info(f"Updated additional info for user in database.")
    except Exception as e:
        logger.error(f"Error updating additional info: {e}")
    

@app.get("/analyze-data")
async def fetch_data(uuid: str):
# MARK: NN Setup
    adjustments = np.load("data/weights.npz")
    input_weights = adjustments['input_weights']
    input_biases = adjustments['input_biases']

    hidden1_weights = adjustments['hidden1_weights']
    hidden1_biases = adjustments['hidden1_biases']

    hidden2_weights = adjustments['hidden2_weights']
    hidden2_biases = adjustments['hidden2_biases']

    output_weights = adjustments['output_weights']
    output_biases = adjustments['output_biases']

    select_value = ["gender", "age", "sleep_duration", "activity_level", "stress", "bmi", "h_rate", "steps", "disorders"]
    where_values = ["uuid", "day"]
    values = [uuid, datetime.now().strftime("%A")]
    user_data = db.select_items(select_value, where_values, values)[0]
    data_df = pd.DataFrame(user_data, columns=["Gender", "Age", "Sleep Duration", "Physical Activity Level", 
                                               "Stress Level", "BMI Category", "Heart Rate", "Daily Steps", 
                                               "Sleep Disorders"])
    
    nn = FNN(
        input_size=len(data_df.columns),
        hidden1_size=((len(user_data) + 1) // 2) + len(data_df.columns),
        hidden2_size=((len(user_data) + 1) // 2) + len(data_df.columns),
        output_size=1,
        input_weights=input_weights, input_biases=input_biases,
        hidden1_weights=hidden1_weights, hidden1_biases=hidden1_biases,
        hidden2_weights=hidden2_weights, hidden2_biases=hidden2_biases,
        output_weights=output_weights, output_biases=output_biases
    )

# MARK: Sleep Quality
    normalize = Normalize(data_df)
    normalize.not_digit()
    normalize.adjust_outliers()
    user_data_normalized = normalize.data
    nn.forward(user_data_normalized)
    predicted_sleep = nn.pred_value[0]
    logger.info(f"Predicted sleep quality: {predicted_sleep}")
    db.update_items(
        ["predicted_sleep_quality"], 
        ["username", "day"], 
        [predicted_sleep, uuid, datetime.now().strftime("%A")]
    )
    return {"predicted_sleep_quality": predicted_sleep}

@app.get('/sleep-percentage')
async def sleep_percentage(username: str):
    select_value = ["sleep_quality"]
    where_values = ["username"]
    values = [username]
    sleep_quality = db.select_items(select_value, where_values, values)[0][0]
    if not sleep_quality:
        logger.error(f"No data found for user {username}.")
        return {"error": "No data found for the specified user."}

    sleep_percentage = sleep_quality * 100
    logger.info(f"Sleep quality percentage for user {username}: {sleep_percentage}%")
    return {"sleep_quality_percentage": sleep_percentage}

# MARK: Micro Habits

def compare_sleep(username):
    select_value = ["*"]
    where_values = ["username"]
    values = [username]
    user_data = db.select_items(select_value, where_values, values)[0]

    if not user_data:
        logger.error(f"No data found for user {username}.")
        return {"error": "No data found for the specified user."}
    
    sleep_quality = user_data[7]
    factors = {
        "Sleep Duration": user_data[5],
        "Steps": user_data[15],
        "Physical Activity": user_data[11],
        "Heart Rate": user_data[9],
        "BMI Category": user_data[14],
        "Stress Level": user_data[13],
    }

    compare = CompareSleep(factors, sleep_quality)
    critical_factors = compare.compare_stats()
    logger.info(f"Critical factors affecting sleep for user {username}: {critical_factors}")
    return critical_factors

@app.get('/micro-habits')
async def micro_habits(username: str):
    try:
        user_data = db.select_items(["*"], ["username"], [username])
        goal = db.select_items(["goal"], ["username"], [username])[0][0]
        growth_rate = db.select_items(["growth_rate"], ["username"], [username])[0][0]
        critical_factors = compare_sleep(username)
        if not critical_factors:
            return {"message": "No critical factors found for the user."}

        prompt = PromptPlan(user_data, critical_factors, goal, growth_rate)
        micro_habits = prompt.generate_advice()
        logger.info(f"Generated micro habits for user {username}: {micro_habits}")
        return {"micro_habits": micro_habits}
    except Exception as e:
        logger.error(f"Error generating micro habits for user {username}: {e}")
        return {"error": str(e)}
    
@app.get('/top-friends')
async def top_friends(username: str):
    return