module block_select_tb;
parameter integer i_size = 14;
parameter integer c_size = 4;
parameter integer d_size = 3;
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 4;

integer i;
integer j;
integer k;
integer l;
integer m;
integer n;
reg [c_size - d_size - $clog2(a_size) - 1: 0] tag;
reg [$clog2(a_size) - 1 : 0] correct;

reg [c_size - d_size - $clog2(a_size) - 1: 0] tag_array[a_size];
reg [$clog2(a_size) - 1 : 0] block_select;

block_selector  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) selector (tag_array, tag, block_select);



initial
begin
	for(i = 0; i < 2 ** (c_size - d_size - $clog2(a_size)); i = i + 1)
	begin
		tag = i;
		for(j = 0; j < 2 ** (c_size - d_size - $clog2(a_size)); j = j + 1)
		begin
			tag_array[0] = j;
			for(k = 0; k < 2 ** (c_size - d_size - $clog2(a_size)); k = k + 1)
			begin
				tag_array[1] = k;
				for(l = 0; l < 2 ** (c_size - d_size - $clog2(a_size)); l = l + 1) 
				begin
					tag_array[2] = l;
					for(m = 0; m < 2 ** (c_size - d_size - $clog2(a_size)); m = m + 1)
					begin
						tag_array[3] = m;
						for(n = 0; n < a_size; n = n + 1)
						begin
							if(tag_array[n] === tag)
							begin
								correct = n;
								break;
							end
						end
						
						if(block_select !== correct)
						begin
							$display("\n\nincorrect:");
							$displayh("input: ", tag_array, "\ntag: ", tag);
							$displayh("\nShould be:", correct);
						end
					end
				end
			end
		end
	end
	$display("finished");
end

endmodule	
