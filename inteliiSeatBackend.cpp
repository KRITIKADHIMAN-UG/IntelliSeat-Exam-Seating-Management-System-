#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <map>
#include <queue>
using namespace std;

// ----------------- Student Structure -----------------
// Stores student details
struct Student {
    string rollNumber;
    string firstName;
    string lastName;
    string branch;
    vector<string> subjects; // Subjects student is enrolled in
};

// ----------------- Exam Structure -----------------
// Stores exam details
struct Exam {
    string subject;
    string hallType; // LT/CR
};

// ----------------- Hall Class -----------------
// Stores hall details and manages seating
class Hall {
public:
    string name;
    string type;
    int rows, cols;
    vector<vector<string>> seating; // 2D seating arrangement

    Hall(string n, string t, int r, int c) : name(n), type(t), rows(r), cols(c) {
        // Initialize all seats as EMPTY
        seating.assign(rows, vector<string>(cols, "EMPTY"));
    }

    // Function to assign seat to a student using row-wise allocation
    bool assignSeat(const string &rollNumber) {
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (seating[i][j] == "EMPTY") {
                    seating[i][j] = rollNumber;
                    return true;
                }
            }
        }
        return false; // Hall full
    }

    // Display hall seating
    void display() const {
        cout << "\nSeating Arrangement for Hall " << name << " (" << type << "):\n";
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                cout << setw(12) << seating[i][j] << " |";
            }
            cout << endl;
        }
    }

    int getCapacity() const { return rows * cols; }
};

// ----------------- Seating Management -----------------
class SeatingArrangement {
public:
    vector<Hall> halls; // List of all halls

    // Function to add hall details
    void addHall(Hall hall) {
        halls.push_back(hall);
    }

    // Function to generate seating for given exam and students
    void generateSeating(vector<Student> &students, Exam &exam) {
        // Filter students who have this subject
        vector<Student> eligibleStudents;
        for (auto &s : students) {
            for (auto &sub : s.subjects) {
                if (sub == exam.subject) {
                    eligibleStudents.push_back(s);
                    break;
                }
            }
        }

        // Using a queue for round-robin allocation across halls of the same type
        queue<int> hallQueue;
        for (int i = 0; i < halls.size(); i++) {
            if (halls[i].type == exam.hallType)
                hallQueue.push(i);
        }

        if (hallQueue.empty()) {
            cout << "No halls available for this exam type!\n";
            return;
        }

        // Assign students one by one to halls in queue
        for (auto &student : eligibleStudents) {
            bool seated = false;
            int attempts = hallQueue.size(); // Max halls to try
            while (!seated && attempts--) {
                int hallIndex = hallQueue.front();
                hallQueue.pop();
                // Try assigning seat in current hall
                if (halls[hallIndex].assignSeat(student.rollNumber)) {
                    seated = true;
                }
                hallQueue.push(hallIndex); // Move to back for round-robin
            }

            if (!seated) {
                cout << "Warning: No available seat for student " << student.rollNumber << endl;
            }
        }

        // Display all halls of this type
        for (auto &hall : halls) {
            if (hall.type == exam.hallType)
                hall.display();
        }
    }
};

// ----------------- Main Function -----------------
int main() {
    vector<Student> students;
    int n;

    // ----------------- Input Students -----------------
    cout << "Enter number of students: ";
    cin >> n;
    cin.ignore();

    for (int i = 0; i < n; i++) {
        Student s;
        cout << "\n--- Enter details for Student " << i + 1 << " ---\n";
        cout << "Roll Number: ";
        getline(cin, s.rollNumber);
        cout << "First Name: ";
        getline(cin, s.firstName);
        cout << "Last Name: ";
        getline(cin, s.lastName);
        cout << "Branch: ";
        getline(cin, s.branch);
        cout << "Subjects (comma separated, e.g., Maths,Physics): ";
        string line;
        getline(cin, line);

        // Split subjects by comma
        size_t pos = 0;
        while ((pos = line.find(',')) != string::npos) {
            string sub = line.substr(0, pos);
            s.subjects.push_back(sub);
            line.erase(0, pos + 1);
        }
        if (!line.empty())
            s.subjects.push_back(line);

        students.push_back(s);
    }

    // ----------------- Input Halls -----------------
    SeatingArrangement seating;
    int hallCount;
    cout << "\nEnter number of halls: ";
    cin >> hallCount;
    cin.ignore();

    for (int i = 0; i < hallCount; i++) {
        string name, type;
        int rows, cols;
        cout << "\n--- Enter details for Hall " << i + 1 << " ---\n";
        cout << "Hall Name: ";
        getline(cin, name);
        cout << "Hall Type (LT/CR): ";
        getline(cin, type);
        cout << "Number of Rows: ";
        cin >> rows;
        cout << "Number of Columns: ";
        cin >> cols;
        cin.ignore();

        seating.addHall(Hall(name, type, rows, cols));
    }

    // ----------------- Input Exam -----------------
    Exam exam;
    cout << "\nEnter exam subject: ";
    getline(cin, exam.subject);
    cout << "Enter hall type for exam (LT/CR): ";
    getline(cin, exam.hallType);

    // ----------------- Generate Seating -----------------
    seating.generateSeating(students, exam);

    return 0;
}