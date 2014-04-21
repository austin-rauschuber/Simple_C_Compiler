
long i;

void main()
{
	for (i=0; i<15; i= i+1) {
		printf("i=%d\n", i);
		if (i<6) {
			i = i + 1;
			continue;
		}
	}
	printf("for i=%d\n", i);

	i = 0;
	while ( i<15) {
		printf("i=%d\n", i);

		if (i<8) {
			i = i + 2;
			continue;
		}
		
		i = i+1;
	}
	printf("while i=%d\n", i);
	
	i = 0;
	do {
		printf("i=%d\n", i);

		if (i<10) {
			i = i + 2;
			continue;
		}
		
		i = i+1;
	}
	while (i<15);
	
	printf("do/while i=%d\n", i);
	
	printf("OK\n");
}

