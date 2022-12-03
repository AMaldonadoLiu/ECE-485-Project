//this file contains parameters and data structs
package mypkg;

  struct {
    int tag_info[10];
    int index_info[10];
    int bit_select[10];
    
  } cache_data;

enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands





endpackage