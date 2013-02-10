/*{-{*/

changequote(<,>)
changequote(`,´)

define(QUEUE, `/*{-{*/
    // $1 = name
    // $2 = type
    // $3 = size

C _$1_enqueue(),
  _$1_dequeue(),
  _$1_head(),
  _$1_size(),
  _$1_maxSize(),
  _$1_empty();

C do
  $2 $1_queue[$3];
  uint8_t $1_hd = 0;
  uint8_t $1_tail = 0;
  uint8_t $1_sz = 0;
  
  bool $1_empty() {
    return $1_sz == 0;
  }

  uint8_t $1_size() {
    return $1_sz;
  }

  uint8_t $1_maxSize() {
    return $3;
  }

  $2 $1_head() {
    return $1_queue[$1_hd];
  }

  void printQueue() {
#ifdef TOSSIM
    int i, j;
    for (i = $1_hd; i < $1_hd + $1_sz; i++) {
      for (j = 0; j < sizeof($2); j++) {
	uint8_t v = ((uint8_t*)&$1_queue[i % $3])[j];
      }
    }
#endif
  }
  
  $2 $1_dequeue() {
    $2 t = $1_head();
    if (!$1_empty()) {
      $1_hd++;
      if ($1_hd == $3) $1_hd = 0;
      $1_sz--;
      printQueue();
    }
    return t;
  }

  error_t $1_enqueue($2 newVal) {
    if ($1_size() < $1_maxSize()) {
      $1_queue[$1_tail] = newVal;
      $1_tail++;
      if ($1_tail == $3) $1_tail = 0;
      $1_sz++;
      printQueue();
      return SUCCESS;
    }
    else {
      return FAIL;
    }
  }
  
  $2 $1_element(uint8_t idx) {
    idx += $1_hd;
    if (idx >= $3) {
      idx -= $3;
    }
    return $1_queue[idx];
  }  

end

/*}-}*/´)

/*}-}*/dnl
