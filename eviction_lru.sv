
module eviction_lru_tb;

parameter integer associativity = 8;
integer i;
integer j;
integer k;
integer a = 0;

integer debug = 0;
//size of output and inputs
reg [associativity - 2 : 0] returned;
reg [associativity - 2 : 0] LRU_bits;
reg [$clog2(associativity) - 1 : 0] block_select;
reg [$clog2(associativity) - 1 : 0] check;
reg [associativity - 2 : 0] temp = 0;

int num_wrong = 0;

eviction_lru #(.associativity(associativity)) test(block_select, LRU_bits);


initial
begin 
	if($test$plusargs ("debug")) //checking if debug was called in the terminal
		debug = 1;
		
	for(j = 0; j < 2 ** (associativity-1); j = j + 1) //next branch of LRU tree
	begin
		LRU_bits = j;
		a = 0;
		for(k = 0; k < $clog2(associativity); k = k + 1) //final branch of LRU tree (the actual block)
		begin
			check[2-k] = LRU_bits[a]; //set the check[a] to the selected block value
			if(LRU_bits[a] % 2 === 0) //if value is even
			begin
				check[2-k] = 1;
				a = 2 * a + 2; // go right
			end
			else //value must be odd
			begin
				check[2-k] = 0;
				a = 2 * a + 1; //go left
			end
		end
		//$display("Before delay: ", LRU_bits);
		#1
		//$display("After delay: ", LRU_bits);

		else if(debug === 1)
		begin
			$displayb("\nLRU bits input: ", LRU_bits);
			$displayb("LRU bits actual: ", j);
			$display("should be: ", check);
			$display("block select: ", block_select);
		end
		if(block_select ===  check || debug) //if the output value equals either the check value or debug
		begin // display the evicted value
			//$displayb("\nblock select: ", block_select);
			//$displayb("LRU bits: ", j);
			//$displayb("should be: ", check);
			//$display("Evicted: ", block_select);
		end
		else //(returned !==  check || debug) //the output value does not equal the check value or debug
		begin // display and compare the results to each other
			num_wrong++;
			$display("Incorrect");
			$displayb("\nLRU bits input: ", LRU_bits);
			$displayb("LRU bits actual: ", j);
			$display("should be: ", check);
			$display("block select: ", block_select);
		end
	end
	$display("Finished.");
end


endmodule
