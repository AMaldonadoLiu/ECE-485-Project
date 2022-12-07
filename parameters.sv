//this file contains parameters and data structs
package mypkg;
`define WAYS  8
`define HIT   0
`define HITM  1
`define NOHIT 2

parameter WAY   = `WAYS;
parameter HIT   = `HIT;
parameter HITM  = `HITM;
parameter NOHIT = `NOHIT;
 bit [1:0]final_Snoop;
bit[1:0]final_final_snoop;

//using bits
parameter integer i_size = 32; //instruction size
parameter integer c_size = 24; // capacity size
parameter integer d_size = 6; // data_line size
parameter integer protocol = 2; // how many bits for protocol (MESI)
parameter integer a_size = 8; //ways

reg [i_size - 1 : 0]address;
wire [d_size - 1 : 0]byte_select;
wire [11- 1 : 0]index;
wire [15: 0]tag;
string translator;

 typedef struct {
	 reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag[a_size];
	 reg [protocol - 1: 0]protocol_bits[a_size];
	 reg [a_size-2 : 0]PLRU; //subtract 2 because - 1 for array to 0 and -1 for the equation for PLRU bits
    
  } cache_data;
int read = 0;
int write = 0;
int cacheMiss=0;
int CacheHIT=0;

int BusOp;
string snoop_text_rslt;
//int address;
//int SnoopResult;

enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands
enum{M=0,E,S,I}MESI_states;





endpackage
