import mypkg::*;

module hit_miss(tag, /*index,*/ tag_array, MESI, hit, miss, block_select);

//this uses powers of 2
parameter integer i_size = 32;
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2;

//this one is in bits
parameter integer a_size = 8;

input [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0]tag;
//input [(c_size - a_size) - 1 : 0]index;
input [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag_array[a_size];
input [protocol-1 : 0] MESI[a_size];

output reg hit;
output reg miss;
output reg [$clog2(a_size) - 1 : 0] block_select;

always @*
begin
	//#1
	/*for(int p = 0; p < a_size; p = p + 1)
	begin
		$display("MESI: ", MESI[p]);

		$display("tag_array: ",tag_array[p]);
	end*/
	//$display("Here I am.");
	for(int i = 0; i < a_size; i = i + 1)
	begin
		if(MESI[i] == 0)
		begin
			hit = 0;
			miss = 1;
			//$display(" got a miss so far: ", MESI[i]);
			block_select = i;
			break;
		end		
		else if(MESI[i] !== 0 && tag_array[i] === tag)
		begin
			hit = 1;
			miss = 0;
			block_select = i;
			break;
		end

		
		//$display("Hit: ", hit, " Miss: ", miss, " \n\n\n");
	end

	//$display("Hit: ", hit, " Miss: ", miss, " \n\n\n");

end

endmodule
	
