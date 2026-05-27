#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 100

typedef struct {
    int shiftId;
    char shiftName[30];
    char startTime[10];
    char endTime[10];
} Shift;

Shift shifts[MAX];
int count = 0;

/* Add Shift */
void addShift() {
    int i;
    int id;

    printf("Enter Shift ID: ");
    scanf("%d", &id);

    /* Check duplicate ID */
    for (i = 0; i < count; i++) {
        if (shifts[i].shiftId == id) {
            printf("Shift ID already exists.\n");
            return;
        }
    }

    shifts[count].shiftId = id;

    printf("Enter Shift Name: ");
    scanf(" %[^\n]", shifts[count].shiftName);

    printf("Enter Start Time: ");
    scanf("%s", shifts[count].startTime);

    printf("Enter End Time: ");
    scanf("%s", shifts[count].endTime);

    count++;

    printf("Shift added successfully.\n");
}

/* Search Shift */
void searchShift() {
    int id, i;

    printf("Enter Shift ID to search: ");
    scanf("%d", &id);

    for (i = 0; i < count; i++) {
        if (shifts[i].shiftId == id) {
            printf("\nShift Found\n");
            printf("ID: %d\n", shifts[i].shiftId);
            printf("Name: %s\n", shifts[i].shiftName);
            printf("Start Time: %s\n", shifts[i].startTime);
            printf("End Time: %s\n", shifts[i].endTime);

            printf("DAA Insight: Linear Search O(n)\n");
            return;
        }
    }

    printf("Shift not found.\n");
}

/* Display All Shifts */
void displayShifts() {
    int i;

    if (count == 0) {
        printf("No shifts available.\n");
        return;
    }

    printf("\n--- Shift List ---\n");

    for (i = 0; i < count; i++) {
        printf("ID: %d | Name: %s | Start: %s | End: %s\n",
               shifts[i].shiftId,
               shifts[i].shiftName,
               shifts[i].startTime,
               shifts[i].endTime);
    }

    printf("DAA Insight: Traversal O(n)\n");
}

int main() {
    int choice;

    while (1) {
        printf("\n===== Shift Management Menu =====\n");
        printf("1. Add Shift\n");
        printf("2. Search Shift\n");
        printf("3. Display All Shifts\n");
        printf("4. Exit\n");

        printf("Enter your choice: ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                addShift();
                break;

            case 2:
                searchShift();
                break;

            case 3:
                displayShifts();
                break;

            case 4:
                printf("Exiting Program...\n");
                exit(0);

            default:
                printf("Invalid choice.\n");
        }
    }

    return 0;
}
