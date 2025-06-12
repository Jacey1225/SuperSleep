import os
from dotenv import load_dotenv
import google.generativeai as genai
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()
key=os.getenv("API_KEY")
genai.configure(api_key=key)

class PromptPlan:
    def __init__(self, user_stats, critical_factors, goal, progress_speed):
        self.model = genai.GenerativeModel("gemini-1.5-flash")
        self.default_prompt = f"You are a helpful health assistant that provides specific advice to help the user {goal} " \
        "based on their input such as age, gender, sleep times, physical activity, mental health, and disorders." \
        "Your mission is to help people build up their lifestyle by changing their daily habits incrementally. This user's current" \
        "lifestyle is: "
        self.user_stats = user_stats + "."
        self.critical_factors = "According to sleep quality records, the user lacks in: " + critical_factors
        self.plan = f"Given this information, can you give the user some changes to gradually commit to over {progress_speed} that will help them raise their sleep quality and achieve their goal? "
        self.format = "Please format your response as a categorized list of the lacking factors, " \
        "the changes to make, and how many days per week each should be committed to given how demanding or intense the change is."

    def generate_advice(self):
        prompt = self.default_prompt + self.user_stats + self.critical_factors + self.plan + self.format
        logger.info(f"Generated prompt: {prompt}")
        response = self.model.generate_content(prompt)
        logger.info(f"Response from Gemini: {response.text}")

        if response.error:
            raise Exception(f"Error generating text: {response.error.message}")
        return response.text.strip()
    
