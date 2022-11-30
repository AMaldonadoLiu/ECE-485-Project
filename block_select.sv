module block_selector(tag_array, block_select, tag);
parameter integer i_size = 32;
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 8;



input [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0]tag_array;
input [i_size - 1 : c_size - a_size + d_size] tag;
output reg [$clog2(a_size) - 1 : 0] block_select;

integer i;
integer g1;
integer g2;

always @(tag_array)
begin
	for(i = 0; i < a_size; i = i + 1)
	begin
		g1 = (protocol + i_size - c_size + $clog2(a_size) - d_size) * (i + 1) - protocol;
		g2 = (protocol + i_size - c_size + $clog2(a_size) - d_size) + c_size - $clog2(a_size) + d_size;
		if(tag_array[g1 +protocol -: protocol] !== 0)
		begin
			if(tag_array[g1 -: (protocol + i_size - c_size + $clog2(a_size) - d_size)] === tag)
			begin
				$display("here: ", tag_array[g1 -: (protocol + i_size - c_size + $clog2(a_size) - d_size)]);
				block_select = i;
				break;
			end
		end
	end
end

endmodule