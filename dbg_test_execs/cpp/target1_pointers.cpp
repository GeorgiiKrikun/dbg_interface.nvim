#include <iostream>

struct Node {
    int value;
    Node* next;
    Node(int val) : value(val), next(nullptr) {}
};

void traverse_list(Node* head) {
    Node* current = head;
    int index = 0;
    while (current != nullptr) {
        // Breakpoint here: Watch 'current' pointer address change and inspect 'current->value'
        std::cout << "Node " << index << " value: " << current->value << "\n";
        current = current->next;
        index++;
    }
}

int main() {
    std::cout << "Building linked list...\n";
    
    Node* head = new Node(10);
    head->next = new Node(20);
    head->next->next = new Node(30);
    head->next->next->next = new Node(40);

    traverse_list(head);

    // Cleanup
    Node* current = head;
    while (current != nullptr) {
        Node* next = current->next;
        delete current;
        current = next;
    }

    return 0;
}
