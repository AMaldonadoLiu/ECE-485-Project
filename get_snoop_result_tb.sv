import mypkg::*;

module get_snoop_result_tb;

parameter integer d_size  = 6;
parameter integer protocol = 2;

reg [d_size - 1:0] byte_select;
reg [protocol - 1:0] snoop_result;
reg [protocol - 1:0] snoop_test;

int debug = 0;
int i;


get_snoop_result #(.d_size(d_size), .protocol(protocol)) test(byte_select, snoop_result);

initial
begin
	if($test$plusargs ("debug")) //checking if debug was called in the terminal
		debug = 1;
	
	for(i = 0; i < 2 ** d_size; i = i + 1)
	begin
		byte_select = i;
		if(byte_select[protocol - 1:0] === HIT)
			snoop_test = HIT;

		else if(byte_select[protocol - 1:0] === HITM)
			snoop_test = HITM;

		else
			snoop_test = NOHIT;

		#1
		if(snoop_result !== snoop_test)
		begin
			$display("Incorrect");
			$display("Input: ", byte_select);
			$display("Snoop Result: ", snoop_result);
			$display("Should be: ", snoop_test);
		end

		else if(debug === 1)
		begin
			$display("Input: ", byte_select);
			$display("Snoop Result: ", snoop_result);
			$display("Should be: ", snoop_test);
		end
	end
	
	$display("Finished");
end

endmodule
