#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define KEY_LEN 50
#define VALUE_LEN 100

typedef struct {
    char key[KEY_LEN];
    char value[VALUE_LEN];
} DBRecord;

typedef struct {
    DBRecord *data;
    int size;
    int capacity;
} DBTable;

void initDBTable(DBTable *table) {
    table->size = 0;
    table->capacity = 10;
    table->data = (DBRecord *)malloc(table->capacity * sizeof(DBRecord));
    if (table->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeDBTable(DBTable *table) {
    free(table->data);
    table->data = NULL;
    table->size = 0;
    table->capacity = 0;
}

static void resizeIfNeeded(DBTable *table) {
    DBRecord *newData;
    if (table->size < table->capacity) {
        return;
    }
    table->capacity *= 2;
    newData = (DBRecord *)realloc(table->data, table->capacity * sizeof(DBRecord));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeDBTable(table);
        exit(1);
    }
    table->data = newData;
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

int findRecordByKey(const DBTable *table, const char *key) {
    int i;
    for (i = 0; i < table->size; i++) {
        if (strcmp(table->data[i].key, key) == 0) {
            return i;
        }
    }
    return -1;
}

int insertRecord(DBTable *table, const char *key, const char *value) {
    if (findRecordByKey(table, key) != -1) {
        return 0;
    }
    resizeIfNeeded(table);
    strncpy(table->data[table->size].key, key, KEY_LEN - 1);
    table->data[table->size].key[KEY_LEN - 1] = '\0';
    strncpy(table->data[table->size].value, value, VALUE_LEN - 1);
    table->data[table->size].value[VALUE_LEN - 1] = '\0';
    table->size++;
    return 1;
}

int updateRecord(DBTable *table, const char *key, const char *newValue) {
    int index = findRecordByKey(table, key);
    if (index == -1) {
        return 0;
    }
    strncpy(table->data[index].value, newValue, VALUE_LEN - 1);
    table->data[index].value[VALUE_LEN - 1] = '\0';
    return 1;
}

int deleteRecord(DBTable *table, const char *key) {
    int index = findRecordByKey(table, key);
    int i;
    if (index == -1) {
        return 0;
    }
    for (i = index; i < table->size - 1; i++) {
        table->data[i] = table->data[i + 1];
    }
    table->size--;
    return 1;
}

void displayRecords(const DBTable *table) {
    int i;
    if (table->size == 0) {
        printf("No records found.\n");
        return;
    }
    printf("\n--- DB Records ---\n");
    for (i = 0; i < table->size; i++) {
        printf("Key: %s | Value: %s\n", table->data[i].key, table->data[i].value);
    }
}

int main(void) {
    DBTable table;
    int choice;

    initDBTable(&table);

    while (1) {
        char key[KEY_LEN];
        char value[VALUE_LEN];
        int index;

        printf("\n===== DB Module Menu =====\n");
        printf("1. Insert Record\n");
        printf("2. Update Record\n");
        printf("3. Delete Record\n");
        printf("4. Search Record by Key\n");
        printf("5. Display All Records\n");
        printf("6. Exit\n");

        if (!readIntInput("Enter your choice: ", &choice)) {
            printf("Invalid input. Enter a valid number from 1 to 6.\n");
            continue;
        }

        if (choice == 1) {
            if (!readTextInput("Enter Key: ", key, sizeof(key)) || key[0] == '\0') {
                printf("Invalid key.\n");
                continue;
            }
            if (!readTextInput("Enter Value: ", value, sizeof(value)) || value[0] == '\0') {
                printf("Invalid value.\n");
                continue;
            }
            if (insertRecord(&table, key, value)) {
                printf("Record inserted successfully.\n");
            } else {
                printf("Insert failed: key already exists.\n");
            }
            printf("DAA Insight: Insert uses duplicate search O(n) and append O(1) amortized.\n");
        } else if (choice == 2) {
            if (!readTextInput("Enter Key to update: ", key, sizeof(key)) || key[0] == '\0') {
                printf("Invalid key.\n");
                continue;
            }
            if (!readTextInput("Enter New Value: ", value, sizeof(value)) || value[0] == '\0') {
                printf("Invalid value.\n");
                continue;
            }
            if (updateRecord(&table, key, value)) {
                printf("Record updated successfully.\n");
            } else {
                printf("Record not found.\n");
            }
            printf("DAA Insight: Update search complexity = O(n).\n");
        } else if (choice == 3) {
            if (!readTextInput("Enter Key to delete: ", key, sizeof(key)) || key[0] == '\0') {
                printf("Invalid key.\n");
                continue;
            }
            if (deleteRecord(&table, key)) {
                printf("Record deleted successfully.\n");
            } else {
                printf("Record not found.\n");
            }
            printf("DAA Insight: Delete includes search O(n) and shift O(n).\n");
        } else if (choice == 4) {
            if (!readTextInput("Enter Key to search: ", key, sizeof(key)) || key[0] == '\0') {
                printf("Invalid key.\n");
                continue;
            }
            index = findRecordByKey(&table, key);
            if (index != -1) {
                printf("Record found: Key: %s | Value: %s\n",
                       table.data[index].key,
                       table.data[index].value);
            } else {
                printf("Record not found.\n");
            }
            printf("DAA Insight: Linear search complexity = O(n).\n");
        } else if (choice == 5) {
            displayRecords(&table);
            printf("DAA Insight: Display traversal complexity = O(n).\n");
        } else if (choice == 6) {
            printf("Exiting DB module.\n");
            break;
        } else {
            printf("Invalid choice. Please try again.\n");
        }
    }

    freeDBTable(&table);
    return 0;
}
