

void printArray( long* a, long left, long right) {
	long i;
	for (i = left; i <= right; i = i+1) {
		printf("%d\n", a[i]);
	}
}

void print(char* s) {
	printf("==%s==\n", s);
}

long quicksortsubrange(long* a, long left, long right)
{
	if (left >= right) {
		return 0;
	}

	long x;
	x = a[right];

	long l;
	l = left;
	long g;
	g = right - 1;

	while (l<g) {
		while (l<g && a[l]<x) {
			l = l + 1;
		}

		while (l<g && a[g]>x) {
			g = g - 1;
		}

		if (l<g) {
			long tmp;
			tmp = a[l];
			a[l] = a[g];
			a[g]=tmp;
		}
	}

	a[right]=a[l];
	a[l]=x;

	quicksortsubrange(a, left, l - 1);
	quicksortsubrange(a,g+1, right);

}

void quicksort(long* a, long n) {
	quicksortsubrange(a, 0, n - 1);
}

void
main() {

	print("Hello");
	
	long n;
	n = 10;
	
	long* a;
	a = malloc(n*8);

	a[0] = 8;
	a[1] = 7;
	a[2] = 1;
	a[3] = 9;
	a[4] = 11;
	a[5] = 83;
	a[6] = 7;
	a[7] = 13;
	a[8] = 94;
	a[9] = 1;

	printf("-------- Before -------\n");
	printArray(a, 0, n - 1);
	quicksort(a, n);
	printf("-------- After -------\n");
	printArray(a, 0, n - 1);
}

