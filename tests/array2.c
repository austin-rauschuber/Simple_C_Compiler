
void main()
{
	
	long* a;
	long i;

	a = malloc(8*20);

	for (i = 0; i < 20; i=i+1) {
		a[i]= 3*i;
	}

	printf("Ok so far\n");
	     
	for (i = 0; i < 20; i=i+1) {
		printf("%d: %d\n", i, a[i]);
	}
	
}
  
