
char* g;

void main()
{
	char* h;
	h = malloc(20);
	h[0]=65;
	h[1]=66;
	h[2]=67;
	h[3]=0;
	printf("h=%s\n", h);

	g = malloc(20);
	g[0]=68;
	g[1]=69;
	g[2]=70;
	g[3]=0;
	printf("g=%s\n", g);

}

