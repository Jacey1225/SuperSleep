import os
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()
key=os.getenv("API_KEY")
genai.configure(api_key=key)

class PromptPlan:
    def __init__(self):
        self.model = genai.GenerativeModel("gemini-1.5-flash")
        self.default_prompt = "You are a helpful sleep assistant that provides specific advice on how to improve the quality of " \
        "sleep based on the user's input such as age, gender, sleep times, physical activity, mental health, and disorders." \
        "Your mission is to help people build up their lifestyle by changing their daily habits incrementally. This user's current" \
        "lifestyle is: "
        self.communicate = "Given this information, can you help the user with these questions or concerns: "
    def generate_advice(self, user_stats, user_input):
        prompt = self.default_prompt + user_stats + self.communicate + user_input
        response = self.model.generate_content(prompt)
        if response.error:
            raise Exception(f"Error generating text: {response.error.message}")
        return response.text.strip()
    
