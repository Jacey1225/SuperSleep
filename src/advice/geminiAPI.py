import os
from dotenv import load_dotenv
import google.generativeai as genai
from use_DB import DBConnection
import logging
import json

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()
key=os.getenv("API_KEY")
genai.configure(api_key=key)

class PromptPlan:
    def __init__(self, username, user_stats, critical_factors, goal, progress_speed):
        self.model = genai.GenerativeModel("gemini-1.5-flash")
        self.default_prompt = f"You are a helpful health assistant that provides specific advice to help the user {goal} " \
        "based on their input such as age, gender, sleep times, physical activity, mental health, and disorders." \
        "Your mission is to help people build up their lifestyle by changing their daily habits incrementally. This user's current" \
        "lifestyle is: "
        self.username = username
        self.user_stats = user_stats + "."
        self.critical_factors = "According to sleep quality records, the user lacks in: " + critical_factors
        self.plan = f"Given this information, can you give the user some daily changes to gradually commit to over {progress_speed} that will help them raise their sleep quality and achieve their goal? "
        self.format = "Format your response as a dictionary with the following keys: " \
        "Lacking Factor: [habit to change ith the intention of improving the factor of concern, days per week to commit to the habits based on how mentally demanding the habit can be] "
        
        self.db = DBConnection(table="sleepMembers")

    def generate_advice(self):
        prompt = self.default_prompt + self.user_stats + self.critical_factors + self.plan + self.format
        logger.info(f"Generated prompt: {prompt}")
        response = self.model.generate_content(prompt)
        logger.info(f"Response from Gemini: {response.text}")

        if response.error:
            raise Exception(f"Error generating text: {response.error.message}")
        return json.loads(response.text)

    def save_habits(self, advice: dict): 
        micro_habits = [habit for _, habit in advice.items()]
        logger.info(f"Micro habits to save: {micro_habits}")

        values_to_update = ["habits"]
        where_values = ["username"]
        values = [micro_habits, self.username]
        try:
            self.db.update_items(values_to_update, where_values, values)
            logger.info("Habits saved successfully.")
            return micro_habits
        except Exception as e:
            logger.error(f"Error saving habits: {e}")
            raise e
    

        
    
