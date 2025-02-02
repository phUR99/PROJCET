#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <ctype.h>

// ����Ʈ�� ����
typedef struct node{
	int data; // tree�� ������
	struct node* left, * right; // ����Ʈ���� �ٱ�

}node;

// ���ο� ��带 ������ִ� + �ʱ�ȭ����
node* newNode(int data)
{
	node* temp = malloc(sizeof(node)); // ���� �Ҵ�
	temp->data = data; // ������ �Ҵ�
	temp->left = temp->right = NULL; //�ٱ� �ʱ�ȭ

	return temp; // temp ������ ��ȯ
}

// ���� �Լ�
node* insertion(node* node, int data) {
	// ��带 ������ش�.
	if (node == NULL) return newNode(data);
		
		// ��Ʈ �����ϱ�
		// ������ ����, ũ�� ������
	if (data <= node->data)
		node->left = insertion(node->left, data);
	else
		node->right= insertion(node->right, data);
	
	// ��� ������ ��ȯ
	return node;
	
}
node* min_value_node(node* root)
{
	node* current = root;
	// �� ���� �ܸ� ��带 ã���� ������
	while (current->left != NULL)
		current = current->left;
	return current;
}
// ���� �Լ�
node* deletion(node* root, int data) {
	// �߰����� ������ �� ��� ������ ��ȯ
	if (root == NULL) return root;
	// Ű�� ��Ʈ���� ������ ���� ���� Ʈ���� ����
	if (data < root->data) 			
		root->left = deletion(root->left, data);
	// Ű�� ��Ʈ���� ũ�� ������ ���� Ʈ���� ����
	else if (data > root->data) 		
		root->right = deletion(root->right, data);
	// Ű�� ��Ʈ�� ������ �� ��带 ������
	else {
		// ������ ������� ��
		if (root->left == NULL) {	
			node* temp = root->right;
			free(root);
			return temp;
		}
		// �������� ������� ��
		else if (root->right == NULL) {	
			node* temp = root->left;
			free(root);
			return temp;
		}

		node* temp = min_value_node(root->right); 		
		root->data = temp->data; // ���� Ű ����
		root->right = deletion(root->right, temp->data); // ���� ��� ����
	}
	// ������ ��ȯ
	return root;
}
// Ž�� �Լ�(���� ��ȸ)
int search(node* root, int data) {
	// ã�� �����Ͱ� ���� ��
	if (root == NULL)  return NULL;
	// ã�� �����Ͱ� ���� ��
	if (data == root->data) return root;
	// ��Ʈ�� �����Ͷ� ���ؼ� �ٽ� ����
	else if (data < root->data)
		return  search(root->left, data);
	else
		return  search(root->right, data);
}
// ����Ž���Լ�
int maxDepth(struct node* node)
{
	// �ƹ��͵� ���� ��
	if (node == NULL)
		return 0;

	// ������ ����Ʈ���� ���̸� Ž���ϰ�
	else {
		int lDepth = maxDepth(node->left);
		int rDepth = maxDepth(node->right);

		// �� ū���� ����Ѵ�.
		if (lDepth > rDepth)
			return (lDepth + 1);
		else
			return (rDepth + 1);
	}
}
// ���� ��ȸ
void printCurrentLevel(struct node* root, int level, FILE* fp)
{
	// ���������
	if (root == NULL) {
		fprintf(fp, "0 " );
		// ����ִµ� ��Ʈ�� ������ 1�� �ƴϴ� => �ؿ� �� �ٱ�� ����ϱ�
		if (level != 1) {
			for (int i = 1; i < pow(2, level-1); i++)
				fprintf(fp, "0 ");
		}
		return;
	}
	// ������ 1�̸� �� ���� ����Ѵ�.
	if (level == 1)
		fprintf(fp, "%d ", root->data);
	// ������ 1���� ũ�� ������ ���ҽñ�� �ٽ� Ž���Ѵ�.
	else if (level > 1) {
		printCurrentLevel(root->left, level - 1, fp);
		printCurrentLevel(root->right, level - 1, fp);
	}
}
//���� ��ȸ
void printLevelOrder(struct node* root, int height, FILE* fp)
{
	// ���� ���� Ž���ϱ�
	int h = height;
	for (int i = 1; i <= h; i++)
		printCurrentLevel(root, i, fp);
}


// main �Լ�
void main() {
	node* root = NULL; // ��Ʈ
	FILE* fp, *wfp; // ���� ������
	char mode; // ���
	int data; // ���� ������
	fp = fopen("input.txt", "r");
	wfp = fopen("output.txt", "w");
	// ���� üũ
	if (fp == NULL) {
		printf("���� ���⸦ �����߽��ϴ�");
		exit(1);
	}
	if (wfp == NULL) {
		printf("���� ���⸦ �����߽��ϴ�");
		exit(1);
	}


	// ������ ���� �ƴϸ� ��� ����
	while (EOF != fscanf(fp, "%c%d", &mode, &data)) {
		// ��忡 �̻��� ���� ������ üũ
		if (!isalpha(mode)) continue;
		// insertion
		if (mode == 'i') {
			root = insertion(root, data);
			fprintf(wfp, "%c%d : ", mode, data);
			printLevelOrder(root, maxDepth(root), wfp);
			fprintf(wfp, "\n");


		}
		// deletion
		else if (mode == 'd') {
			fprintf(wfp, "%c%d : ", mode, data);
			// search ���� ������ �������� �ʴ´�.
			if (NULL == search(root, data)) {
				fprintf(wfp, "Not exist\n");
				continue;
			}
			root = deletion(root, data);
			printLevelOrder(root, maxDepth(root), wfp);
			fprintf(wfp, "\n");
			
			
		}

		// search
		else {
			if (NULL == search(root, data)) {
				fprintf(wfp, "%c%d : ", mode, data);
				fprintf(wfp, "Not exist\n");
			}
			else {
				fprintf(wfp, "%c%d : ", mode, data);
				fprintf(wfp, "exist\n");
			}
		}
	}

	fclose(fp);
	fclose(wfp);
	
	
}