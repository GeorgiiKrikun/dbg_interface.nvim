#include <iostream>
#include <string>
#include <vector>
#include <memory>

class Character {
protected:
    std::string name;
    int health;
public:
    Character(std::string n, int h) : name(n), health(h) {}
    virtual ~Character() = default;
    virtual void take_damage(int amount) {
        health -= amount;
        std::cout << name << " took " << amount << " damage. Health: " << health << "\n";
    }
};

class Warrior : public Character {
private:
    int armor;
public:
    Warrior(std::string n, int h, int a) : Character(n, h), armor(a) {}
    void take_damage(int amount) override {
        // Breakpoint here: Inspect 'this' to see both 'armor' and inherited 'name'/'health'
        int actual_damage = std::max(1, amount - armor);
        health -= actual_damage;
        std::cout << "Warrior " << name << " deflected damage. Took " << actual_damage << ". Health: " << health << "\n";
    }
};

int main() {
    std::vector<std::unique_ptr<Character>> party;
    party.push_back(std::make_unique<Character>("Peasant", 50));
    party.push_back(std::make_unique<Warrior>("Arthur", 100, 5));

    for (auto& member : party) {
        member->take_damage(15);
    }

    return 0;
}
