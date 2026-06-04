#!/usr/bin/env python3
"""
Inspect requests Session internals without making real network calls.
Good breakpoint spots: after build_session() to inspect adapters/cookies,
and inside prepare_requests() to watch each PreparedRequest's headers and url.
"""
import requests


def build_session():
    session = requests.Session()
    session.headers.update({"X-Debug": "test", "User-Agent": "dbg-test/1.0"})
    session.cookies.set("session_id", "abc123", domain="example.com")
    session.cookies.set("theme", "dark", domain="example.com")
    return session


def prepare_requests(session):
    targets = [
        ("GET",  "https://httpbin.org/get"),
        ("POST", "https://httpbin.org/post"),
        ("GET",  "https://example.com/api/data?page=1&limit=20"),
    ]
    prepared = []
    for method, url in targets:
        req = requests.Request(method, url, headers={"Accept": "application/json"})
        # Breakpoint: inspect req before prepare
        p = session.prepare_request(req)
        # Breakpoint: inspect p.headers, p.url, p.method
        prepared.append(p)
    return prepared


if __name__ == "__main__":
    session = build_session()
    # Breakpoint: inspect session.adapters (https/http), session.headers, session.cookies
    prepared = prepare_requests(session)
    for p in prepared:
        print(f"{p.method} {p.url}")
    print("Done — no actual network calls made.")
