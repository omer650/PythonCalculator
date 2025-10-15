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
        # TODO: Implement subtraction
        pass

    def multiply(self, a, b):
        """Multiply two numbers"""
        # TODO: Implement multiplication
        pass

    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        result = a / b
        self.history.append(f"{a} ÷ {b} = {result}")
        return result

    def get_history(self):
        """Return calculation history"""
        return self.history

    def clear_history(self):
        """Clear calculation history"""
        self.history = []
