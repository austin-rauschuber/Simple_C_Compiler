long* queens;
long solid;

long abs(long v) {
  if (v < 0)
        return (-1)*v;
  return v;
}

long check(long depth) {
  long i;
  for (i=0; i<depth; i=i+1) {
    if ( (queens[i] == queens[depth]) ||
         (abs(queens[i]-queens[depth]) == (depth-i)) ) {
      return 0;
    }
  }

  return 1;
}

long bruteforce(long depth) {
  if (depth==8) {
    long i;
    printf("Solution #%2ld = [ ", solid);
    solid=solid+1;
    for (i=0; i<8; i=i+1) {
      printf("%ld ", queens[i]+1);
    }
    printf("]\n");
    return 0;
  }

  long i;

  for (i=0; i<8; i=i+1) {
    queens[depth] = i;
    if (check(depth) != 0) {
      bruteforce(depth+1);
    }
  }

  return 0;
}

void main() {
  queens = malloc(8*8);
  solid = 1;
  bruteforce(0);
}


