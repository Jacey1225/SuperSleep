import numpy as np
import pandas as pd
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class Variables:  
    def __init__(self, activation=None, product=None, next_layer_dLdz=None, next_layer_weights=None, last_out=None, 
                 weights=None, biases=None, pred_value=None, true_value=None, error=None):
        self.a = activation
        self.z = product
        self.weights = weights
        self.biases = biases

        self.pred_value = pred_value
        self.true_value = true_value
        self.error = error

        self.next_layer_dLdz = next_layer_dLdz
        self.next_layer_weights = next_layer_weights
        self.last_out = last_out

class Gradient(Variables):  
    def adjust(self, learning_rate, layer_type='output'):
        if layer_type == 'output':
            dLdyt = 2 * (self.pred_value - self.true_value)
            dLdz = Activations.sigmoid_derivative(self.z) * dLdyt

        elif layer_type == 'hidden':
            dLdyt = np.dot(self.next_layer_dLdz, self.next_layer_weights.T)
            dLdz = Activations.relu_derivative(self.z) * dLdyt

        dLdw = np.outer(self.last_out, dLdz)
        dLdb = dLdz

        self.weights -= learning_rate * dLdw
        self.biases -= learning_rate * dLdb
        
        return dLdz, self.weights

class Loss(Variables):
    def mse(self):
        if self.pred_value is None or self.true_value is None:
            raise ValueError("pred_value and true_value must be set before calculating loss.")
        
        self.error = np.square(np.subtract(self.pred_value, self.true_value))
        return self.error

class Activations:
    @staticmethod
    def sigmoid(z):
        return 1 / (1 + np.exp(-z))
    
    @staticmethod
    def sigmoid_derivative(z):
        sig = Activations.sigmoid(z)
        return sig * (1 - sig)
    
    @staticmethod
    def relu(z):
        return np.maximum(0, z)
    
    @staticmethod
    def relu_derivative(z):
        result = np.where(z > 0, 1, 0)
        return result
    
class Normalize:
    def __init__(self, data):
        self.data = pd.DataFrame(data)
        self.columns = self.data.columns
    
    def not_digit(self):
        self.data["Gender"] = self.data["Gender"].replace(
            {"f": 0, "m": 1, "F": 0, "M": 1, "Female": 0, "Male": 1}
        )
        logger.info("Gender normalized to 0, 1")

        if "BMI Category" in self.data.columns:
            self.data["BMI Category"] = self.data["BMI Category"].replace(
                {"Normal": 0, "Normal Weight": 0, "Overweight": 1, "Obese": 2}
            )
            logger.info("BMI Category normalized to 0, 1, 2")

        if "Sleep Disorders" in self.data.columns:
            self.data["Sleep Disorders"] = self.data["Sleep Disorders"].astype(str).str.strip().str.lower()
            self.data["Sleep Disorders"] = self.data["Sleep Disorders"].replace(
                {"nan": 0, "none": 0, "no": 0, "no": 0, "sleep apnea": 1, "insomnia": 1, "yes": 1}
            )
            logger.info("Sleep Disorders normalized to 0, 1")

        if "Medication Usage" in self.data.columns:
            self.data["Medication Usage"] = self.data["Medication Usage"].replace(
                {"No": 0, "no": 0, "Yes": 1, "yes": 1}
            )
            logger.info("Medication Usage normalized to 0, 1")

        if "Dietary Habits" in self.data.columns:
            self.data["Dietary Habits"] = self.data["Dietary Habits"].replace(
                {"healthy": 0, "medium": 1, "unhealthy": 2}
            )
            logger.info("Dietary Habits normalized to 0, 1, 2")

        if self.data["Physical Activity Level"].apply(lambda x: isinstance(x, str)).any():
            self.data["Physical Activity Level"] = self.data["Physical Activity Level"].replace(
                {"low": 0, "medium": 1, "high": 2}
            )
            logger.info("Physical Activity Level normalized to 0, 1, 2")

        return self.data
    
    def time_to_float(self, time_str):
        """Convert a time string 'HH:MM' to a float: hour + (minute/60)."""
        if isinstance(time_str, str) and ":" in time_str:
            hour, minute = map(int, time_str.split(":"))
            return hour + minute / 60.0
        return np.nan  # or handle as needed

    def convert_time_columns(self, columns):
        """Convert specified time columns in self.data to float representation."""
        for col in columns:
            if col in self.data.columns:
                self.data[col] = self.data[col].apply(self.time_to_float)
        return self.data
    
    def adjust_outliers(self):
        for column in self.data.columns:
            min = np.min(self.data[column])
            max = np.max(self.data[column])
            self.data[column] = (self.data[column] - min) / (max - min)
            logger.info(f"Column {column} normalized with min: {min}, max: {max}")

