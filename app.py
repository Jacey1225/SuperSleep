from fastapi import FastAPI
from src.neuralnet.fnn import FNN
from src.neuralnet.NeuralNetFuncions import Normalize
from use_DB import DBConnection
import logging
import numpy as np
from advice.compare import CompareSleep
from datetime import datetime
from src.advice.geminiAPI import PromptPlan
from src.dashboard.groups import CreateGroup
import pandas as pd
import json
#MARK: FastAPI Setup
# uvicorn app:app --reload

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

@app.get("/get-username")
async def get_username(uuid: str):
    select_value = "username"
    where_values = ["uuid"]
    values = [uuid]
    try:
        username = db.select_items(select_value, where_values, values)[0][0]
        logger.info(f"Retrieved username {username} for UUID {uuid}.")
        return {"username": username}
    except Exception as e:
        logger.error(f"Error retrieving username: {e}")
        return {"error": str(e)}

# MARK: Helper Functions
def process_height(height):
    str_height = str(height)
    feet = str_height.split(".")[0]
    inches = str_height.split(".")[1]
    if not inches.startswith("0") and len(inches) == 1:
        inches = inches + "0"
    logger.info(f"Processing height: {feet} feet, {inches} inches.")
    total_inches = (int(feet) * 12) + int(inches)
    return int(total_inches)

def process_bmi(height, weight): #pounds and inches
    height_squared = height ** 2
    bmi = (weight / height_squared) * 703
    logger.info(f"Calculated BMI: {bmi} for height: {height} inches and weight: {weight} pounds.")
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
async def basic_info(uuid: str, username: str, age: int, gender: str, weight: int, height: float):
    inches = process_height(height)
    bmi = process_bmi(inches, weight)
    
    where_values = ["uuid", "day"]
    values_to_update = ["username", "age", "gender", "weight", "height", "bmi"]
    values = [username, age, gender, weight, inches, bmi, uuid, datetime.now().strftime("%A")] 
    try:
        db.update_items(values_to_update, where_values, values)
        logger.info(f"Updated basic info for user {uuid} in database.")
    except Exception as e:
        logger.error(f"Error updating basic info: {e}")

@app.get('/additional-info')
async def additional_info(uuid: str, sleep_duration: str, activity: str, stress:int, disorders: str):
    where_values = ["uuid", "day"]
    values_to_update = ["sleep_duration", "activity_level", "stress", "disorders"]
    values = [sleep_duration, activity, stress, disorders, uuid, datetime.now().strftime("%A")]
    try:
        db.update_items(values_to_update, where_values, values)
        logger.info(f"Updated additional info for user in database.")
    except Exception as e:
        logger.error(f"Error updating additional info: {e}")
    
@app.get('/get-device-data')
async def get_device_data(uuid):
    return

# MARK: NN Setup

@app.get("/analyze-data")
async def fetch_data(uuid: str, has_device: bool):
    logger.info(f"Device data presence for user {uuid}: {has_device}")
    if has_device:
        adjustments = np.load("data/weights(1).npz")
    else:
        adjustments = np.load("data/weights(no_device).npz")

    input_weights = adjustments['input_weights']
    input_biases = adjustments['input_biases']

    hidden1_weights = adjustments['hidden1_weights']
    hidden1_biases = adjustments['hidden1_biases']

    hidden2_weights = adjustments['hidden2_weights']
    hidden2_biases = adjustments['hidden2_biases']

    output_weights = adjustments['output_weights']
    output_biases = adjustments['output_biases']

    select_value = "*"
    where_values = ["uuid", "day"]
    values = [uuid, datetime.now().strftime("%A")]
    response = db.select_items(select_value, where_values, values)[0]
    if has_device:
        user_data = [response[5], response[4], response[16], response[9], response[11], response[12], response[13], response[8], response[10]]
        data_df = pd.DataFrame([user_data], columns=["Gender", "Age", "Sleep Duration", "Physical Activity Level", 
                                                "Stress Level", "BMI Category", "Heart Rate", "Daily Steps", 
                                                "Sleep Disorders"])
    else:
        user_data = [response[5], response[4], response[16], response[9], response[11], response[12], response[13]]
        data_df = pd.DataFrame([user_data], columns=["Gender", "Age", "Sleep Duration", "Physical Activity Level",
                                                "Stress Level", "BMI Category", "Sleep Disorders"])
    
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
    normalize.adjust_outliers_on_input()
    user_data_normalized = normalize.data
    nn.predict(user_data_normalized)
    predicted_sleep = nn.pred_value[0][0]
    predicted_sleep = normalize.decode_label(predicted_sleep)
    logger.info(f"Predicted sleep quality: {predicted_sleep}")
    db.update_items(
        ["sleep_quality"], 
        ["uuid", "day"], 
        [predicted_sleep, uuid, datetime.now().strftime("%A")]
    )
    return {"sleep_quality": predicted_sleep}

