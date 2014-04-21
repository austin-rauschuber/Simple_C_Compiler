
long g;

long compute(long a, long b) {
	long j;
	long h;
	j = g+9;
	h = (a + b)*j;
	return h;
}

void main()
{
	long j;
	g = 9;
	j = compute(2, 5);
	printf("j=%d g=%d\n", j, g);
}
