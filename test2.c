
long h;

long compute(long a, long b, long c) {
	long d;
	d = 10;
	h = 11;
	return 2*a*a - 4*(b-c)*d - h;
}

long main()
{
	printf("compute=%d\n", compute(1, 2, 3));
}

