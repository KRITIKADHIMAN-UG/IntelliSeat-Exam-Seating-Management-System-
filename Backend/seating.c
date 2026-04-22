#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HALL_LEN 50

typedef struct {
    int seatNo;
    int studentRollNo;
    int examId;
    char hallName[HALL_LEN];
} Seating;

typedef struct {
    Seating *data;
    int size;
    int capacity;
} SeatingList;

void initSeatingList(SeatingList *list) {
    list->size = 0;
    list->capacity = 10;
    list->data = (Seating *)malloc(list->capacity * sizeof(Seating));
    if (list->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeSeatingList(SeatingList *list) {
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

static void resizeIfNeeded(SeatingList *list) {
    Seating *newData;
    if (list->size < list->capacity) {
        return;
    }
    list->capacity *= 2;
    newData = (Seating *)realloc(list->data, list->capacity * sizeof(Seating));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeSeatingList(list);
        exit(1);
    }
    list->data = newData;
}

static int readLineSafe(char *buffer, size_t size) {
    int ch;
    size_t len;
    if (fgets(buffer, size, stdin) == NULL) {
        return 0;
    }
    len = strlen(buffer);
    if (len > 0 && buffer[len - 1] == '\n') {
        buffer[len - 1] = '\0';
    } else {
        while ((ch = getchar()) != '\n' && ch != EOF) {
        }
    }
    return 1;
}

static int readIntInput(const char *prompt, int *value) {
    char buffer[128];
    char extra;
    printf("%s", prompt);
    if (!readLineSafe(buffer, sizeof(buffer))) {
        return 0;
    }
    if (sscanf(buffer, "%d %c", value, &extra) != 1) {
        return 0;
    }
    return 1;
}

static int readTextInput(const char *prompt, char *output, size_t size) {
    printf("%s", prompt);
    return readLineSafe(output, size);
}

int findSeatBySeatNo(const SeatingList *list, int seatNo) {
    int i;
    for (i = 0; i < list->size; i++) {
        if (list->data[i].seatNo == seatNo) {
            return i;
        }
    }
    return -1;
}

int assignSeat(SeatingList *list, int seatNo, int studentRollNo, int examId, const char *hallName) {
    if (findSeatBySeatNo(list, seatNo) != -1) {
        return 0;
    }
    resizeIfNeeded(list);
    list->data[list->size].seatNo = seatNo;
    list->data[list->size].studentRollNo = studentRollNo;
    list->data[list->size].examId = examId;
    strncpy(list->data[list->size].hallName, hallName, HALL_LEN - 1);
    list->data[list->size].hallName[HALL_LEN - 1] = '\0';
    list->size++;
    return 1;
}

void displaySeating(const SeatingList *list) {
    int i;
    if (list->size == 0) {
        printf("No seating records found.\n");
        return;
    }
    printf("\n--- Seating Plan ---\n");
    for (i = 0; i < list->size; i++) {
        printf("Seat: %d | Roll No: %d | Exam ID: %d | Hall: %s\n",
               list->data[i].seatNo,
               list->data[i].studentRollNo,
               list->data[i].examId,
               list->data[i].hallName);
    }
}

int main(void) {
    SeatingList seatingList;
    int choice;

    initSeatingList(&seatingList);

    while (1) {
        int seatNo;
        int rollNo;
        int examId;
        char hallName[HALL_LEN];

        printf("\n===== Seating Management Menu =====\n");
        printf("1. Assign Seat\n");
        printf("2. Search Seat by Seat Number\n");
        printf("3. Display Seating Plan\n");
        printf("4. Exit\n");

        if (!readIntInput("Enter your choice: ", &choice)) {
            printf("Invalid input. Enter a valid number from 1 to 4.\n");
            continue;
        }

        if (choice == 1) {
            if (!readIntInput("Enter Seat Number: ", &seatNo) || seatNo <= 0) {
                printf("Invalid seat number. Enter a positive integer.\n");
                continue;
            }
            if (!readIntInput("Enter Student Roll Number: ", &rollNo) || rollNo <= 0) {
                printf("Invalid roll number. Enter a positive integer.\n");
                continue;
            }
            if (!readIntInput("Enter Exam ID: ", &examId) || examId <= 0) {
                printf("Invalid exam ID. Enter a positive integer.\n");
                continue;
            }
            if (!readTextInput("Enter Hall Name: ", hallName, sizeof(hallName)) || hallName[0] == '\0') {
                printf("Invalid hall name.\n");
                continue;
            }

            if (assignSeat(&seatingList, seatNo, rollNo, examId, hallName)) {
                printf("Seat assigned successfully.\n");
            } else {
                printf("Seat number already assigned.\n");
            }
            printf("DAA Insight: Seat assignment uses linear duplicate check O(n), insertion O(1) amortized.\n");
        } else if (choice == 2) {
            int index;
            if (!readIntInput("Enter Seat Number to search: ", &seatNo) || seatNo <= 0) {
                printf("Invalid seat number. Enter a positive integer.\n");
                continue;
            }
            index = findSeatBySeatNo(&seatingList, seatNo);
            if (index != -1) {
                printf("Seat found: Seat %d | Roll No %d | Exam ID %d | Hall %s\n",
                       seatingList.data[index].seatNo,
                       seatingList.data[index].studentRollNo,
                       seatingList.data[index].examId,
                       seatingList.data[index].hallName);
            } else {
                printf("Seat not found.\n");
            }
            printf("DAA Insight: Linear search complexity = O(n).\n");
        } else if (choice == 3) {
            displaySeating(&seatingList);
            printf("DAA Insight: Display traversal complexity = O(n).\n");
        } else if (choice == 4) {
            printf("Exiting Seating Management module.\n");
            break;
        } else {
            printf("Invalid choice. Please try again.\n");
        }
    }

    freeSeatingList(&seatingList);
    return 0;
}
