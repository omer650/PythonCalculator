"""
Simple Calculator Class - Student Implementation Required

Students need to implement all the methods below.
"""


class Calculator:
    def __init__(self):
        self.history = []

    def add(self, a, b):
        """Add two numbers"""
        # TODO: Implement addition
        # Hint: result = a + b, then add to history
        return a + b

    def subtract(self, a, b):
        """Subtract b from a"""
        return a -b

    def multiply(self, a, b):
        return a * b

    def divide(self, a, b):
        # TODO: Implement division
        return a / b
    
    def get_history(self):     
        """Return calculation history"""
        return self.history

    def clear_history(self):
        """Clear calculation history"""
        self.history = []
