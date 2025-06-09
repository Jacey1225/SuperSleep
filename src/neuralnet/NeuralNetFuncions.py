import numpy as np
import pandas as pd

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
    
class Normalize:
    def __init__(self, data):
        self.data = pd.DataFrame(data)
        self.mean = np.mean(data, axis=0)
        self.std = np.std(data, axis=0)
    
    def not_digit(self):
        self.data["Gender"].replace("Female", 0, inplace=True)
        self.data["Gender"].replace("Male", 1, inplace=True)
        
        self.data["BMI Category"].replace(["Normal", "Normal Weight"], 0, inpalce=True)
        self.data["BMI Category"].replace("Overweight", 1, inplace=True)
        self.data["BMI Category"].replace("Obese", 2, inplace=True)

        self.data["Sleep Disorder"].replace("None", 0, inplace=True)
        self.data["Sleep Disorder"].replace(["Sleep Apnea", "Insomnia"], 1, inplace=True)

    def adjust_outliers(self, out=2):
        positive_range = self.mean + (out * self.std)
        negative_range = self.mean - (out * self.std)
        outliers = self.data.columns[(self.data > positive_range or self.data < negative_range).any()]

        for outlier in outliers:
            min = np.min(self.data[outlier])
            max = np.max(self.data[outlier])
            self.data[outlier] = (self.data[outlier] - min) / (max - min)