#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>

#define SMART_INPUT(type,number,min,max) while (!scanf_s(type,&number) || !number || (min == max)?false:(number < min || number > max)) rewind(stdin);\
rewind(stdin);

int main() {
	printf("Input size of array:\n");
	short arraySize;
	do {
		SMART_INPUT("%hu",arraySize,1,10);
	} while (!arraySize);

	float* array = (float*)malloc(arraySize * sizeof(float));
	if (!array)
		return 1;
	for (int i = 0; i < arraySize; i++) {
		printf("Enter %hu element:\n",i+1);
		SMART_INPUT("%f", array[i], 0,0);
	}
	printf("array %f",array[0]);
	double result = 0;
	int i = 0;
	arraySize--;
	_asm {
		xor ecx,ecx
		mov cx,arraySize
		finit
		mov eax,array
		fld [eax]
		add eax, 4
		start:
			fadd [eax]
			add eax,4
		loop start
			fst result
		fwait
	}
	printf("\nResult is: %lf", result);
	free(array);
	system("pause");
	return 0;
}