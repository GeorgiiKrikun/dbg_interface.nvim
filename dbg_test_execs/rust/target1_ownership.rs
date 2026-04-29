fn take_ownership(s: String) {
    // Breakpoint here: 's' is valid and owned here. 
    // If you look at the caller's frame, the original variable should be marked as moved or inaccessible.
    println!("I own: {}", s);
}

fn borrow_data(v: &Vec<i32>) {
    // Breakpoint here: inspect 'v'. Your debugger should ideally show it as a pointer/reference to a slice or heap array.
    println!("Borrowed vector of length: {}", v.len());
}

fn main() {
    let my_string = String::from("Hello Debugger");
    let mut my_vec = vec![1, 2, 3];

    borrow_data(&my_vec);

    my_vec.push(4);
    
    // Breakpoint here: inspect 'my_string' before it moves into the function.
    println!("About to move the string...");
    take_ownership(my_string);

    // my_string is now invalid. my_vec is [1, 2, 3, 4]
    println!("Finished ownership tests. Vector length is: {}", my_vec.len());
}
