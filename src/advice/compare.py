import pandas as pd
import numpy as np
import logging
from src.neuralnet.NeuralNetFuncions import Normalize

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CompareSleep:
    def __init__(self, factors, filename="data/Sleep_Stats(2).csv"):
        self.user_normalizer = Normalize([factors])
        self.factors = factors
        self.user_normalizer.not_digit()
        self.user_normalizer.adjust_outliers_on_input()
        self.factors = self.user_normalizer.data

        self.filename = filename
        self.sleep_stats = pd.read_csv(self.filename)
        self.data_normalizer = Normalize(self.sleep_stats.drop(columns=["User ID", "Gender", "Age"]))
        self.data_normalizer.not_digit()
        self.data_normalizer.adjust_outliers()
        self.sleep_stats = self.data_normalizer.data
        
        user_disorder = self.factors["Sleep Disorders"].iloc[0]
        user_sleep_quality = self.factors["Sleep Quality"].iloc[0]
        mask = (self.sleep_stats["Sleep Disorders"] == user_disorder) & \
               (self.sleep_stats["Sleep Quality"] >= user_sleep_quality) 
        self.best_sleep = self.sleep_stats[mask]

        if len(self.best_sleep) > 0:
            logger.info(f"Best sleep stats found: {self.best_sleep.head()}")
        else:
            logger.warning("No matching sleep stats found for the user's sleep disorders and predicted sleep quality.")
       
    def compare_stats(self, threshold=0.3):
        sleep_stat = np.mean(self.best_sleep["Sleep Duration"])
        activity_stat = np.mean(self.best_sleep["Physical Activity Level"])
        bmi_stat = np.mean(self.best_sleep["BMI Category"])
        h_rate_stat = np.mean(self.best_sleep["Heart Rate"])
        steps_stat = np.mean(self.best_sleep["Daily Steps"])
        stress_stat = np.mean(self.best_sleep["Stress Level"])

        sleep_comp = sleep_stat - self.factors["Sleep Duration"].iloc[0]
        activity_comp = activity_stat - self.factors["Physical Activity"].iloc[0]
        bmi_comp = bmi_stat - self.factors["BMI Category"].iloc[0]
        h_rate_comp = h_rate_stat - self.factors["Heart Rate"].iloc[0]
        steps_comp = steps_stat - self.factors["Steps"].iloc[0]
        stress_comp = stress_stat - self.factors["Stress Level"].iloc[0]
        
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
