#!/usr/bin/env python3

def risky_division(x, y):
    print(f"Attempting to divide {x} by {y}")
    # If y is 0, this will throw a ZeroDivisionError
    return x / y

def read_config():
    # This will throw a FileNotFoundError
    with open("non_existent_config_file.json", "r") as f:
        return f.read()

if __name__ == "__main__":
    print("Running exception tests...")
    
    # Test 1: Handled Exception
    try:
        result = risky_division(10, 0)
    except ZeroDivisionError as e:
        print(f"Caught an expected error: {e}")
        
    # Test 2: Unhandled Exception
    print("About to read config...")
    # Setting a breakpoint here allows you to step into the crash
    config = read_config() 
    print("This line will never execute.")
