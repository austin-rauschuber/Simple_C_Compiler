
long mysort(long n, long* a) {
	long i;
	long j;
	long tmp;
	for (i = n - 1; i>0; i = i - 1) {
		for (j = 0; j<i;j=j+1) {
			if (a[j]>a[j+1]) {
				tmp = a[j];
				a[j]=a[j+1];
				a[j+1]=tmp;
			}
		}
	}
}

void printArray(char* s, long n, long* a) {
	long i;
	printf("----------- %s -----------\n", s);
	for (i = 0; i < n; i = i+1) {
		printf("%d\n", a[i]);
	}
}

void main()
{
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

	printArray("Before", n, a);
	mysort( n, a);
	printArray("After", n, a);
}
