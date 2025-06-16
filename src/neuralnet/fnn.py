import pandas as pd
import numpy as np
import logging
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from src.neuralnet.NeuralNetFuncions import Gradient, Loss, Activations, Normalize

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MARK: Layer Initialization
class Layer:
    def __init__(self, input_size, output_size, weights=None, biases=None, layer_type='input'):
        self.output_size = output_size
        self.input_size = input_size
        self.weights = np.random.randn(input_size, output_size) if weights is None else weights
        self.biases = np.zeros(output_size) if biases is None else biases
        self.layer_type = layer_type
        self.a = None
        self.z = None

    def forward(self, x):
        self.z = np.dot(x, self.weights) + self.biases
        if self.layer_type == 'input' or self.layer_type == 'hidden':
            self.a = Activations.relu(self.z)
        elif self.layer_type == 'output':
            self.a = Activations.sigmoid(self.z)

        return self.a

# MARK: Propagation
class FNN:
    def __init__(self, input_size, hidden1_size, hidden2_size, output_size, 
                 input_weights=None, input_biases=None, 
                 hidden1_weights=None, hidden1_biases=None, 
                 hidden2_weights=None, hidden2_biases=None, 
                 output_weights=None, output_biases=None):
        self.input_layer = Layer(input_size, hidden1_size, input_weights, input_biases, layer_type='input')
        self.hidden_layer1 = Layer(hidden1_size, hidden2_size, hidden1_weights, hidden1_biases, layer_type='hidden')
        self.hidden_layer2 = Layer(hidden2_size, output_size, hidden2_weights, hidden2_biases, layer_type='hidden')
        self.output_layer = Layer(output_size, 1, output_weights, output_biases, layer_type='output')

        self.pred_value = None
    
    def forward(self, row_input):
        self.input_out = row_input
        self.out1 = self.input_layer.forward(row_input)  
        self.out2 = self.hidden_layer1.forward(self.out1)    
        self.out3 = self.hidden_layer2.forward(self.out2)
        self.pred_value = self.output_layer.forward(self.out3)        
         
    def backward(self, true_value, learning_rate=0.01):
        loss = Loss(pred_value=self.pred_value, true_value=true_value)
        error = loss.mse()
        #logger.info(f"Predicted Value: {self.pred_value}, True Value: {true_value}, Error: {error}")

# ========= Output Layer =========
        out_gradient = Gradient(
            activation=self.output_layer.a,
            product=self.output_layer.z,
            weights=self.output_layer.weights, 
            biases=self.output_layer.biases, 
            next_layer_dLdz=None,
            next_layer_weights=None,
            last_out=self.out3,
            pred_value=self.pred_value, 
            true_value=true_value, 
            error=error)
        dLdz, w_out = out_gradient.adjust(learning_rate)
        self.output_layer.weights = out_gradient.weights
        self.output_layer.biases = out_gradient.biases

# ========= Hidden Layer 2 =========

        h2_gradient = Gradient(
            activation=self.hidden_layer2.a,
            product=self.hidden_layer2.z,
            next_layer_dLdz=dLdz,
            next_layer_weights=w_out,
            last_out=self.out2,
            weights=self.hidden_layer2.weights, 
            biases=self.hidden_layer2.biases, 
            pred_value=self.pred_value, 
            true_value=true_value, 
            error=error)    
        dLdz, w_h2 = h2_gradient.adjust(learning_rate)
        self.hidden_layer2.weights = h2_gradient.weights
        self.hidden_layer2.biases = h2_gradient.biases

# ========= Hidden Layer 1 =========
        h1_gradient = Gradient(
            activation=self.hidden_layer1.a,
            product=self.hidden_layer1.z,
            weights=self.hidden_layer1.weights, 
            biases=self.hidden_layer1.biases, 
            next_layer_dLdz=dLdz,
            next_layer_weights=w_h2,
            last_out=self.out1,
            pred_value=self.pred_value, 
            true_value=true_value, 
            error=error)
        dLdz, w_h1 = h1_gradient.adjust(learning_rate)
        self.hidden_layer1.weights = h1_gradient.weights
        self.hidden_layer1.biases = h1_gradient.biases
        
