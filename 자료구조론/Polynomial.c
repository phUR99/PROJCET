#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
// ���׽��� �� ����
// input ��� : ����� ������ ����� ����, �������� ���׽� ����, ù �װ� ������ ���� �ݵ�� �ְ������� �ּ��������� ��
typedef struct term { 
	int coef; // ��� ����
	int exp; // ���� ����
	struct term* link; //���Ḯ��Ʈ�� ���� ��ũ(������ ����)
}term;
//���Ḯ��Ʈ�� ��� ����
typedef struct headpointer { 
	int length;
	term* head;
	term* tail;

}headpointer;

// �ʱ�ȭ �Լ�
void init(headpointer* plist) {
	plist->length = 0;
	plist->head = plist->tail = NULL;
}
// ����Ʈ�� �������� ��带 �߰����ִ� �Լ�
void add_node(headpointer* plist, int coef, int exp)
{
	term* temp = (term*)malloc(sizeof(term)); // �޸� �Ҵ�

	if (temp == NULL) { // ���� ������
		printf("�޸� �Ҵ� ����");
		exit;
	}

	temp->coef = coef;
	temp->exp = exp;
	temp->link = NULL;

	if (plist->tail == NULL) { // ó�� ���Խ�
		plist->head = plist->tail = temp;
	}
	else { // ����
		plist->tail->link = temp;
		plist->tail = temp;
	}
	plist->length++;

}
// �� ���Ḯ��Ʈ�� ���ϴ� �Լ�
void poly_add(headpointer* plist1, headpointer* plist2, headpointer* plist3)
{
	term* a = plist1->head;
	term* b = plist2->head;
	int sum;

	while (a && b) { // ����Ʈ�� ���� ������ ���Ͽ� ���Ѵ�
		 // ���� ��
		if (a->exp == b->exp) {
			sum = a->coef + b->coef;
			if (sum != 0)add_node(plist3, sum, a->exp);
			a = a->link; b = b->link;
		} 
		//�� ���� Ŭ ��
		else if (a->exp > b->exp) { 
			add_node(plist3, a->coef, a->exp);
			a = a->link;
		}
		else {
			add_node(plist3, b->coef, b->exp);
			b = b->link;
		}
	}
	// �� ����Ʈ�� ������ �� ���� ����Ʈ ó��
	for (; a != NULL; a = a->link) 
		add_node(plist3, a->coef, a->exp);
	for (; b != NULL; b = b->link)
		add_node(plist3, b->coef, b->exp);


}
// ���Ḯ��Ʈ�� ����ϴ� �Լ�
void poly_print(headpointer* plist, int mode) {
	term* p = plist->head; //����Ʈ�� �޾ƿ�
	FILE* fp = NULL; //���� ������ ���� 

	if (mode) // ������ ���� ����
	{
		fp = fopen("output.txt", "w"); //���� ������ �ʱ�ȭ
		fprintf(fp, "addition\n");
	}

	else {
		fp = fopen("output.txt", "a"); //���� ������ �ʱ�ȭ
		fprintf(fp, "multiplication\n");
	}	

	for (; p; p = p->link) // �����͸� ���󰡸鼭 �ϳ��� ���
		fprintf(fp, "%d   %d\n", p->coef, p->exp);

	fclose(fp); // ���� �����͸� ����

}
// �� ����Ʈ�� ���ϴ� �Լ�
void poly_multi(headpointer* plist1, headpointer* plist2, headpointer* plist3, headpointer* plist4) {


	term* p1 = plist1->head;
	term* p2 = plist2->head;


	while (p1) //p1�� ������ �� �� �ݺ����� ����
	{
		while (p2) { // p2�� ������ �� �� �ݺ����� ����
			// �� �׾� ���� ����� ���ο� ����Ʈ�� �߰�
			int coef_product = (p2->coef) * (p1->coef); 
			int exp_sum = p2->exp + p1->exp;
			add_node(plist3, coef_product, exp_sum);

			p2 = p2->link;

		}
		p1 = p1->link;

		p2 = plist2->head; //p2�� �ٽ� ��带 ����Ű�� �ʱ�ȭ
	}


	term* p3 = plist3->head;

	int n = p3->exp; // ������ ����Ʈ�� ù ��(�ְ�����)
	int n_min = plist3->tail->exp; // ������ ����Ʈ�� ������ ��(�ּ�����)
	// ���� �� ��
	for (n; n >= n_min; n--) { // �ְ������� �ּ������� ���� �� ���� ����

		int coef_sum = 0;

		while (p3) { // ����Ʈ�� ó������ ������ ����

			if (p3->exp == n) // ���� �������� �����
				coef_sum = coef_sum + p3->coef;

			p3 = p3->link;
		}

		if (coef_sum != 0) // ����� 0�� �ƴ� �� ���� �߰�
			add_node(plist4, coef_sum, n);

		p3 = plist3->head; // ����Ʈ�� ó������ �ʱ�ȭ
	}
}
//input.txt�� �д� �Լ�
void input(headpointer* plist1, headpointer* plist2) {

	FILE* fp = NULL;
	char buffer[20] = {NULL,};

	fp = fopen("input.txt", "r"); // ���� ������ �ʱ�ȭ
	int n1 = 0, n2 = 0;

	if (fp == NULL) // ���� üũ
		printf("���� ���⿡ �����߽��ϴ�\n\n");
	else
		printf("���� ���⿡ �����߽��ϴ�\n\n");
	int i = 0;
	// ���� ����
	while (fgets(buffer, sizeof(buffer), fp) != NULL) {

		if (isspace(buffer[0])) // ������ ù ���� ������ ��
		{
			break;
		}
		i++; // ������ ������ ���� ����
	}
	fp = fopen("input.txt", "r"); // ���� ������ �ʱ�ȭ
	//���� �б�
	while (EOF != fscanf(fp, "%d %d", &n1, &n2)) {

		if (i!=0) {  // ������ ������ ������
			add_node(plist1, n1, n2);
			i--;
		}
		else { // ������ ���� ��
			add_node(plist2, n1, n2);
			
		}
		
	}

	fclose(fp);
}

void main() {

	headpointer list1, list2, list3, list4, list5;

	init(&list1);
	init(&list2);
	init(&list3);
	init(&list4);
	init(&list5);
	
	input(&list1, &list2);
	poly_add(&list1, &list2, &list3);
	poly_multi(&list1, &list2, &list4, &list5);

	poly_print(&list3, 1);	
	poly_print(&list5, 0);







}