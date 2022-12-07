module address_parse(address, tag, index, byte_select);
//parameters to be changed depending on the architecture (in bits used to represent them)
parameter integer i_size = 64;
parameter integer d_size = 6;
parameter integer c_size = 14;
parameter integer a_size = 8;

//the defined size of an instruction
input [i_size - 1: 0]address;

//the size of the output section arrays
output [d_size - 1 : 0]byte_select;
output [(c_size - $clog2(a_size) - d_size) - 1 : 0]index;
output [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0]tag;

//assign different sections of the data to each output
assign byte_select = address[d_size - 1 : 0];
assign index = address[(c_size - $clog2(a_size)) + d_size - 1 : d_size];
assign tag = address[i_size - 1 : (c_size - $clog2(a_size)) + d_size];

endmodule
