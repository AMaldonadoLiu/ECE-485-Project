import mypkg::*;

module cache_tb;

/*This module takes in the command, tag_array, and output 
**the bus operation
**the snoop_result
**and L2_L1

*/
//this uses powers of 2
/*parameter integer i_size = 32; 
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2; 

//this one is in bits
parameter integer a_size = 8;*/
parameter integer max_array = a_size + (protocol + i_size - c_size + $clog2(a_size) - d_size) * a_size - 2;

integer command; // command from trace file 
reg [i_size - 1 : 0] instruction;

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int i=0;
reg common;

reg hit;
reg miss;
reg [1:0] bus_op_out; //bus operation commands 
reg [1:0] snoop_result; //update snoop_result 
reg [1:0] L2_L1; // this is for communication between the L1 and L2
int temp_index=36; //delete later





wire [i_size - c_size + $clog2(a_size) - d_size - 1 :0] tag; //tag bits
wire [(c_size - $clog2(a_size)) - d_size - 1 : 0] index; // num of index bits
wire [d_size - 1 : 0] byte_select; //num of byte_select bits
reg [$clog2(a_size) - 1 : 0] block_select; // num of block_select (ways)
reg [max_array : max_array - a_size + 1] returned;

cache testing(0, 5000, hit, miss, bus_op_out, 0, snoop_result, L2_L1);

endmodule
