
void inc(long* a) {
	a[0] = a[0]+1;
}

void
main()
{
	long a;
	a = 8;
	printf("a=%d\n", a);
	inc(&a);
	printf("a=%d\n", a);
}
