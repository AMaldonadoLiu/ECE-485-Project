module address_parse_tb;

//parameters for memory size and organization (in bits used to represent them)
//instruction size
parameter integer i_size = 16;
//capacity size
parameter integer c_size = 10;
//associativity
parameter integer a_size = 3;
//data size
parameter integer d_size = 6;

//for looping
integer i;

integer debug = 0;


//define address and individual section sizes
reg [i_size - 1 : 0]address;
wire [d_size - 1 : 0]byte_select;
wire [(c_size - a_size) - 1 : 0]index;
wire [i_size - c_size + a_size - d_size - 1 : 0]tag;

//instantiate the module using out memory and organization inputs
address_parse #(.instruction_size(i_size), .capacity(c_size), .data_lines(d_size), .associativity(a_size)) temp(address, tag, index, byte_select);

initial
begin
	if($test$plusargs ("debug"))
		debug = 1;
	//loop through all possible values
	for(i = 0; i < 2 ** (i_size); i = i + 1)
	begin
		//assign value to address
		address = i;
		//check that the values we get back from the module are correct
		if((byte_select !== address[d_size - 1 : 0] || index !== address[(c_size - a_size) + d_size - 1 : d_size] || tag !== address[i_size - (c_size - a_size) - d_size + d_size + (c_size - a_size) - 1 : d_size + (c_size - a_size)]) || debug)
		begin
			//if not, display the error information
			$display("\n\nincorrect:");
			$displayh("input: ", address, "\nbyte_select: ", byte_select, "\nindex: ", index, "\ntag: ", tag);
			$displayh("\nShould be: \nbyte_select:", address[d_size - 1 : 0], "\nindex: ", address[(c_size - a_size) + d_size - 1 : d_size], "\ntag: ", address[i_size - (c_size - a_size) - d_size + d_size + (c_size - a_size) - 1 : d_size + (c_size - a_size)]); 
		end

	end
	$display("Finished.");
end

endmodule
