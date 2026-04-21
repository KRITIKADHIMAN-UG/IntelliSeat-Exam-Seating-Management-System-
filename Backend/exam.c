#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define SUBJECT_LEN 100
#define DATE_LEN 11

typedef struct {
    int examId;
    char subject[SUBJECT_LEN];
    char date[DATE_LEN];   /* Format: YYYY-MM-DD */
} Exam;

typedef struct {
    Exam *data;
    int size;
    int capacity;
} ExamList;

typedef struct {
    int studentRollNo;
    int examId;
} StudentExamMap;

typedef struct {
    StudentExamMap *data;
    int size;
    int capacity;
} StudentExamMapList;

void initExamList(ExamList *list) {
    list->size = 0;
    list->capacity = 10;
    list->data = (Exam *)malloc(list->capacity * sizeof(Exam));
    if (list->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeExamList(ExamList *list) {
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

void initMapList(StudentExamMapList *list) {
    list->size = 0;
    list->capacity = 10;
    list->data = (StudentExamMap *)malloc(list->capacity * sizeof(StudentExamMap));
    if (list->data == NULL) {
        printf("Memory allocation failed.\n");
        exit(1);
    }
}

void freeMapList(StudentExamMapList *list) {
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

static void resizeExamListIfNeeded(ExamList *list) {
    Exam *newData;
    if (list->size < list->capacity) {
        return;
    }
    list->capacity *= 2;
    newData = (Exam *)realloc(list->data, list->capacity * sizeof(Exam));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeExamList(list);
        exit(1);
    }
    list->data = newData;
}

static void resizeMapListIfNeeded(StudentExamMapList *list) {
    StudentExamMap *newData;
    if (list->size < list->capacity) {
        return;
    }
    list->capacity *= 2;
    newData = (StudentExamMap *)realloc(list->data, list->capacity * sizeof(StudentExamMap));
    if (newData == NULL) {
        printf("Memory reallocation failed.\n");
        freeMapList(list);
        exit(1);
    }
    list->data = newData;
}

static void trimNewline(char *str) {
    size_t len = strlen(str);
    if (len > 0 && str[len - 1] == '\n') {
        str[len - 1] = '\0';
    }
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
        /* Flush remaining characters when input exceeds buffer size. */
        while ((ch = getchar()) != '\n' && ch != EOF) {
        }
    }
    return 1;
}

static void trimSpaces(char *str) {
    size_t start = 0;
    size_t end;
    size_t i = 0;
    size_t len = strlen(str);

    while (str[start] != '\0' && isspace((unsigned char)str[start])) {
        start++;
    }
    if (start > 0) {
        while (str[start] != '\0') {
            str[i++] = str[start++];
        }
        str[i] = '\0';
    }

    len = strlen(str);
    if (len == 0) {
        return;
    }
    end = len - 1;
    while (end > 0 && isspace((unsigned char)str[end])) {
        str[end--] = '\0';
    }
}

static int equalsIgnoreCase(const char *a, const char *b) {
    size_t i = 0;
    while (a[i] != '\0' && b[i] != '\0') {
        if (tolower((unsigned char)a[i]) != tolower((unsigned char)b[i])) {
            return 0;
        }
        i++;
    }
    return a[i] == '\0' && b[i] == '\0';
}

static int isAlphaSpaceString(const char *str) {
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

static int isValidDateFormat(const char *date) {
    int year, month, day;
    char extra;
    if (strlen(date) != 10) {
        return 0;
    }
    if (sscanf(date, "%d-%d-%d%c", &year, &month, &day, &extra) != 3) {
        return 0;
    }
    if (year < 2000 || year > 2100) {
        return 0;
    }
    if (month < 1 || month > 12) {
        return 0;
    }
    if (day < 1 || day > 31) {
        return 0;
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
    if (!readLineSafe(output, size)) {
        return 0;
    }
    return 1;
}

int findExamById(const ExamList *list, int examId) {
    int i;
    for (i = 0; i < list->size; i++) {
        if (list->data[i].examId == examId) {
            return i;
        }
    }
    return -1;
}

int addExam(ExamList *list, int examId, const char *subject, const char *date) {
    if (findExamById(list, examId) != -1) {
        return 0;
    }
    resizeExamListIfNeeded(list);
    list->data[list->size].examId = examId;
    strncpy(list->data[list->size].subject, subject, SUBJECT_LEN - 1);
    list->data[list->size].subject[SUBJECT_LEN - 1] = '\0';
    strncpy(list->data[list->size].date, date, DATE_LEN - 1);
    list->data[list->size].date[DATE_LEN - 1] = '\0';
    list->size++;
    return 1;
}

int mapStudentToExam(StudentExamMapList *mapList, int studentRollNo, int examId) {
    int i;
    for (i = 0; i < mapList->size; i++) {
        if (mapList->data[i].studentRollNo == studentRollNo &&
            mapList->data[i].examId == examId) {
            return 0;
        }
    }
    resizeMapListIfNeeded(mapList);
    mapList->data[mapList->size].studentRollNo = studentRollNo;
    mapList->data[mapList->size].examId = examId;
    mapList->size++;
    return 1;
}

/* qsort comparator -> sort by date */
static int compareExamsByDate(const void *a, const void *b) {
    const Exam *examA = (const Exam *)a;
    const Exam *examB = (const Exam *)b;
    return strcmp(examA->date, examB->date);
}

void sortExamsByDate(ExamList *list) {
    if (list->size <= 1) {
        return;
    }
    qsort(list->data, list->size, sizeof(Exam), compareExamsByDate);
}

void displayExams(const ExamList *list) {
    int i;
    if (list->size == 0) {
        printf("No exams available.\n");
        return;
    }
    printf("\n--- Exam List ---\n");
    for (i = 0; i < list->size; i++) {
        printf("Exam ID: %d | Subject: %s | Date: %s\n",
               list->data[i].examId,
               list->data[i].subject,
               list->data[i].date);
    }
}

void displayMappings(const StudentExamMapList *mapList, const ExamList *examList) {
    int i;
    if (mapList->size == 0) {
        printf("No student-exam mappings available.\n");
        return;
    }
    printf("\n--- Student to Exam Mapping ---\n");
    for (i = 0; i < mapList->size; i++) {
        int idx = findExamById(examList, mapList->data[i].examId);
        if (idx != -1) {
            printf("Roll No: %d -> Exam ID: %d (%s, %s)\n",
                   mapList->data[i].studentRollNo,
                   mapList->data[i].examId,
                   examList->data[idx].subject,
                   examList->data[idx].date);
        } else {
            printf("Roll No: %d -> Exam ID: %d (Exam details not found)\n",
                   mapList->data[i].studentRollNo,
                   mapList->data[i].examId);
        }
    }
}

int main(void) {
    ExamList exams;
    StudentExamMapList mappings;
    int choice;

    initExamList(&exams);
    initMapList(&mappings);

    while (1) {
        int examId;
        int rollNo;
        char subject[SUBJECT_LEN];
        char date[DATE_LEN];

        printf("\n===== Exam Management Menu =====\n");
        printf("1. Add Exam\n");
        printf("2. Map Student to Exam\n");
        printf("3. Sort Exams by Date\n");
        printf("4. Display Exams\n");
        printf("5. Display Student-Exam Mapping\n");
        printf("6. Exit\n");

        if (!readIntInput("Enter your choice: ", &choice)) {
            printf("Invalid input. Enter a valid number from 1 to 6.\n");
            continue;
        }

        if (choice == 1) {
            if (!readIntInput("Enter Exam ID: ", &examId) || examId <= 0) {
                printf("Invalid Exam ID. Enter a positive integer.\n");
                continue;
            }
            if (!readTextInput("Enter Subject: ", subject, sizeof(subject)) ||
                !isAlphaSpaceString(subject)) {
                printf("Invalid subject. Use letters and spaces only.\n");
                continue;
            }
            if (!readTextInput("Enter Date (YYYY-MM-DD): ", date, sizeof(date)) ||
                !isValidDateFormat(date)) {
                printf("Invalid date. Use YYYY-MM-DD format.\n");
                continue;
            }

            if (addExam(&exams, examId, subject, date)) {
                printf("Exam added successfully.\n");
            } else {
                printf("Exam ID already exists.\n");
            }
        } else if (choice == 2) {
            if (!readIntInput("Enter Student Roll No: ", &rollNo) || rollNo <= 0) {
                printf("Invalid roll number. Enter a positive integer.\n");
                continue;
            }
            if (!readIntInput("Enter Exam ID: ", &examId) || examId <= 0) {
                printf("Invalid Exam ID. Enter a positive integer.\n");
                continue;
            }
            if (findExamById(&exams, examId) == -1) {
                printf("Cannot map: Exam ID not found.\n");
                continue;
            }
            if (mapStudentToExam(&mappings, rollNo, examId)) {
                printf("Student mapped to exam successfully.\n");
            } else {
                printf("Mapping already exists.\n");
            }
            printf("DAA Insight: Mapping insertion in list is O(1) amortized after duplicate check O(n).\n");
        } else if (choice == 3) {
            sortExamsByDate(&exams);
            printf("Exams sorted by date.\n");
            printf("DAA Insight: Sorting uses qsort with average time complexity O(n log n).\n");
        } else if (choice == 4) {
            displayExams(&exams);
        } else if (choice == 5) {
            displayMappings(&mappings, &exams);
            printf("DAA Insight: Display mapping traversal time complexity O(n).\n");
        } else if (choice == 6) {
            printf("Exiting Exam Management module.\n");
            break;
        } else {
            printf("Invalid choice. Please try again.\n");
        }
    }

    freeExamList(&exams);
    freeMapList(&mappings);
    return 0;
}
