module block_selector(tag_array, tag, block_select);
//parameters for memory size and organization (in bits used to represent them)
//instruction size
parameter integer i_size = 20;
//capacity size
parameter integer c_size = 12;
//associativity (not in bits)
parameter integer a_size = 8;
//data size
parameter integer d_size = 6;


input [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag_array[a_size];
input [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag;
output reg [$clog2(a_size) - 1 : 0] block_select; //way 

integer i;


always @(*)
begin
	for(i = 0; i < a_size; i = i + 1)
	begin
		$display(tag_array[i]);
		$display(tag);
		if(tag_array[i] === tag)
		begin
			block_select = i;
			break;
		end
	end
	//$display("this is the block select: ", block_select);
end

endmodule
