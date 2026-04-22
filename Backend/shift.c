#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define SHIFT_LEN 40
#define TIME_LEN 6

typedef struct {
    int shiftId;
    char shiftName[SHIFT_LEN];
    char startTime[TIME_LEN];
    char endTime[TIME_LEN];
} Shift;

typedef struct {
    Shift *data;
    int size;
    int capacity;
} ShiftList;

void initShiftList(ShiftList *list) {
    list->size = 0;
    list->capacity = 10;
    list->data = (Shift *)malloc(list->capacity * sizeof(Shift));
    if (list->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeShiftList(ShiftList *list) {
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

static void resizeIfNeeded(ShiftList *list) {
    Shift *newData;
    if (list->size < list->capacity) {
        return;
    }
    list->capacity *= 2;
    newData = (Shift *)realloc(list->data, list->capacity * sizeof(Shift));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeShiftList(list);
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

static int isValidTime(const char *timeStr) {
    int hh;
    int mm;
    char extra;
    if (strlen(timeStr) != 5) {
        return 0;
    }
    if (sscanf(timeStr, "%d:%d%c", &hh, &mm, &extra) != 2) {
        return 0;
    }
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59) {
        return 0;
    }
    return 1;
}

int findShiftById(const ShiftList *list, int shiftId) {
    int i;
    for (i = 0; i < list->size; i++) {
        if (list->data[i].shiftId == shiftId) {
            return i;
        }
    }
    return -1;
}

int addShift(ShiftList *list, int shiftId, const char *shiftName, const char *startTime, const char *endTime) {
    if (findShiftById(list, shiftId) != -1) {
        return 0;
    }
    resizeIfNeeded(list);
    list->data[list->size].shiftId = shiftId;
    strncpy(list->data[list->size].shiftName, shiftName, SHIFT_LEN - 1);
    list->data[list->size].shiftName[SHIFT_LEN - 1] = '\0';
    strncpy(list->data[list->size].startTime, startTime, TIME_LEN - 1);
    list->data[list->size].startTime[TIME_LEN - 1] = '\0';
    strncpy(list->data[list->size].endTime, endTime, TIME_LEN - 1);
    list->data[list->size].endTime[TIME_LEN - 1] = '\0';
    list->size++;
    return 1;
}

void displayShifts(const ShiftList *list) {
    int i;
    if (list->size == 0) {
        printf("No shifts available.\n");
        return;
    }
    printf("\n--- Shift List ---\n");
    for (i = 0; i < list->size; i++) {
        printf("Shift ID: %d | Name: %s | Start: %s | End: %s\n",
               list->data[i].shiftId,
               list->data[i].shiftName,
               list->data[i].startTime,
               list->data[i].endTime);
    }
}

int main(void) {
    ShiftList shifts;
    int choice;

    initShiftList(&shifts);

    while (1) {
        int shiftId;
        char shiftName[SHIFT_LEN];
        char startTime[TIME_LEN];
        char endTime[TIME_LEN];

        printf("\n===== Shift Management Menu =====\n");
        printf("1. Add Shift\n");
        printf("2. Search Shift by ID\n");
        printf("3. Display All Shifts\n");
        printf("4. Exit\n");

        if (!readIntInput("Enter your choice: ", &choice)) {
            printf("Invalid input. Enter a valid number from 1 to 4.\n");
            continue;
        }

        if (choice == 1) {
            if (!readIntInput("Enter Shift ID: ", &shiftId) || shiftId <= 0) {
                printf("Invalid Shift ID. Enter a positive integer.\n");
                continue;
            }
            if (!readTextInput("Enter Shift Name: ", shiftName, sizeof(shiftName)) || shiftName[0] == '\0') {
                printf("Invalid shift name.\n");
                continue;
            }
            if (!readTextInput("Enter Start Time (HH:MM): ", startTime, sizeof(startTime)) ||
                !isValidTime(startTime)) {
                printf("Invalid start time. Use HH:MM in 24-hour format.\n");
                continue;
            }
            if (!readTextInput("Enter End Time (HH:MM): ", endTime, sizeof(endTime)) ||
                !isValidTime(endTime)) {
                printf("Invalid end time. Use HH:MM in 24-hour format.\n");
                continue;
            }

            if (addShift(&shifts, shiftId, shiftName, startTime, endTime)) {
                printf("Shift added successfully.\n");
            } else {
                printf("Shift ID already exists.\n");
            }
            printf("DAA Insight: Duplicate check with linear search O(n), insertion O(1) amortized.\n");
        } else if (choice == 2) {
            int index;
            if (!readIntInput("Enter Shift ID to search: ", &shiftId) || shiftId <= 0) {
                printf("Invalid Shift ID. Enter a positive integer.\n");
                continue;
            }
            index = findShiftById(&shifts, shiftId);
            if (index != -1) {
                printf("Shift found: ID %d | %s | %s - %s\n",
                       shifts.data[index].shiftId,
                       shifts.data[index].shiftName,
                       shifts.data[index].startTime,
                       shifts.data[index].endTime);
            } else {
                printf("Shift not found.\n");
            }
            printf("DAA Insight: Search time complexity = O(n).\n");
        } else if (choice == 3) {
            displayShifts(&shifts);
            printf("DAA Insight: Traversal complexity = O(n).\n");
        } else if (choice == 4) {
            printf("Exiting Shift Management module.\n");
            break;
        } else {
            printf("Invalid choice. Please try again.\n");
        }
    }

    freeShiftList(&shifts);
    return 0;
}
