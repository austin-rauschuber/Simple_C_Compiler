

void printArray( char** a, long left, long right) {
	long i;
	for (i = left; i <= right; i = i+1) {
		printf("%d: %s\n", i, a[i]);
	}
}

void print(char* s) {
	printf("==%s==\n", s);
}

long mystrcmp(char* s1, char* s2) {
	while (s1[0] && s2[0] && s1[0] == s2[0]) {
		s1 = s1 + 1;
		s2 = s2 + 1;
	}

	if (s1[0] == 0 && s2[0] == 0) {
		return 0;
	}

	if (s1[0] == 0 && s2[0] != 0) {
		return -1;
	}
	
	if (s1[0] != 0 && s2[0] == 0) {
		return 1;
	}

	if (s1[0] > s2[0]) {
		return 1;
	}

	return -1;
	
}

long quicksortsubrange(char** a, long left, long right)
{
	if (left >= right) {
		return 0;
	}

	char* x;
	x = a[right];

	long l;
	l = left;
	long g;
	g = right - 1;

	while (l<g) {

		while (l<g && mystrcmp(a[l],x)<0) {
			l = l + 1;
		}

		while (l<g && mystrcmp(a[g],x)>=0) {
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

	long n;
	n = 6;
	
	char** a;
	a = malloc(n*8);

	a[0] = "Rachael";
	a[1] = "Monica";
	a[2] = "Phoebe";
	a[3] = "Joey";
	a[4] = "Ross";
	a[5] = "Chandler";

	printf("-------- Before -------\n");
	printArray(a, 0, n - 1);
	quicksort(a, n);
	printf("-------- After -------\n");
	printArray(a, 0, n - 1);
}

