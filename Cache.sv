module cache(command, instruction, tag_array, hit, bus_op_out, common, snoop_result, L2_L1);
/*This module takes in the command, tag_array, and output 
**the bus operation
**the snoop_result
**and L2_L1

*/
//this uses powers of 2
parameter integer i_size = 32; 
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2; 

//this one is in bits
parameter integer a_size = 8;
parameter integer max_array = a_size + (protocol + i_size - c_size + $clog2(a_size) - d_size) * a_size - 2;

input integer command; // command from trace file 
input [i_size - 1 : 0] instruction;
input [1:0] bus_op_in;

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int i=0;
inout reg [15:0]tag_array[i];
input common;

output hit;
output [1:0] bus_op_out; //bus operation commands 
output [1:0] snoop_result; //update snoop_result 
output [1:0] L2_L1; // this is for communication between the L1 and L2
int temp_index=36; //delete later




wire [i_size - c_size + $clog2(a_size) - c_size - d_size - 1 :0] tag; //tag bits
wire [(c_size - $clog2(a_size)) - d_size - 1 : 0] index; // num of index bits
wire [d_size - 1 : 0] byte_select; //num of byte_select bits
reg [$clog2(a_size) - 1 : 0] block_select; // num of block_select??
reg [max_array : max_array - a_size + 1] returned; // ??


address_parse #(.instruction_size(i_size), .data_lines(d_size), .capacity(c_size), .associativity(a_size)) a_parse (instruction, tag, index, byte_select);
//block_selector  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) selector (tag_array[index], block_select);
//update_LRU #(.a_size(a_size)) uL (block_select, tag_array[index][max_array : max_array - a_size + 1], returned);

	reg [31:0] tag_array[(c_size - $clog2(a_size)) - d_size - 1:0][a_size-1:0];
//assign tag_array[index][max_array : max_array - a_size + 1] = returned; 
//assign tag_array[index][(protocol + i_size - c_size + a_size - d_size) * (block_select + 1) - protocol : (protocol + i_size - c_size + a_size - d_size) * block_select] = 

/* initial
begin

	//#1



end */

endmodule
