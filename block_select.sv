module block_selector(tag_array, tag, block_select);
parameter integer i_size = 32;
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 8;



input [c_size - d_size - $clog2(a_size) - 1 : 0] tag_array[a_size];
input [c_size - d_size - $clog2(a_size) - 1: 0] tag;
output reg [$clog2(a_size) - 1 : 0] block_select; //way 

integer i;


always @(tag)
begin
	for(i = 0; i < a_size; i = i + 1)
	begin
		if(tag_array[i] === tag)
		begin
			block_select = i;
			break;
		end
	end
end

endmodule
