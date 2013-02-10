/*{-{*/

changequote(<,>)
changequote(`,´)

define(POOL, `/*{-{*/
    // $1 = name
    // $2 = type
    // $3 = size

C _$1_init(), _$1_empty(), _$1_size(), _$1_maxSize(), _$1_get(), _$1_put();

C do
  uint8_t $1_free;
  uint8_t $1_index;
  $2* $1_queue[$3];
  $2 $1_pool[$3];

  error_t $1_init() {
    int i;
    for (i = 0; i < $3; i++) {
      $1_queue[i] = &$1_pool[i];
    }
    $1_free = $3;
    $1_index = 0;
    return SUCCESS;
  }
  
  bool $1_empty() {
    return $1_free == 0;
  }
  uint8_t $1_size() {
    return $1_free;
  }
    
  uint8_t $1_maxSize() {
    return $3;
  }

  $2* $1_get() {
    if ($1_free) {
      $2* rval = $1_queue[$1_index];
      $1_queue[$1_index] = NULL;
      $1_free--;
      $1_index++;
      if ($1_index == $3) {
        $1_index = 0;
      }
      return rval;
    }
    return NULL;
  }

  error_t $1_put($2* newVal) {
    if ($1_free >= $3) {
      return FAIL;
    }
    else {
      uint16_t emptyIndex = ($1_index + $1_free);
      if (emptyIndex >= $3) {
        emptyIndex -= $3;
      }
      $1_queue[emptyIndex] = newVal;
      $1_free++;
      return SUCCESS;
    }
  }
end
/*}-}*/´)

/*}-}*/dnl
