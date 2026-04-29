#[derive(Debug)]
enum WebEvent {
    PageLoad,
    KeyPress(char),
    Click { x: i64, y: i64 },
}

fn process_event(event: &WebEvent) {
    // Breakpoint here: Step through the match statement.
    // Inspect 'event' to see if your debugger correctly identifies which variant is active (e.g., distinguishing the Click struct fields).
    match event {
        WebEvent::PageLoad => println!("Page loaded"),
        WebEvent::KeyPress(c) => println!("Key '{}' pressed", c),
        WebEvent::Click { x, y } => println!("Clicked at x={}, y={}", x, y),
    }
}

fn main() {
    let events = vec![
        WebEvent::PageLoad,
        WebEvent::KeyPress('R'),
        WebEvent::Click { x: 250, y: 144 },
    ];

    println!("Processing events...");
    for event in &events {
        process_event(event);
    }
}
