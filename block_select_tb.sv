module block_select_tb;
parameter integer i_size = 14;
parameter integer c_size = 4;
parameter integer d_size = 3;
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 2;

integer i;
integer j;
reg [i_size - 1 : c_size - a_size + d_size] temp;

reg [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array;
reg [$clog2(a_size) - 1 : 0] block_select;

block_selector  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) selector (tag_array, block_select, temp);



initial
begin
	for(i = 0; i < a_size; i = i + 1)
	begin
		for(j = 0; j < 2 ** (protocol + i_size - c_size + a_size - d_size); j = j + 1)
		begin
			tag_array = 0;
			tag_array[(protocol + i_size - c_size + a_size - d_size) * (i + 1) - 1 -: (protocol + i_size - c_size + a_size - d_size)] = j;
			temp = tag_array[(protocol + i_size - c_size + a_size - d_size) * (i + 1) - protocol -: c_size - a_size + d_size];
			#1
			if(block_select !== temp && temp[(protocol + i_size - c_size + a_size - d_size) * (i + 1) - protocol -: protocol])
			begin
				$display("\n\nincorrect:");
				$displayh("input: ", tag_array, "\nblock_select: ", block_select);
				$displayh("\nShould be: \nblock_select:", temp);
			end
		end
		
	end
	$display("finished");
end

endmodule	
