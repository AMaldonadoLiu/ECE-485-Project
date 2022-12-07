module address_parse(address, tag, index, byte_select);
//parameters to be changed depending on the architecture (in bits used to represent them)
parameter integer instruction_size = 64;
parameter integer data_lines = 6;
parameter integer capacity = 14;
parameter integer associativity = 3;

//the defined size of an instruction
input [instruction_size - 1: 0]address;

//the size of the output section arrays
output [data_lines - 1 : 0]byte_select;
output [(c_size - $clog2(a_size)) - d_size - 1 : 0]index;
output [instruction_size - data_lines - capacity + associativity - 1 : 0]tag;

//assign different sections of the data to each output
assign byte_select = address[data_lines - 1 : 0];
assign index = address[(capacity - associativity) + data_lines - 1 : data_lines];
assign tag = address[instruction_size - 1 : (capacity - associativity) + data_lines];

endmodule