# ========= Input Layer ========= 

        in_gradient = Gradient(
            activation=self.input_layer.a,
            product=self.input_layer.z,
            next_layer_dLdz=dLdz,
            next_layer_weights=w_h1,
            last_out=self.input_out,
            weights=self.input_layer.weights, 
            biases=self.input_layer.biases, 
            pred_value=self.pred_value, 
            true_value=true_value, 
            error=error)
        in_gradient.adjust(learning_rate)
        self.input_layer.weights = in_gradient.weights
        self.input_layer.biases = in_gradient.biases 
    
    def predict(self, row_input):
        self.forward(row_input)

        logger.info(f"Predicted Sleep Performance: {self.pred_value[0]}")
        return self.pred_value

# MARK: Training
class TrainData:
    def __init__(self, epochs, train_frac=0.8, filename="data/Sleep_Stats(2).csv"):
        self.filename = filename
        self.epochs = epochs
        self.data = pd.read_csv(self.filename)
        self.train_size = int(len(self.data) * train_frac)
        self.Y_Max = np.max(self.data["Sleep Quality"])
        self.Y_Min = np.min(self.data["Sleep Quality"])
        
        self.normalize = Normalize(self.data)
        self.normalize.not_digit()
        #self.normalize.convert_time_columns(["Bedtime", "Wake-up Time"])
        self.normalize.adjust_outliers()
        self.data = self.normalize.data

        self.training_data = self.data[:self.train_size]
        self.features = self.training_data.drop(columns=["User ID", "Sleep Quality", "Heart Rate", "Daily Steps"])
        logger.info(f"Training Data Features: {self.features.columns.tolist()}")
        self.labels = self.training_data["Sleep Quality"].values[:self.train_size]
    
    def feed_input(self):
        input_weights = None
        input_biases = None
        hidden1_weights = None
        hidden1_biases = None
        hidden2_weights = None 
        hidden2_biases = None
        output_weights = None 
        output_biases = None
        for _ in range(self.epochs):
            for index, row in self.features.iterrows():
                label = self.labels[index]
                feed = FNN(input_size=len(row), 
                           hidden1_size=((len(row) + 1) // 2) + len(row), 
                           hidden2_size=((len(row) + 1) // 2) + len(row), 
                           output_size=1,
                           input_weights=input_weights, input_biases=input_biases,
                           hidden1_weights=hidden1_weights, hidden1_biases=hidden1_biases,
                           hidden2_weights=hidden2_weights, hidden2_biases=hidden2_biases,
                           output_weights=output_weights, output_biases=output_biases)

                feed.forward(row.values)
                feed.backward(label, learning_rate=0.01)
                input_weights = feed.input_layer.weights
                input_biases = feed.input_layer.biases

                hidden1_weights = feed.hidden_layer1.weights
                hidden1_biases = feed.hidden_layer1.biases

                hidden2_weights = feed.hidden_layer2.weights
                hidden2_biases = feed.hidden_layer2.biases

                output_weights = feed.output_layer.weights
                output_biases = feed.output_layer.biases
            
        return feed.input_layer.weights, feed.input_layer.biases, \
               feed.hidden_layer1.weights, feed.hidden_layer1.biases, \
               feed.hidden_layer2.weights, feed.hidden_layer2.biases, \
               feed.output_layer.weights, feed.output_layer.biases        

    def save_weights(self, weights, biases, filename="data/weights(no_device).npz"):
        np.savez(filename, 
                 input_weights=weights[0], input_biases=biases[0],
                 hidden1_weights=weights[1], hidden1_biases=biases[1],
                 hidden2_weights=weights[2], hidden2_biases=biases[2],
                 output_weights=weights[3], output_biases=biases[3])

# MARK: Testing
class TestData:
    def __init__(self,  test_frac=0.2, data_file="data/weights(no_device).npz", test_file="data/Sleep_Stats(2).csv"):
        self.data_file = data_file
        self.test_file = test_file

        self.weights = np.load(self.data_file)
        self.input_weights = self.weights['input_weights']
        self.input_biases = self.weights['input_biases']
        logger.info(f"Input Weights: {self.input_weights} Biases: {self.input_biases}")

        self.hidden1_weights = self.weights['hidden1_weights']
        self.hidden1_biases = self.weights['hidden1_biases']
        logger.info(f"Hidden Layer 1 Weights: {self.hidden1_weights} Biases: {self.hidden1_biases}")

        self.hidden2_weights = self.weights['hidden2_weights']
        self.hidden2_biases = self.weights['hidden2_biases']
        logger.info(f"Hidden Layer 2 Weights: {self.hidden2_weights} Biases: {self.hidden2_biases}")

        self.output_weights = self.weights['output_weights']
        self.output_biases = self.weights['output_biases']
        logger.info(f"Output Layer Weights: {self.output_weights} Biases: {self.output_biases}")

        self.test_data = pd.read_csv(self.test_file)
        self.Y_Max = np.max(self.test_data["Sleep Quality"])
        self.Y_Min = np.min(self.test_data["Sleep Quality"])
        logger.info(f"Y_Max: {self.Y_Max}, Y_Min: {self.Y_Min}")

        self.normalize = Normalize(self.test_data)
        #self.normalize.convert_time_columns(["Bedtime", "Wake-up Time"])
        self.normalize.not_digit()
        self.normalize.adjust_outliers()
        self.test_data = self.normalize.data

        self.test_size = int(len(self.test_data) * test_frac)
        self.test_features = self.test_data[self.test_size:].drop(columns=["User ID", "Sleep Quality", "Heart Rate", "Daily Steps"])
        self.test_labels = self.test_data["Sleep Quality"].values[self.test_size:]

        self.correct_outputs = 0
    
    def test_model(self):
        for i, (index, row) in enumerate(self.test_features.iterrows()):
            label = self.test_labels[i]
            feed = FNN(input_size=len(row), 
                           hidden1_size=((len(row) + 1) // 2) + len(row), 
                           hidden2_size=((len(row) + 1) // 2) + len(row), 
                           output_size=1,
                           input_weights=self.input_weights, input_biases=self.input_biases,
                           hidden1_weights=self.hidden1_weights, hidden1_biases=self.hidden1_biases,
                           hidden2_weights=self.hidden2_weights, hidden2_biases=self.hidden2_biases,
                           output_weights=self.output_weights, output_biases=self.output_biases)

            feed.forward(row.values)
            pred_value = feed.pred_value[0]
            prediction = (pred_value * (self.Y_Max - self.Y_Min)) + self.Y_Min
            true_value = (label * (self.Y_Max - self.Y_Min)) + self.Y_Min
            logger.info(f"Predicted Value: {pred_value}: Normalized: {np.round(prediction)} -> True Value: {true_value}")
            if abs(true_value - prediction) < 1:
                self.correct_outputs += 1

        accuracy = (self.correct_outputs / len(self.test_features)) * 100
        logger.info(f"Testing completed. Correct Outputs: {self.correct_outputs}, Total: {len(self.test_features)}, Accuracy: {accuracy:.2f}%")


# MARK: Main Execution
if __name__ == "__main__":
    # Create a TrainData instance
    trainer = TrainData(epochs=1000)
    logger.info("Starting training process...")

    # Train the model and get the weights and biases
    weights_and_biases = trainer.feed_input()
    logger.info("Training completed successfully.")

    # Split weights and biases for saving
    weights = weights_and_biases[::2]
    biases = weights_and_biases[1::2]

    # Save the trained weights and biases
    trainer.save_weights(weights, biases, filename="data/weights(no_device).npz")

    tester = TestData()
    logger.info("Starting testing process...")

    tester.test_model()
    logger.info("Testing completed successfully.")


