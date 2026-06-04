#!/usr/bin/env python3
"""
Uses the rich library to build and render a formatted table.
Good breakpoint spots: inside build_table() to inspect the Table's internal
columns/rows structures, and after process_records() to inspect the data list.
"""
import sys
from rich.console import Console
from rich.table import Table
from rich import box


def process_records(raw):
    records = []
    for entry in raw:
        records.append({
            "name":  entry["name"],
            "score": entry["score"],
            "grade": "A" if entry["score"] >= 90 else "B" if entry["score"] >= 75 else "C",
        })
    # Breakpoint: inspect records list
    return records


def build_table(records):
    table = Table(title="Student Results", box=box.ROUNDED, show_lines=True)
    table.add_column("Name",  style="cyan",    no_wrap=True)
    table.add_column("Score", style="magenta", justify="right")
    table.add_column("Grade", style="green",   justify="center")

    for rec in records:
        # Breakpoint: inspect rec, table.columns, len(table.rows)
        table.add_row(rec["name"], str(rec["score"]), rec["grade"])

    return table


if __name__ == "__main__":
    raw = [
        {"name": "Alice",   "score": 95},
        {"name": "Bob",     "score": 82},
        {"name": "Charlie", "score": 67},
        {"name": "Diana",   "score": 91},
    ]

    records = process_records(raw)
    table   = build_table(records)

    console = Console()
    # Breakpoint: inspect table internals before rendering
    console.print(table)
