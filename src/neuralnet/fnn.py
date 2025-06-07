import pandas as pd
import numpy as np
from src.neuralnet.NeuralNetFuncions import Gradient, Loss, Activations, Normalize

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
    
class FNN:
    def __init__(self, input_size, hidden1_size, hidden2_size, output_size, 
                 input_weights=None, input_biases=None, 
                 hidden1_weights=None, hidden1_biases=None, 
                 hidden2_weights=None, hidden2_biases=None, 
                 output_weights=None, output_biases=None):
        self.input_layer = Layer(input_size, output_size, input_weights, input_biases, layer_type='input')
        self.hidden_layer1 = Layer(input_size, hidden1_size, hidden1_weights, hidden1_biases, layer_type='hidden')
        self.hidden_layer2 = Layer(hidden1_size, hidden2_size, hidden2_weights, hidden2_biases, layer_type='hidden')
        self.output_layer = Layer(hidden2_size, output_size, output_weights, output_biases, layer_type='output')

        self.pred_value = None
    
    def forward(self, row_input):
        self.input_out = row_input
        self.out1 = self.input_layer.forward(row_input)  
        self.out2 = self.hidden_layer1.forward(self.out1)    
        self.out3 = self.hidden_layer2.forward(self.out2)
        self.pred_value = self.output_layer.forward(self.out3)        
    
    def backward(self, true_value, learning_rate=0.01):
        loss = Loss(self.pred_value, true_value)
        error = loss.mse()

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

class TrainData:
    def __init__(self, epochs, filename="data/Health_Sleep_Statistics.csv"):
        self.filename = filename
        self.epochs = epochs
        self.data = pd.read_csv(self.filename)
        self.data = self.data.dropna()
        self.features = self.data.drop(column=["Sleep Quality"])
        self.labels = self.data["Sleep Quality"].values
        
        self.normalize = Normalize(self.data)
        self.data = self.normalize.not_digit()
        self.data = self.normalize.adjust_outliers()
    
    def feed_input(self):
        for i in range(self.epochs):
            input_weights, input_biases, 
            hidden1_weights, hidden1_biases, 
            hidden2_weights, hidden2_biases, 
            output_weights, output_biases = None

            for index, row in self.features.iterrows():
                label = self.labels[index]
                feed = FNN(input_size=len(row), 
                           hidden1_size=15, 
                           hidden2_size=10, 
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

