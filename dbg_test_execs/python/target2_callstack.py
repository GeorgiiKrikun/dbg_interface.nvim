#!/usr/bin/env python3

def format_output(word):
    # Breakpoint here to check the call stack (main -> process_data -> reverse_string -> format_output)
    return f"---> {word} <---"

def reverse_string(text):
    reversed_text = text[::-1]
    return format_output(reversed_text)

def process_data(data_list):
    processed = []
    for item in data_list:
        clean_item = item.strip().lower()
        processed.append(reverse_string(clean_item))
    return processed

if __name__ == "__main__":
    raw_data = ["  Hello  ", "WORLD", "  DeBuGgEr  "]
    print("Starting data processing...")
    
    final_result = process_data(raw_data)
    
    print("Finished processing:")
    for res in final_result:
        print(res)
