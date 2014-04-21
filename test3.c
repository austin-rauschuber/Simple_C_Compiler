
long sum(long n, long* a) {
	long i, s;
	s = 0;
	for (i=0; i<n; i=i+1) {
		s = s + a[i];
	}
	return s;
}

long main()
{
	long* a;
	a = malloc(5*8);
	
	a[0]=4; a[1]=3; a[2]=1; a[3]=7; a[4]= 6;
	
	long s;
	s = sum(5, a);
	
	printf("sum=%d\n", s);
}

