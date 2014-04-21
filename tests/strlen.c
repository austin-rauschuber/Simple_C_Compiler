
long mystrlen(char* s) {
	long l;
	l = 0;

	while(s[l]) {
		l = l+1;
	}

	return l;
}

void mystrcpy(char* s1, char* s2) {
        while(s2[0]) {
		s1[0]=s2[0];
		s1 = s1 + 1;
		s2 = s2 + 1;
	}
	s1[0] = 0;
}

char* g;

void main()
{
	char* h;
	h = malloc(30);
	mystrcpy(h, "Hello world");
	printf("h=%s\n", h);
	printf("l=%d\n", mystrlen(h));

	g = malloc(30);
	strcpy(g, "This is a great course");
	printf("g=%s\n", g);
	printf("l=%d\n", mystrlen(g));

	
}
