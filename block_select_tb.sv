module block_select_tb;
	
//parameters
// address size
parameter integer i_size = 14;
//capacity size
parameter integer c_size = 4;
// data line size
parameter integer d_size = 3;
// protocol bits (MESI)
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 4;

//for looping
integer i;
integer j;
integer k;
integer l;
integer m;
integer n;
	
integer debug = 0;
	
reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1: 0] tag;
// to have what the output should be
reg [$clog2(a_size) - 1 : 0] correct;

reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1: 0] tag_array[a_size];
reg [$clog2(a_size) - 1 : 0] block_select;

block_selector  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) selector (tag_array, tag, block_select);



initial
begin
	if($test$plusargs ("debug")) //checking if debug was called in the terminal
		debug = 1;
	//loop through all values of the tag
	for(i = 0; i < 2 ** (c_size - d_size - $clog2(a_size)); i = i + 1)
	begin
		tag = i;
		//loop through all values of tag array 0
		for(j = 0; j < 2 ** (c_size - d_size - $clog2(a_size)); j = j + 1)
		begin
			tag_array[0] = j;
			//loop through all values of tag array 1
			for(k = 0; k < 2 ** (c_size - d_size - $clog2(a_size)); k = k + 1)
			begin
				tag_array[1] = k;
				//loop through all values of tag array 2
				for(l = 0; l < 2 ** (c_size - d_size - $clog2(a_size)); l = l + 1) 
				begin
					tag_array[2] = l;
					//loop through all values of tag array 3
					for(m = 0; m < 2 ** (c_size - d_size - $clog2(a_size)); m = m + 1)
					begin
						tag_array[3] = m;
						//loop through all values of tag array and loop for a matching tag
						for(n = 0; n < a_size; n = n + 1)
						begin
							//if we find the tag, store the index of which correct way
							if(tag_array[n] === tag)
							begin
								correct = n;
								break;
							end
						end
						#1
						
						//if we get the wrong way
						//I do understand it will hold the previous value when the tag doesn't match any of the tag_array, but we will use the hit_miss function to determine whether we use the block_select
						if(block_select !== correct)
						begin
							$display("\n\nincorrect:");
							$displayh("input: ", tag_array, "\ntag: ", tag);
							$displayh("\nShould be:", correct);
						end
						else if (debug === 1)
						begin
							$displayh("\ntag: ", tag);
							$displayh("\nShould be:", correct);
							$displayh("Output: ", block_select);
						end
					end
				end
			end
		end
	end
	$display("finished");
end

endmodule	