@app.get('/get-sleep-quality')
async def get_sleep_quality(uuid: str):
    select_value = "sleep_quality"
    where_values = ["uuid", "day"]
    values = [uuid, datetime.now().strftime("%A")]
    sleep_quality = db.select_items(select_value, where_values, values)[0][0]
    sleep_quality = round((sleep_quality * 10), 0)
    
    if not sleep_quality:
        logger.error(f"No sleep quality data found for user {uuid}.")
        return {"error": "No sleep quality data found for the specified user."}
    
    logger.info(f"Sleep quality for user {uuid}: {int(sleep_quality)}")
    return {"sleep_quality": int(sleep_quality)}

# MARK: Habits    
def compare_sleep(username, has_device=False):
    select_value = "*"
    where_values = ["username"]
    values = [username]
    user_data = db.select_items(select_value, where_values, values)[0]

    if not user_data:
        logger.error(f"No data found for user {username}.")
        return {"error": "No data found for the specified user."}
    
    factors = {
        "Sleep Duration": user_data[16],
        "Steps": user_data[8],
        "Physical Activity": user_data[9],
        "Heart Rate": user_data[13],
        "BMI Category": user_data[12],
        "Stress Level": user_data[11],
        "Sleep Disorders": user_data[10],
        "Sleep Quality": user_data[7]
    }


    logger.info(f"Factors for user {username}: {factors}, Sleep Quality: {factors['Sleep Quality']}")
    compare = CompareSleep(factors, has_device)
    critical_factors = compare.compare_stats()
    return critical_factors

@app.get("/five-min-habit")

@app.get('/micro-habits')
async def micro_habits(uuid: str, has_device: bool = False):
    try:
        username = db.select_items("username", ["uuid"], [uuid])[0][0]
        logger.info(f"Found username {username} for UUID {uuid}.")
        user_data = db.select_items("*", ["username"], [username])
        goal = db.select_items("goal", ["username"], [username])[0][0]
        growth_rate = db.select_items("growth_rate", ["username"], [username])[0][0]
        logger.info(f"User data for {username}: {user_data}, Goal: {goal}, Growth Rate: {growth_rate}")

        critical_factors = compare_sleep(username, has_device)
        if not critical_factors:
            logger.warning(f"No critical factors found for user {username}.")
            

        logger.info(f"Data for Gemini API: {user_data}, Critical Factors: {critical_factors}, Goal: {goal}, Growth Rate: {growth_rate}")
        prompt = PromptPlan(username, user_data, critical_factors, goal, growth_rate)
        advice = prompt.generate_advice()
        micro_habits = prompt.save_habits(advice)
        logger.info(f"Generated micro habits for user {username}: {micro_habits}")
        return {"micro_habits": micro_habits}
    except Exception as e:
        logger.error(f"Error generating micro habits for user {username}: {e}")
        return {"error": str(e)}

@app.get('/get-micro-habits')
async def get_micro_habits(uuid: str):
    try:
        select_value = "habits"
        where_values = ["uuid"]
        values = [uuid]
        habits = db.select_items(select_value, where_values, values)[0][0]
        
        if not habits:
            logger.error(f"No habits found for user {uuid}.")
            return {"error": "No habits found for the specified user."}
        
        logger.info(f"Habits for user {uuid}: {habits}")
        if isinstance(habits, str):
            habits = json.loads(habits)
        return {"habits": habits}
    
    except Exception as e:
        logger.error(f"Error fetching habits for user {uuid}: {e}")
        return {"error": str(e)}
    
@app.get('/add-habit')
async def add_habit(username: str, habit: str):
    try:
        select_value = "habits"
        where_values = ["username"]
        values = [username]
        current_habits = db.select_items(select_value, where_values, values)[0][0]
        if isinstance(current_habits, list):
            current_habits.append(habit)

        values_to_update = ["habits"]
        where_values = ["username"]
        values = [current_habits, username]
        db.update_items(values_to_update, where_values, values)
        logger.info(f"Added habit '{habit}' for user {username}.")
        return {"message": f"Habit '{habit}' added successfully for user {username}."}
    
    except Exception as e:
        logger.error(f"Error adding habit for user {username}: {e}")
        return {"error": str(e)}
    
@app.get('/add-completion')
async def add_completion(uuid: str, habit: str):
    try:
        select_value = "habits"
        where_values = ["uuid"]
        values = [uuid]
        current_habits = db.select_items(select_value, where_values, values)[0][0]
        current_habits = json.loads(current_habits)

        habit_to_update = current_habits[habit]
        habit_to_update[0] += 1
        current_habits[habit] = habit_to_update

        values_to_update = ["habits"]
        where_values = ["uuid"]
        values = [json.dumps(current_habits), uuid]
        db.update_items(values_to_update, where_values, values)
        logger.info(f"Added completion for habit '{habit}' for user {uuid}.")

        return {"message": f"Completion for habit '{habit}' added successfully for user {uuid}."}
    except Exception as e:
        logger.error(f"Error adding completion for habit '{habit}' for user {uuid}: {e}")
        return {"error": str(e)}
        
