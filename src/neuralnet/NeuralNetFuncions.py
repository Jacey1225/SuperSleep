import numpy as np

class Variables:  
    def __init__(self, activation, product, next_layer_dLdz=None, next_layer_weights=None, last_out=None, 
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

        dLdw = dLdz.reshape(-1, 1) * self.last_out.reshape(1, -1)
        dLdb = dLdz

        self.weights -= learning_rate * dLdw
        self.biases -= learning_rate * dLdb
        
        return dLdz, self.weights

class Loss(Variables):
    def mse(self):
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