module update_LRU(block_select, LRU_bits, returned);
parameter associativity = 8;


output reg [associativity - 2 : 0]returned; //size of the output (returned value)

input [associativity - 2 : 0]LRU_bits; // size of LRU bits
input [$clog2(associativity) - 1 : 0]block_select; //size of each block (based on log_2 calculation of associativity, log_2(8))

int i = 0;
int a = 0;
int b = 0;
int enable = 0;

reg [associativity - 2 : 0]temp;
reg [associativity - 2 : 0]final_value;

//assign temp[a] = block_select[$clog2(associativity) - 1 - i];
//assign returned = temp;


always @(LRU_bits)
begin
	a = 0;
	b = 0;
	returned = 0;

	for(i = 0; i < associativity - 1; i = i + 1)
	begin
		if(i == a) // if true
		begin
			//$display("I made it here."); //the value made it to it's specific block location
			returned[i] = block_select[$clog2(associativity) - 1 - b]; //output the value from that same block location
			if(block_select[$clog2(associativity) - 1 - b]%2 == 0) //if the selected block is even
			begin
				a = 2 * a + 1; //go left
			end
		
			else //if the selected block is odd
			begin
				a = 2 * a + 2; // go right
			end
			b = b + 1; //increment (b) for so it can also go to the next block value (line 33)?
		end
			
		else //if the value is not true (line 30), 
		begin
			returned[i] = LRU_bits[i]; //output the value from that specific LRU bit, which will be a temp value
			//$display("using temp");
		end
		//$display(returned, " ", i);

		
		
	end
	//returned = temp;
	//returned = final_value;
end 

always @*
begin
	//$display("a, block select: ", a, " " , block_select[$clog2(associativity) - 1]);
	//$display("returned: " , returned);
end



endmodule
