import pandas as pd
import numpy as np
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CompareSleep:
    def __init__(self, user_data, predicted_sleep, filename="data/Sleep_Stats(2).csv"):
        self.user_data = user_data
        self.predicted_sleep = predicted_sleep
        self.filename = filename
        self.sleep_stats = pd.read_csv(self.filename)

        mask = (self.sleep_stats["Age"] == self.user_data["Age"]) & \
               (self.sleep_stats["Gender"] == self.user_data.get("Gender")) & \
               (self.sleep_stats["Sleep Disorders"] == self.user_data.get("Sleep Disorders")) & \
               (self.sleep_stats["Medication Usage"] == self.user_data.get("Medication Usage")) & \
               (self.sleep_stats["Sleep Quality"] > self.predicted_sleep)
        self.best_sleep = self.sleep_stats[mask]
    
    def compare_stats(self, threshold=0.3):
        sleep_stat = np.mean(self.best_sleep["Sleep Duration"])
        activity_stat = np.mean(self.best_sleep["Physical Activity"])
        bmi_stat = np.mean(self.best_sleep["BMI Category"])
        h_rate_stat = np.mean(self.best_sleep["Heart Rate"])
        steps_stat = np.mean(self.best_sleep["Steps"])
        stress_stat = np.mean(self.best_sleep["Stress Level"])

        sleep_comp = sleep_stat - self.user_data.get("Sleep Duration", 0)
        activity_comp = activity_stat - self.user_data.get("Physical Activity", 0)
        bmi_comp = bmi_stat - self.user_data.get("BMI Category", 0)
        h_rate_comp = h_rate_stat - self.user_data.get("Heart Rate", 0)
        steps_comp = steps_stat - self.user_data.get("Steps", 0)
        stress_comp = stress_stat - self.user_data.get("Stress Level", 0)
        
        comparison_stats = {
            "Sleep Duration": [sleep_comp, sleep_stat],
            "Physical Activity": [activity_comp, activity_stat],
            "BMI Category": [bmi_comp, bmi_stat],
            "Heart Rate": [h_rate_comp, h_rate_stat],
            "Steps": [steps_comp, steps_stat],
            "Stress Level": [stress_comp, stress_stat]
        }
        critical_factors = [category for category, metrics in comparison_stats.items() if metrics[0] > (metrics[1] * threshold)]
        logger.info(f"Critical factors affecting sleep: {critical_factors}")
        return critical_factors
