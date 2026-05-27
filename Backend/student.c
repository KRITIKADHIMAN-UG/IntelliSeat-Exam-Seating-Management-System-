#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define NAME_LEN 100
#define BRANCH_LEN 50

typedef struct {
    int rollNo;
    char name[NAME_LEN];
    char branch[BRANCH_LEN];
} Student;

typedef struct {
    Student *data;
    int size;
    int capacity;
} StudentList;

void initStudentList(StudentList *list) {
    list->size = 0;
    list->capacity = 10;
    list->data = (Student *)malloc(list->capacity * sizeof(Student));

    if (list->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeStudentList(StudentList *list) {
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

static void resizeIfNeeded(StudentList *list) {
    if (list->size < list->capacity) {
        return;
    }

    list->capacity *= 2;
    Student *newData = (Student *)realloc(list->data, list->capacity * sizeof(Student));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeStudentList(list);
        exit(1);
    }
    list->data = newData;
}

int findStudentByRoll(const StudentList *list, int rollNo) {
    int i;
    for (i = 0; i < list->size; i++) {
        if (list->data[i].rollNo == rollNo) {
            return i;
        }
    }
    return -1;
}

int findStudentByName(const StudentList *list, const char *name) {
    int i;
    for (i = 0; i < list->size; i++) {
        if (strcmp(list->data[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int findStudentByRollWithComparisons(const StudentList *list, int rollNo, int *comparisons) {
    int i;
    *comparisons = 0;
    for (i = 0; i < list->size; i++) {
        (*comparisons)++;
        if (list->data[i].rollNo == rollNo) {
            return i;
        }
    }
    return -1;
}

int findStudentByNameWithComparisons(const StudentList *list, const char *name, int *comparisons) {
    int i;
    *comparisons = 0;
    for (i = 0; i < list->size; i++) {
        (*comparisons)++;
        if (strcmp(list->data[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int insertStudent(StudentList *list, int rollNo, const char *name, const char *branch) {
    if (findStudentByRoll(list, rollNo) != -1) {
        return 0;
    }

    resizeIfNeeded(list);

    list->data[list->size].rollNo = rollNo;
    strncpy(list->data[list->size].name, name, NAME_LEN - 1);
    list->data[list->size].name[NAME_LEN - 1] = '\0';
    strncpy(list->data[list->size].branch, branch, BRANCH_LEN - 1);
    list->data[list->size].branch[BRANCH_LEN - 1] = '\0';
    list->size++;

    return 1;
}

int deleteStudentByRoll(StudentList *list, int rollNo) {
    int index = findStudentByRoll(list, rollNo);
    int i;

    if (index == -1) {
        return 0;
    }

    for (i = index; i < list->size - 1; i++) {
        list->data[i] = list->data[i + 1];
    }
    list->size--;
    return 1;
}

void displayStudents(const StudentList *list) {
    int i;
    if (list->size == 0) {
        printf("No students found.\n");
        return;
    }

    printf("\n--- Student List ---\n");
    for (i = 0; i < list->size; i++) {
        printf("Roll No: %d | Name: %s | Branch: %s\n",
               list->data[i].rollNo,
               list->data[i].name,
               list->data[i].branch);
    }
}

static void trimNewline(char *str) {
    size_t len = strlen(str);
    if (len > 0 && str[len - 1] == '\n') {
        str[len - 1] = '\0';
    }
}

static int isValidNameOrBranch(const char *str) {
    size_t i;
    if (str == NULL || str[0] == '\0') {
        return 0;
    }

    for (i = 0; str[i] != '\0'; i++) {
        if (!(isalpha((unsigned char)str[i]) || str[i] == ' ')) {
            return 0;
        }
    }
    return 1;
}

static int readIntInput(const char *prompt, int *value) {
    char buffer[128];
    char extra;

    printf("%s", prompt);
    if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
        return 0;
    }

    if (sscanf(buffer, "%d %c", value, &extra) != 1) {
        return 0;
    }
    return 1;
}

static int readValidatedTextInput(const char *prompt, char *output, size_t size) {
    printf("%s", prompt);
    if (fgets(output, size, stdin) == NULL) {
        return 0;
    }
    trimNewline(output);
    return isValidNameOrBranch(output);
}

int main(void) {
    StudentList students;
    int choice;

    initStudentList(&students);

    while (1) {
        int rollNo;
        int index;
        int comparisons;
        char name[NAME_LEN];
        char branch[BRANCH_LEN];

        printf("\n===== Student Management Menu =====\n");
        printf("1. Insert Student\n");
        printf("2. Delete Student by Roll Number\n");
        printf("3. Search Student by Roll Number (Linear Search)\n");
        printf("4. Search Student by Name (Linear Search)\n");
        printf("5. Display All Students\n");
        printf("6. Exit\n");
        if (!readIntInput("Enter your choice: ", &choice)) {
            printf("Invalid input. Enter a valid number from 1 to 6.\n");
            continue;
        }

        if (choice == 1) {
            if (!readIntInput("Enter Roll Number: ", &rollNo) || rollNo <= 0) {
                printf("Invalid roll number. Enter a positive integer only.\n");
                continue;
            }
            if (!readValidatedTextInput("Enter Name: ", name, sizeof(name))) {
                printf("Invalid name. Use letters and spaces only.\n");
                continue;
            }
            if (!readValidatedTextInput("Enter Branch: ", branch, sizeof(branch))) {
                printf("Invalid branch. Use letters and spaces only.\n");
                continue;
            }

            if (insertStudent(&students, rollNo, name, branch)) {
                printf("Student inserted successfully.\n");
            } else {
                printf("Insertion failed: Roll number already exists.\n");
            }
        } else if (choice == 2) {
            if (!readIntInput("Enter Roll Number to delete: ", &rollNo) || rollNo <= 0) {
                printf("Invalid roll number. Enter a positive integer only.\n");
                continue;
            }

            if (deleteStudentByRoll(&students, rollNo)) {
                printf("Student deleted successfully.\n");
            } else {
                printf("Student not found.\n");
            }
        } else if (choice == 3) {
            if (!readIntInput("Enter Roll Number to search: ", &rollNo) || rollNo <= 0) {
                printf("Invalid roll number. Enter a positive integer only.\n");
                continue;
            }

            index = findStudentByRollWithComparisons(&students, rollNo, &comparisons);
            if (index != -1) {
                printf("Student found: Roll No: %d | Name: %s | Branch: %s\n",
                       students.data[index].rollNo,
                       students.data[index].name,
                       students.data[index].branch);
            } else {
                printf("Student not found.\n");
            }
            printf("DAA Insight: Linear Search comparisons = %d, Time Complexity = O(n)\n", comparisons);
        } else if (choice == 4) {
            if (!readValidatedTextInput("Enter Name to search: ", name, sizeof(name))) {
                printf("Invalid name. Use letters and spaces only.\n");
                continue;
            }

            index = findStudentByNameWithComparisons(&students, name, &comparisons);
            if (index != -1) {
                printf("Student found: Roll No: %d | Name: %s | Branch: %s\n",
                       students.data[index].rollNo,
                       students.data[index].name,
                       students.data[index].branch);
            } else {
                printf("Student not found.\n");
            }
            printf("DAA Insight: Linear Search comparisons = %d, Time Complexity = O(n)\n", comparisons);
        } else if (choice == 5) {
            displayStudents(&students);
            printf("DAA Insight: Display traversal Time Complexity = O(n)\n");
        } else if (choice == 6) {
            printf("Exiting Student Management module.\n");
            break;
        } else {
            printf("Invalid choice. Please try again.\n");
        }
    }

    freeStudentList(&students);
    return 0;
}
