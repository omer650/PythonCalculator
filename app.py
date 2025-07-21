#!/usr/bin/env python3
"""
Flask Web Calculator Application

This Flask app provides a web interface for students to test their calculator implementations.
Students implement methods in calculator.py and can test them through the web interface.
"""

from flask import Flask, render_template, request, jsonify
from calculator import Calculator
import traceback

app = Flask(__name__)

# Global calculator instance for maintaining history
calc = Calculator()

@app.route('/')
def index():
    """Render the main calculator page."""
    return render_template('index.html')

@app.route('/calculate', methods=['POST'])
def calculate():
    """Handle calculation requests from the web interface."""
    try:
        data = request.get_json()
        operation = data.get('operation')
        num1 = data.get('num1')
        num2 = data.get('num2')
        
        # Convert string inputs to numbers
        if num1 is not None:
            try:
                num1 = float(num1) if '.' in str(num1) else int(num1)
            except ValueError:
                return jsonify({
                    'success': False,
                    'error': f'Invalid first number: {num1}'
                })
        
        if num2 is not None:
            try:
                num2 = float(num2) if '.' in str(num2) else int(num2)
            except ValueError:
                return jsonify({
                    'success': False,
                    'error': f'Invalid second number: {num2}'
                })
        
        # Perform the calculation based on operation
        result = None
        
        if operation == 'add':
            result = calc.add(num1, num2)
        elif operation == 'subtract':
            result = calc.subtract(num1, num2)
        elif operation == 'multiply':
            result = calc.multiply(num1, num2)
        elif operation == 'divide':
            result = calc.divide(num1, num2)
        elif operation == 'power':
            result = calc.power(num1, num2)
        elif operation == 'square_root':
            result = calc.square_root(num1)
        elif operation == 'factorial':
            # For factorial, ensure we have an integer
            if isinstance(num1, float) and not num1.is_integer():
                return jsonify({
                    'success': False,
                    'error': 'Factorial requires an integer'
                })
            result = calc.factorial(int(num1))
        elif operation == 'percentage':
            result = calc.percentage(num1, num2)
        else:
            return jsonify({
                'success': False,
                'error': f'Unknown operation: {operation}'
            })
        
        return jsonify({
            'success': True,
            'result': result,
            'history': calc.get_history()
        })
        
    except Exception as e:
        # Check if it's a "not implemented" error (method returns None or raises NotImplementedError)
        error_message = str(e)
        if 'pass' in error_message or not error_message or 'NoneType' in error_message:
            error_message = f"Method '{operation}' not implemented yet! Check calculator.py"
        
        return jsonify({
            'success': False,
            'error': error_message,
            'history': calc.get_history()
        })

@app.route('/history')
def get_history():
    """Get the calculation history."""
    return jsonify({
        'history': calc.get_history()
    })

@app.route('/clear', methods=['POST'])
def clear_history():
    """Clear the calculation history."""
    calc.clear_history()
    return jsonify({
        'success': True,
        'message': 'History cleared'
    })

@app.route('/health')
def health_check():
    """Simple health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'message': 'Calculator web app is running!'
    })

if __name__ == '__main__':
    print("🧮 Starting Calculator Web App...")
    print("📱 Open your browser to: http://localhost:5001")
    print("💡 Implement methods in calculator.py to make the calculator work!")
    print()
    app.run(host='0.0.0.0', port=5001, debug=True)
