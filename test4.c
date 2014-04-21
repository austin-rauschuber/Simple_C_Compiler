
long fact(long n) {
	if (n==0) return 1;
	return n*fact(n - 1);
}

void main()
{
	printf(" Factorial of 5 = %d\n" , fact(5));
}