# MARK: Group Functions 
@app.get("/get-group-id")
async def get_group_id(uuid: str):
    select_value = "group_id"
    where_values = ["uuid"]
    values = [uuid]
    group_id = db.select_items(select_value, where_values, values)[0][0]
    
    if not group_id:
        logger.error(f"No group ID found for user {uuid}.")
        return {"error": "No group ID found for the specified user."}
    
    logger.info(f"Group ID for user {uuid}: {group_id}")
    return {"group_id": group_id}

@app.get('/create-group')
async def create_group(uuid: str):
    username = db.select_items("username", ["uuid"], [uuid])[0][0]
    group_creator = CreateGroup(username)
    try:
        group_creator.create_group()
        return {"message": "Group created successfully."}
    except Exception as e:
        logger.error(f"Error creating group for user {username}: {e}")
        return {"error": str(e)}
    
@app.get('/join-group')
async def join_group(uuid: str, group_id: str):
    username = db.select_items("username", ["uuid"], [uuid])[0][0]
    group_member = CreateGroup(username)
    try:
        group_member.join_group(group_id)
        return {"message": f"User {username} joined group {group_id} successfully."}
    except Exception as e:
        logger.error(f"Error joining group {group_id} for user {username}: {e}")
        return {"error": str(e)}
    
@app.get('/invite-to-group')
async def invite_to_group(uuid: str):
    try:
        select_value = "group_id"
        where_values = ["uuid"]
        values = [uuid]
        group_id = db.select_items(select_value, where_values, values)[0][0]
        return {"group_id": group_id}
    except Exception as e:
        logger.error(f"Error retrieving group ID from {uuid}: {e}")
        return {"error": str(e)}
    
@app.get('/top-friends')
async def top_friends(group_id: str):
    if not group_id:
        logger.error("Group ID is required to fetch top friends.")
        return {"error": "Group ID is required."}
    group_creator = CreateGroup()
    group_stats = group_creator.get_group_info(group_id)
    if group_stats:
        leaderboard = group_creator.leaderboard(group_stats)
        logger.info(f"Leaderboard for group {group_id}: {leaderboard}")
        return {"leaderboard": leaderboard[:3]}
    else:
        logger.error(f"No group stats found for group {group_id}.")
        return {"error": "No group stats found for the specified user."}

@app.get("/all-friends")
async def all_friends(group_id: str):
    if not group_id:
        logger.error("Group ID is required to fetch all friends.")
        return {"error": "Group ID is required."}
    group_creator = CreateGroup()
    group_stats = group_creator.get_group_info(group_id)
    if group_stats:
        leaderboard = group_creator.leaderboard(group_stats)
        logger.info(f"All friends for group {group_id}: {leaderboard}")
        return {"leaderboard": leaderboard}
    else:
        logger.error(f"No group stats found for group {group_id}.")
        return {"error": "No group stats found for the specified user."}

@app.get('/leave-group')
async def leave_group(uuid: str):
    group_member = CreateGroup(uuid)
    try:
        group_member.leave_group(uuid)
        return {"message": f"User {uuid} has left the group."}
    except Exception as e:
        logger.error(f"Error leaving group for user {uuid}: {e}")
        return {"error": str(e)}
    
 # MARK: Daily Reset
@app.get('/new-data')
async def new_data(username: str, sleep_duration: int, wake_time:str, sleep_time: str, activity: str, stress: int):
    select_values = ["age", "gender", "weight", "height", "bmi", "disorders", "goal", "growth_rate", "group_id"]
    where_values = ["username"]
    values = [username]
    user_data = db.select_items(select_values, where_values, values)[0]
    if not user_data:
        logger.error(f"No user data found for {username}.")
        return {"error": "No user data found for the specified user."}
        
    where_values = ["username", "height", "weight", "age", "gender", 
                    "day", "sleep_duration", "bedtime", "waketime", "activity", "stress",
                    "bmi", "disorders", "goal", "growth_rate", "group_id"]
    # FIXME: Relocate user_data positions to correct data
    values = [username, user_data[3], user_data[2], user_data[0], user_data[1], 
                datetime.now().strftime("%A"), sleep_duration, sleep_time, wake_time, activity, stress,
                user_data[4], user_data[5], user_data[6], user_data[7], user_data[8]]
    try:
        db.insert_items(where_values, values)
        logger.info(f"Inserted new daily data for user {username}.")
    except Exception as e:
        logger.error(f"Error inserting new daily data for user {username}: {e}")
        return {"error": str(e)}
    return {"message": "New daily data inserted successfully."}

# MARK: Weekly Progress
@app.get('/weekly-progress')
async def weekly_progress(uuid: str):
    select_value = "*"
    where_values = ["uuid"]
    values = [uuid]
    fetchAmount = 7
    weekly_data = db.select_items(select_value, where_values, values, fetchAmount=fetchAmount)

    if not weekly_data:
        logger.error(f"No weekly data found for user {uuid}.")
        return {"error": "No weekly data found for the specified user."}
    weekly_data = [[data[6], int(data[7] * 10)] for data in weekly_data]

    week_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    weekly_data = sorted(weekly_data, key=lambda x: week_order.index(x[0]))
    logger.info(f"Weekly progress for user {uuid}: {weekly_data}")
    return {"weekly_progress": weekly_data}
