#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#define MAX_SIZE 100 
// input.txt�� �о row�� col�� �о���� �Լ�
void read_txt(int* row, int* col) {
	FILE* fp = NULL;
	fp = fopen("input.txt", "r");
	int num_element = 0;
	int* row_ptr, *col_ptr;
	row_ptr = row;
	col_ptr = col;
	
	if (fp == NULL) // ���� üũ
	{
		printf("���� ���⿡ �����߽��ϴ�\n");
		exit(1);
	}
	else printf("���� ���⿡ �����߽��ϴ�\n");

	while (1) { // �� ���� ������ ���� col�� �д´�.

		char c = fgetc(fp);

		if (c == EOF) break; // ������ ���̸� �����.

		if (c == '\n') break; // �����̸� �����.

		if (!isalnum(c)) continue; // ���ڳ� ���ĺ��� �ƴ�(����)�̸� ���� �ʴ´�.
		(*col_ptr)++;
		
	}

	rewind(fp); // ���� �����͸� �ٽ� �ʱ�ȭ ��Ų��.
	
	while (1) {
		char c = fgetc(fp);
		if (c == EOF) break;

		if (!isalnum(c)) continue; 
		num_element++; // ��ü ������ ����
	}
		
	*row_ptr = num_element / *col_ptr; // ���� �� = ��ü ���� ���� / ���� ����

	fclose(fp);
}
// stack�� ���� ����
typedef struct element {
	int x;
	int y;
} element;

// stack ����
typedef struct stack {
	element data[MAX_SIZE];
	int top;
}stack;

// stack�� �� ���ִ���
int is_full(stack* p) {
	return (p->top == MAX_SIZE - 1);
}
// stack�� ����ִ���
int is_empty(stack* p) {
	return (p->top == -1);
}
// stack�� �״� �Լ�
 void push(stack* p, element data) {
	if (is_full(p)) // �����ִ� �� üũ
	{
		printf("������ ��á���ϴ�\n"); 
		return;
	}
	else
	{
		p->top++;
		p->data[p->top].x = data.x;
		p->data[p->top].y = data.y;
	}
}

 // stack�� ���Ҹ� �����ϰ� �� �����͸� ��ȯ�ϴ� �Լ�
element pop(stack* p)
{
	if (is_empty(p)) //����ִ� �� üũ
	{
		printf("������ ����ֽ��ϴ�\n");
		exit;
	}

	return p->data[(p->top)--];
}

// �������� ã�� �Լ�
void find_here(element* here, char** m, int row, int col)
{

	for (int i = 0; i < row; i++) { // 2���� �迭 m����
		for (int j = 0; j < col; j++) {
			if (m[i][j] == 'E') { // E�� ã�Ƽ� �� ���� ��ȯ�Ѵ�.
				here->x = i;
				here->y = j;
				break;
			}
		}		
	}
}

// stack �ʱ�ȭ
void init(stack* p) {
	p->top = -1;
}

void pushLoc(stack* s, char** m, int row, int col) {
	// �������� . m �ٱ��� ���Ҹ� Ž���ϴ� ���� ����
	if (row < 0 || col < 0) return;
	// Ž���� ����� ���� �ƴϰų�, �̹� ���ٿ� ������ �ƴϸ�
	if (m[row][col] != '1' && m[row][col] != '.') {
		element tmp;
		tmp.x = row;
		tmp.y = col;
		push(s, tmp); // stack�� �� ĭ �״´�.
	}
}


void main(void){
	int row, col; // row, col
	row = 0, col = 0;

	read_txt(&row, &col); // row, col�� �޾ƿ´�.

	char** m = NULL; // �̷� m ����

	m = malloc(sizeof(char*) * row);  // row X col�� ������� 2���� �迭 ����

	for (int i = 0; i < row; i++) {
		m[i] = malloc(sizeof(char) * col);
	}
	// �ʱ�ȭ
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			m[i][j] = NULL;
		}
	}

	FILE* fp;
	int i = 0;
	int j = 0;
	// ������ �о�ͼ� �̷θ� m�� �Է��Ѵ�.
	fp = fopen("input.txt", "r");
	while (1) {
		char c = fgetc(fp);
		if (c == EOF) break; // ������ ���̸� ����
		if (!isalnum(c)) continue; // ���ڰ� �����̸� �ٽ� ����
		m[i][j] = c; // �� ���� �̷ο� �Է����ش�.
		j++;
		if (j % col == 0) { // col ���� �������� ���� row ������ �Ѿ��.
			i++;
			j = 0;
		}

	}
	fclose(fp);

	// �̷� Ž�� �� ���� ���
	fp = fopen("output.txt", "w"); // output.txt�� �д´�.
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			if (m[i][j] == '1') fputc('#', fp); // 1�� #���� ��½����ش�.

			else if (m[i][j] == '0') fputc('B', fp); // 0�� B�� ��½����ش�.
			
			else fputc(m[i][j], fp); // �� �ܴ� �״�� ��½����ش�.

		}
		fputc('\n', fp); // �������� �� ������ ���ش�.

	}
	fputc('\n', fp);

	element here; // ������ġ �޾ƿ���
	find_here(&here, m, row, col);
	printf("���� (%d, %d) -> ", here.x, here.y);

	stack s;

	init(&s); // ���� �ʱ�ȭ

	int k = 0;
	// �̷�Ž��
	while (m[here.x][here.y] != 'X') { // Ż���� ������ Ž���ϱ�
		int r = here.x;
		int c = here.y;
		m[r][c] = '.'; // Ž���� ��ġ�� �ٲ��ش�.
		// �����¿�� Ž��. 
		pushLoc(&s,m,r-1, c);
		pushLoc(&s,m,r+1, c);
		pushLoc(&s,m,r, c-1);
		pushLoc(&s,m,r, c+1);
		// ������ ��������� ���� �����ִ� -> ����
		if (is_empty(&s)) {
			printf("����\n");
			k++;
			break;
		}

		else{// pop�� ���ؼ� ���ÿ��� �ϳ��� �̾ƿ��鼭 Ž����Ų��.
			here = pop(&s);
			printf("(%d, %d) -> ", here.x, here.y);
		}
	
	}
	if (k==0) printf("����\nŽ�� ����\n");


	// Ž�� �� ��� 
	fputs("Ž�� ���\n", fp);
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {

			if (m[i][j] == '1') fputc('#', fp); // 1�� #���� ����Ѵ�.

			else if (m[i][j] == '0') fputc('B', fp); // 0�� B�� ����Ѵ�.

			
			else if (m[i][j] == '.') fputc('T', fp); // .�� T�� ����Ѵ�.

			else fputc(m[i][j], fp); // �� �ܴ� �״�� ����Ѵ�.
		}
		fputc('\n', fp); // ���� �������ش�.
	}
	fclose(fp);
	
	free(m[0]); // �Ҵ�ƴ� �޷θ��� Ǯ���ش�.
	free(m);
}