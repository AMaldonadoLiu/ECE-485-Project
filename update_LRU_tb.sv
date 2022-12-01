module update_LRU_tb;

parameter integer associativity = 8;
integer i;
integer j;
integer k;
integer a = 0;

integer debug = 0;

reg [associativity - 2 : 0] returned;
reg [associativity - 2 : 0] LRU_bits;
reg [$clog2(associativity) - 1 : 0] block_select;
reg [associativity - 2 : 0] check = 0;
reg [associativity - 2 : 0] temp = 0;

update_LRU #(.associativity(associativity)) test(block_select, LRU_bits, returned);


initial
begin
	if($test$plusargs ("debug"))
		debug = 1;
	for(i = 0; i < associativity; i = i + 1)
	begin
		block_select = i;
		for(j = 0; j < 2 ** (associativity-1); j = j + 1)
		begin
			LRU_bits = j;
			check = j;
			a = 0;
			for(k = 0; k < $clog2(associativity); k = k + 1)
			begin
				if(a > associativity-2)
					break;
				check[a] = block_select[$clog2(associativity) - 1 - k];
				if(check[a] % 2 === 0)
				begin
					a = 2 * a + 1;
				end

				else
				begin
					a = 2 * a + 2;
				end
			end
			//$display("Before delay: ", LRU_bits);
			#0;
			//$display("After delay: ", LRU_bits);
			if(returned !==  check || debug)
			begin
				$displayb("\nblock select: ", block_select);
				$displayb("LRU bits: ", j);
				$displayb("should be: ", check);
				$displayb("Returned: ", returned);
			end
		end
	end
	$display("Finished.");
end


endmodule

