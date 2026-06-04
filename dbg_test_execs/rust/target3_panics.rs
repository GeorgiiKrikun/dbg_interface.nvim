use std::fs::File;
use std::io::Read;

fn read_file_contents(path: &str) -> Result<String, std::io::Error> {
    // Breakpoint here: Step over to see the Err value generated when the file isn't found.
    let mut file = File::open(path)?; 
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn risky_operation(trigger_panic: bool) {
    if trigger_panic {
        // Breakpoint here: Configure your debugger to catch panics/exceptions.
        panic!("Deliberate crash triggered!");
    }
    println!("Operation succeeded.");
}

fn main() {
    println!("Testing Result handling...");
    match read_file_contents("non_existent_file.txt") {
        Ok(_) => println!("File read successfully."),
        Err(e) => {
            // Breakpoint here to inspect the standard std::io::Error struct.
            println!("Caught expected error: {}", e);
        }
    }

    println!("Testing Panics...");
    risky_operation(true);
    
    println!("This line will never be reached.");
}
