import mypkg::*;

module eviction_LRU(block_select, LRU_bits, MESI);
parameter integer a_size = 8;


input [a_size - 2 : 0]LRU_bits; // size of LRU bits
input [protocol - 1: 0] MESI[a_size];

output reg [$clog2(a_size) - 1 : 0]block_select; //size of each block (based on log_2 calculation of associativity, log_2(8))

int i = 0;
int a = 0;
int b = 0;

int count = 0;





always @(LRU_bits)
begin
	a = 0;
	b = 0;
	count = 2;

	for(i = 0; i < $clog2(a_size); i = i + 1)
	begin

		block_select[$clog2(a_size) - 1 - i] = LRU_bits[a];
		if(LRU_bits[a] === 0) //if the selected block is even
		begin
			block_select[$clog2(a_size) - 1 - i] = 1;
			a = 2 * a + 2; //go right
		end
	
		else // selected block must be odd
		begin
			block_select[$clog2(a_size) - 1 - i] = 0;
			a = 2 * a + 1; // go left
		end
			
		if(MESI[i] === 0 || MESI[i][0] === 1'bx)
		begin
			$display("MESI: ", MESI[i]);
			block_select = i;
			$display("block_select: ", block_select);
			break;
		end
		
	end


end 




endmodule
