import mypkg::*;

module cache(command, instruction, hit, miss, bus_op_out, common, snoop_result, L2_L1);
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

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int i=0;
input common;

output hit;
output miss;
output [1:0] bus_op_out; //bus operation commands 
output [1:0] snoop_result; //update snoop_result 
output [1:0] L2_L1; // this is for communication between the L1 and L2
int temp_index=36; //delete later

cache_data tag_info[2 ** (c_size - $clog2(a_size)) - d_size];




reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag; //tag bits
wire [(c_size - $clog2(a_size)) - d_size - 1 : 0] index; // num of index bits
wire [d_size - 1 : 0] byte_select; //num of byte_select bits
reg [$clog2(a_size) - 1 : 0] block_select; // num of block_select (ways)
reg [a_size - 2 : 0] returned; // temp variable to hold data for tag_info.PLRU


address_parse #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size)) a_parse (instruction, tag, index, byte_select);
block_selector  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) selector (tag_info[index].tag, tag, block_select);
update_LRU #(.a_size(a_size)) uL (block_select, tag_info[index].PLRU, returned);

//assign tag_array[index][max_array : max_array - a_size + 1] = returned; 
//assign tag_array[index][(protocol + i_size - c_size + a_size - d_size) * (block_select + 1) - protocol : (protocol + i_size - c_size + a_size - d_size) * block_select] = 

always @*
begin
	tag_info[index].PLRU = 5;
	tag_info[index].tag[0] = 5;
	tag = 5;
	while(returned[0] === 1'bx)
	begin
		#1
		$display("stuck: ", returned[0]);
		$display(block_select);
		$display(index);
	end
	
	tag_info[index].PLRU = returned;
	$display("we did it! ",tag_info[index].PLRU);

			



end 

endmodule
