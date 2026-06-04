#!/usr/bin/env python3
"""
Verifies that the venv interpreter is active and third-party packages are importable.
Useful as a quick sanity-check when setting up the DAP config for the first time:
run it and confirm the interpreter path points inside the venv directory.
"""
import sys
import importlib.metadata


def get_interpreter_info():
    return {
        "executable": sys.executable,
        "version":    sys.version,
        "prefix":     sys.prefix,
        "in_venv":    sys.prefix != sys.base_prefix,
    }


def get_package_versions(names):
    result = {}
    for name in names:
        try:
            result[name] = importlib.metadata.version(name)
        except importlib.metadata.PackageNotFoundError:
            result[name] = "NOT INSTALLED"
    # Breakpoint: inspect result to confirm packages are from the venv
    return result


if __name__ == "__main__":
    info = get_interpreter_info()
    # Breakpoint: inspect info["executable"] — should be inside venv/bin/python
    print("=== Interpreter ===")
    for k, v in info.items():
        print(f"  {k}: {v}")

    if not info["in_venv"]:
        print("\nWARNING: not running inside a virtual environment!")
        sys.exit(1)

    packages = get_package_versions(["requests", "rich"])
    print("\n=== Venv packages ===")
    for pkg, ver in packages.items():
        print(f"  {pkg}: {ver}")
