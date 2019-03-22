#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <math.h>

#define SMART_INPUT(type,number,min,max)\
	while (!scanf_s(type,&number) || !number || number < (min) || number > max) rewind(stdin);\
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
		SMART_INPUT("%f", array[i], (-2147483647), 2147483648);
	}

	double result = 0;
	_asm {
		xor ecx,ecx
		mov cx,arraySize
		finit
		mov eax,array
		fld result
		start:
			fadd [eax]
			add eax,4
			cmp cx,0
			dec cx
			jnz start
		fst result


		fwait
	}
	printf("\nResult is: %.2lf\n", result);
	free(array);
	system("pause");
	return 0;

}