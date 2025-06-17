import numpy as np
import pandas as pd
import os
import sys
import logging

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from src.neuralnet.fnn import FNN, Normalize

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

FEATURES = [
    "Gender", "Age", "Sleep Duration",
    "Physical Activity Level", "Stress Level", "BMI Category", "Sleep Disorders"
]

def get_user_input():
    user_data = {}
    print("Please enter the following details (case-insensitive, match examples):")
    user_data["Gender"] = input("Gender (Male/Female): ").strip()
    user_data["Age"] = float(input("Age (e.g., 29): ").strip())
    user_data["Sleep Duration"] = float(input("Sleep Duration (hours, e.g., 7.5): ").strip())
    user_data["Physical Activity Level"] = int(input("Physical Activity Level (minutes active per day, e.g., 60): ").strip())
    user_data["Stress Level"] = float(input("Stress Level (1-10): ").strip())
    user_data["BMI Category"] = input("BMI Category (Normal/Normal Weight/Overweight/Obese): ").strip()
    user_data["Sleep Disorders"] = input("Sleep Disorders (None/Sleep Apnea/Insomnia): ").strip()
    return user_data

def main():
    # Get user input
    user_data = get_user_input()
    df = pd.DataFrame([user_data])

    # Load and normalize training data for reference
    data = pd.read_csv("data/Sleep_Stats(2).csv")
    normalizer = Normalize(data.drop(columns=["User ID", "Sleep Quality", "Heart Rate", "Daily Steps"]))
    normalizer.not_digit()
    train_df = normalizer.data
    logger.info(f"Training data before normalization: {train_df}")

    # Apply the same categorical normalization to the test input
    test_normalizer = Normalize(df)
    test_normalizer.not_digit()
    df = test_normalizer.data
    logger.info(f"Current user data before normalization: {df}")
    # No outlier adjustment for single row, but we need to min-max scale using training data's min/max

    # Now min-max normalize using training data's min/max for each feature
    for col in FEATURES:
        if col in train_df.columns and pd.api.types.is_numeric_dtype(df[col]):
            min_val = train_df[col].min()
            max_val = train_df[col].max()

            if max_val != min_val:
                logger.info(f"Normalizing column {col} with min: {min_val}, max: {max_val}")
                df[col] = (df[col] - min_val) / (max_val - min_val)
            else:
                logger.warning(f"Column {col} has constant value, setting to 0.0")
                df[col] = 0.0

    logger.info(f"Normalized user data: {df}")

    # Load weights and biases
    weights = np.load("data/weights(no_device).npz")
    input_weights = weights['input_weights']
    input_biases = weights['input_biases']
    hidden1_weights = weights['hidden1_weights']
    hidden1_biases = weights['hidden1_biases']
    hidden2_weights = weights['hidden2_weights']
    hidden2_biases = weights['hidden2_biases']
    output_weights = weights['output_weights']
    output_biases = weights['output_biases']

    # Create FNN and predict
    model = FNN(
        input_size=len(FEATURES),
        hidden1_size=((len(FEATURES) + 1) // 2) + len(FEATURES),
        hidden2_size=((len(FEATURES) + 1) // 2) + len(FEATURES),
        output_size=1,
        input_weights=input_weights, input_biases=input_biases,
        hidden1_weights=hidden1_weights, hidden1_biases=hidden1_biases,
        hidden2_weights=hidden2_weights, hidden2_biases=hidden2_biases,
        output_weights=output_weights, output_biases=output_biases
    )

    pred = model.predict(df[FEATURES].iloc[0].values)
    logger.info(f"Prediction(Raw): {pred}")
    # Denormalize output
    Y_Max = data["Sleep Quality"].max()
    Y_Min = data["Sleep Quality"].min()
    sleep_quality = (pred[0] * (Y_Max - Y_Min)) + Y_Min

    print(f"\nPredicted Sleep Quality: {sleep_quality:.2f}")

if __name__ == "__main__":
    main()
    #python tests/test_fnn_predict.py