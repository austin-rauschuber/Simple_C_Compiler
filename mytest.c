long* a;
void main(){

	long b;
	a = malloc(8*2);
	a[1] = 2;
	b = 1+ a[1];
	printf("%d\n",b);
}
