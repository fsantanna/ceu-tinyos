/*{-{*/

C _Random_init(), _Random_rand32(), _Random_rand16();

C do
  uint32_t Random_seed ;

  error_t Random_init(uint16_t s) {
    Random_seed = (uint32_t)(s + 1);
    return SUCCESS;
  }

  uint32_t Random_rand32() {
    uint32_t mlcg,p,q;
    uint64_t tmpseed;
	tmpseed =  (uint64_t)33614U * (uint64_t)Random_seed;
	q = tmpseed; 	/* low */
	q = q >> 1;
	p = tmpseed >> 32 ;		/* hi */
	mlcg = p + q;
        if (mlcg & 0x80000000) { 
	  mlcg = mlcg & 0x7FFFFFFF;
	  mlcg++;
	}
	Random_seed = mlcg;
    return mlcg; 
  }

  uint16_t Random_rand16() {
    return (uint16_t)Random_rand32();
  }
end

/*}-}*/dnl
