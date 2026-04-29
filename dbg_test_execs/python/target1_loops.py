#!/usr/bin/env python3
import sys

def calculate_fibonacci(limit):
    print(f"Calculating Fibonacci sequence up to {limit} terms...")
    sequence = []
    a, b = 0, 1
    
    for i in range(limit):
        # A good place to set a breakpoint to watch 'a', 'b', and 'sequence'
        sequence.append(a)
        next_value = a + b
        a = b
        b = next_value
        
    return sequence

if __name__ == "__main__":
    terms = 10
    if len(sys.argv) > 1:
        terms = int(sys.argv[1])
        
    result = calculate_fibonacci(terms)
    print(f"Result: {result}")
