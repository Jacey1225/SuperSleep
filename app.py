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
from src.dashboard.groups import CreateGroup
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
async def basic_info(uuid: str, username: str, age: int, gender: str, weight: int, height: int):
    bmi = process_bmi(height, weight)
    if username in db.select_items("username", ["username"], [username]):
        logger.warning(f"Username {username} already exists in the database.")
        return {"error": "Username already exists."}
    
    where_values = ["uuid", "day"]
    values_to_update = ["username", "age", "gender", "weight", "height", "bmi"]
    values = [uuid, datetime.now().strftime("%A"), username, age, gender, weight, height, bmi] 
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

    select_value = "*"
    where_values = ["uuid", "day"]
    values = [uuid, datetime.now().strftime("%A")]
    response = db.select_items(select_value, where_values, values)[0]
    user_data = [response[5], response[4], response[19], response[12], response[14], response[15], response[16], response[11], response[13]]
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
    normalize.adjust_outliers_on_input()
    user_data_normalized = normalize.data
    nn.predict(user_data_normalized)
    predicted_sleep = nn.pred_value[0]
    logger.info(f"Predicted sleep quality: {predicted_sleep}")
    db.update_items(
        ["sleep_quality"], 
        ["username", "day"], 
        [predicted_sleep, uuid, datetime.now().strftime("%A")]
    )
    return {"sleep_quality": predicted_sleep}

@app.get('/sleep-percentage')
async def sleep_percentage(username: str):
    select_value = ["sleep_quality"]
    where_values = ["username"]
    values = [username]
    sleep_quality = db.select_items(select_value, where_values, values)[0][0]
    if not sleep_quality:
        logger.error(f"No data found for user {username}.")
        return {"error": "No data found for the specified user."}

    normalizer = Normalize()
    sleep_percentage = normalizer.decode_label(sleep_quality)
    logger.info(f"Sleep quality percentage for user {username}: {sleep_percentage}%")
    return {"sleep_quality_percentage": sleep_percentage}

# MARK: Micro Habits    
def compare_sleep(username):
    select_value = "*"
    where_values = ["username"]
    values = [username]
    user_data = db.select_items(select_value, where_values, values)[0]

    if not user_data:
        logger.error(f"No data found for user {username}.")
        return {"error": "No data found for the specified user."}
    
    factors = {
        "Sleep Duration": user_data[18],
        "Steps": user_data[10],
        "Physical Activity": user_data[11],
        "Heart Rate": user_data[15],
        "BMI Category": user_data[14],
        "Stress Level": user_data[13],
        "Sleep Disorders": user_data[12],
        "Sleep Quality": user_data[7]
    }


    logger.info(f"Factors for user {username}: {factors}, Sleep Quality: {factors['Sleep Quality']}")
    compare = CompareSleep(factors)
    critical_factors = compare.compare_stats()
    return critical_factors

@app.get('/micro-habits')
async def micro_habits(username: str):
    try:
        user_data = db.select_items("*", ["username"], [username])
        goal = db.select_items("goal", ["username"], [username])[0][0]
        growth_rate = db.select_items("growth_rate", ["username"], [username])[0][0]
        logger.info(f"User data for {username}: {user_data}, Goal: {goal}, Growth Rate: {growth_rate}")

        critical_factors = compare_sleep(username)
        if not critical_factors:
            return {"message": "No critical factors found for the user."}

        logger.info(f"Data for Gemini API: {user_data}, Critical Factors: {critical_factors}, Goal: {goal}, Growth Rate: {growth_rate}")
        prompt = PromptPlan(username, user_data, critical_factors, goal, growth_rate)
        advice = prompt.generate_advice()
        micro_habits = prompt.save_habits(advice)
        logger.info(f"Generated micro habits for user {username}: {micro_habits}")
        return {"micro_habits": micro_habits}
    except Exception as e:
        logger.error(f"Error generating micro habits for user {username}: {e}")
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
async def add_completion(username: str, habit: str):
    try:
        select_value = "habits"
        where_values = ["username"]
        values = [username]
        current_habits = db.select_items(select_value, where_values, values)[0]

        habit_to_update = current_habits[habit]
        habit_to_update[0] += 1
        current_habits[habit] = habit_to_update

        values_to_update = ["habits"]
        where_values = ["username"]
        values = [current_habits, username]
        db.update_items(values_to_update, where_values, values)
        logger.info(f"Added completion for habit '{habit}' for user {username}.")

        return {"message": f"Completion for habit '{habit}' added successfully for user {username}."}
    except Exception as e:
        logger.error(f"Error adding completion for habit '{habit}' for user {username}: {e}")
        return {"error": str(e)}
        
# MARK: Group Functions 
@app.get('/create-group')
async def create_group(username: str):
    group_creator = CreateGroup(username)
    try:
        group_creator.create_group()
        return {"message": "Group created successfully."}
    except Exception as e:
        logger.error(f"Error creating group for user {username}: {e}")
        return {"error": str(e)}
    
@app.get('/invite-to-group')
async def invite_to_group(username: str, invite_user: str):
    group_member = CreateGroup(username)
    try:
        group_member.invite_to_group(invite_user)
        return {"message": f"User {invite_user} invited to group {username}'s group."}
    except Exception as e:
        logger.error(f"Error inviting user {invite_user} to group {username}: {e}")
        return {"error": str(e)}
    
@app.get('/top-friends')
async def top_friends(group_id: str):
    group_creator = CreateGroup()
    group_stats = group_creator.get_group_info(group_id)
    if group_stats:
        leaderboard = group_creator.leaderboard(group_stats)
        logger.info(f"Leaderboard for group {group_id}: {leaderboard}")
        return {"leaderboard": leaderboard[:3]}
    else:
        logger.error(f"No group stats found for group {group_id}.")
        return {"error": "No group stats found for the specified user."}

@app.get('/leave-group')
async def leave_group(username: str):
    group_member = CreateGroup(username)
    try:
        group_member.leave_group(username)
        return {"message": f"User {username} has left the group."}
    except Exception as e:
        logger.error(f"Error leaving group for user {username}: {e}")
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
async def weekly_progress(username: str):
    select_value = "*"
    where_values = ["username"]
    values = [username]
    fetchAmount = 7
    weekly_data = db.select_items(select_value, where_values, values, fetchAmount=fetchAmount)

    if not weekly_data:
        logger.error(f"No weekly data found for user {username}.")
        return {"error": "No weekly data found for the specified user."}
    weekly_data = [[data[6], data[7]] for data in weekly_data]

    week_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    weekly_data = sorted(weekly_data, key=lambda x: week_order.index(x[0]))
    logger.info(f"Weekly progress for user {username}: {weekly_data}")
    return {"weekly_progress": weekly_data}
