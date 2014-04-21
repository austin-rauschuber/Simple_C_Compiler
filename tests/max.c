
long max(long* a, long n)
{
	long i;
	long m;

	m = a[0];
	for (i=0; i<n; i=i+1) {
		if (m<a[i]) {
			m = a[i];
		}
	}

	return m;
}
long* a;
long n;
long i;

void main()
{
	n=10;
	a  = malloc(10*8);
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
	for (i = 0; i < n; i = i + 1) {
		printf("%d: %d\n", i, a[i]);
	}

	printf("n=%d\n", n);
	printf("max=%d\n", max(a,n));
	
}
