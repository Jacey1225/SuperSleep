import unittest
import numpy as np
import pandas as pd
from unittest.mock import patch
from src.neuralnet.fnn import FNN, TrainData

class DummyNormalize:
    def __init__(self, data):
        self.data = data
    def not_digit(self):
        return self.data
    def adjust_outliers(self):
        return self.data

class TestFNN(unittest.TestCase):
    def setUp(self):
        np.random.seed(42)
        self.mock_df = pd.DataFrame({
            'feature1': np.random.rand(10),
            'feature2': np.random.rand(10),
            'feature3': np.random.rand(10),
            'Sleep Quality': np.random.randint(0, 2, 10)
        })

    def test_forward_backward(self):
        features = self.mock_df.drop(columns=['Sleep Quality'])
        labels = self.mock_df['Sleep Quality'].values
        fnn = FNN(input_size=3, hidden1_size=5, hidden2_size=3, output_size=1)
        for i, row in features.iterrows():
            fnn.forward(row.values)
            self.assertIsNotNone(fnn.pred_value)
            # Ensure label shape matches pred_value shape
            label = np.array([labels[i]])
            fnn.backward(label, learning_rate=0.01)

    def test_traindata_feed_input(self):
        self.mock_df.to_csv("mock_data.csv", index=False)
        with patch('src.neuralnet.fnn.Normalize', DummyNormalize):
            train_data = TrainData(epochs=2, train_frac=0.8, filename="mock_data.csv")
            weights_biases = train_data.feed_input()
            self.assertEqual(len(weights_biases), 8)
        import os
        os.remove("mock_data.csv")

if __name__ == '__main__':
    unittest.main()