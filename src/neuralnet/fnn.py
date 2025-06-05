import pandas as pd
import numpy as np
from src.neuralnet.NeuralNetFuncions import Variables, Gradient, Loss, Activations

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
    def __init__(self, input_size, hidden1_size, hidden2_size, output_size):
        self.input_layer = Layer(input_size, output_size, layer_type='input')
        self.hidden_layer1 = Layer(input_size, hidden1_size, layer_type='hidden')
        self.hidden_layer2 = Layer(hidden1_size, hidden2_size, layer_type='hidden')
        self.output_layer = Layer(hidden2_size, output_size, layer_type='output')

        self.pred_value = None
    
    def forward(self, row_input):
        self.input_out = row_input
        self.out1 = self.input_layer.forward(row_input)  
        self.out2 = self.hidden_layer1.forward(self.out1)    
        self.out3 = self.hidden_layer2.forward(self.out2)
        self.pred_value = self.output_layer.forward(self.out3)

        return self.pred_value
        
    
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

        