module eviction_lru(block_select, LRU_bits);
parameter associativity = 8; //this is the number of ways for each index


input [associativity - 2 : 0]LRU_bits; // size of LRU bits
output reg [$clog2(associativity) - 1 : 0]block_select; //size of each block (based on log_2 calculation of associativity, log_2(8))

int i = 0; //for assigning each bit of the block_select
int a = 0; //for the index of the LRU_bits array




always @(LRU_bits)
begin
	a = 0;
	b = 0;
	count = 2;

	for(i = 0; i < $clog2(associativity); i = i + 1)
	begin

		block_select[$clog2(associativity) - 1 - i] = LRU_bits[a];
		if(LRU_bits[a] == 1) //if the selected block is even
		begin
			a = 2 * a + 2; //go right
		end
	
		else // selected block must be odd
		begin
			a = 2 * a + 1; // go left
		end
			
		
	end

end 




endmodule
