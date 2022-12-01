module update_LRU(block_select, LRU_bits, returned);
parameter associativity = 8;


output reg [associativity - 2 : 0]returned;

input [associativity - 2 : 0]LRU_bits;
input [$clog2(associativity) - 1 : 0]block_select;

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
		if(i == a)
		begin
			//$display("I made it here.");
			returned[i] = block_select[$clog2(associativity) - 1 - b];
			if(block_select[$clog2(associativity) - 1 - b]%2 == 0)
			begin
				a = 2 * a + 1;
			end
		
			else
			begin
				a = 2 * a + 2;
			end
			b = b + 1;
		end
			
		else
		begin
			returned[i] = LRU_bits[i];
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



 
