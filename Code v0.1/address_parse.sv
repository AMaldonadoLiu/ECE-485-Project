import mypkg::*;

module address_parse(address, tag, index, byte_select);
//parameters to be changed depending on the architecture (in bits used to represent them)
parameter integer i_size = 64;
parameter integer d_size = 6;
parameter integer c_size = 14;
parameter integer a_size = 8;

//the defined size of an instruction
input [i_size - 1: 0]address;

//the size of the output section arrays
output reg [d_size - 1 : 0]byte_select;
output reg [index_bits - 1 : 0]index;
output reg [tag_bits - 1 : 0]tag;

//assign different sections of the data to each output
//assign byte_select = address[d_size - 1 : 0];
//assign index = address[(c_size - $clog2(a_size) - d_size ) + d_size - 1 : d_size];
//assign tag = address[i_size - 1 : (c_size - $clog2(a_size)) + d_size];

always @(address)
begin
	byte_select = address[d_size - 1 : 0];
	index = address[index_bits + d_size - 1 : d_size];
	tag = address[i_size - 1 : index_bits + d_size]; 

	$displayb("byte_select: ", byte_select);
	$displayb("a_index: ", index);
	$displayb("a_tag: ", tag);
end

endmodule
