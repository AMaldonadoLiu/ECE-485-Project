module hit_miss(tag, /*index,*/ tag_array, MESI, hit, miss);

//this uses powers of 2
parameter integer i_size = 32; //instruction size
parameter integer c_size = 24; // cache capacity
parameter integer d_size = 6; //number of bit for byte_select
parameter integer protocol = 2; // this is the number of bits required for the protocol
	

//this one is in bits
parameter integer a_size = 8;
/* substracting the c_size + the a_size and the d_size from i_size to get
the bits for the tag_array*/
input [i_size - c_size + a_size - d_size - 1 : 0]tag; //in our case tag_array should be 15 bits
//input [(c_size - a_size) - 1 : 0]index;
input [i_size - c_size + a_size - d_size - 1: 0] tag_array[a_size];
input [protocol-1 : 0] MESI[a_size];

output reg hit;
output reg miss;

always @*
begin

	for(int i = 0; i < a_size; i = i + 1)
	begin 
		if(tag_array[i] === tag && MESI[i] !== 0) // check if we have tag in cache while checking we're not in invalidate state
		begin
			hit = 1;
			miss = 0;
			break;
		end
		else
		begin
			hit = 0;
			miss = 1;
		end
	end

end

endmodule
	
