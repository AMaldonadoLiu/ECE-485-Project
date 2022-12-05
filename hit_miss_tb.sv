module hit_miss_tb;

//this uses powers of 2
parameter integer i_size = 16;
parameter integer c_size = 10;
parameter integer d_size = 4;
parameter integer protocol = 1;

//this one is in bits
parameter integer a_size = 4;

reg [i_size - c_size + a_size - d_size - 1 : 0]tag;
//reg [(c_size - a_size) - 1 : 0]index;
reg [i_size - c_size + a_size - d_size - 1: 0] tag_array[a_size];
reg MESI[a_size];

integer debug = 0;

reg hit;
reg miss; 

hit_miss #(.i_size(i_size), .c_size(c_size), .d_size(d_size), .protocol(protocol), .a_size(a_size)) inst (tag, /*index,*/ tag_array, MESI, hit, miss);

initial
begin
	if($test$plusargs ("debug"))
	begin
		$display("Debug mode.\n");
		debug = 1;
	end
	for(int i = 0; i < i_size - c_size + a_size - d_size; i = i + 1)
	begin
		tag = i;
		for(int j1 = 0; j1 < i_size - c_size + a_size - d_size + 2; j1 = j1 + 1)
		begin
			{tag_array[0], MESI[0]} = j1;
			
			for(int j2 = 0; j2 < i_size - c_size + a_size - d_size + 2; j2 = j2 + 1)
			begin
				{tag_array[1], MESI[1]} = j2;
				for(int j3 = 0; j3 < i_size - c_size + a_size - d_size + 2; j3 = j3 + 1)
				begin
					{tag_array[2], MESI[2]} = j3;
					for(int j3 = 0; j3 < i_size - c_size + a_size - d_size + 2; j3 = j3 + 1)
					begin
						{tag_array[3], MESI[3]} = j3;
						#5
						if(((MESI[0] !== 1 || MESI[1] !== 1 ) || tag_array[0] !== tag_array[1]) && ((MESI[0] !== 1 || MESI[2] !== 1 ) || tag_array[0] !== tag_array[2]) && ((MESI[0] !== 1 || MESI[3] !== 1 ) || tag_array[0] !== tag_array[3]) && ((MESI[1] !== 1 || MESI[2] !== 1 ) || tag_array[1] !== tag_array[2]) && ((MESI[1] !== 1 || MESI[3] !== 1 ) || tag_array[1] !== tag_array[3]) && ((MESI[2] !== 1 || MESI[3] !== 1 ) || tag_array[2] !== tag_array[3]))
						begin
							if(({tag,1'b1} === {tag_array[0],MESI[0]} || {tag,1'b1} === {tag_array[1],MESI[1]} || {tag,1'b1} === {tag_array[2],MESI[2]} || {tag,1'b1} === {tag_array[3],MESI[3]}) && hit !== 1)
							begin
								$display("Incorrect.");
								$display("Sent: ", tag_array[0], " ", MESI[0], ", ", tag_array[1]," ", MESI[1],  ", ", tag_array[2]," ", MESI[2],  ", ", tag_array[3]," ", MESI[3]);
								$display("no hit for tag: ", tag, "\n");
								$display("Hit: ", hit, " Miss: ", miss);
							end
							
							else if(({tag,1'b1} !== {tag_array[0],MESI[0]} && {tag,1'b1} !== {tag_array[1],MESI[1]} && {tag,1'b1} !== {tag_array[2],MESI[2]} && {tag,1'b1} !== {tag_array[3],MESI[3]}) && miss !== 1)
							begin
								$display("Incorrect.");
								$display("Sent: ", tag_array[0], " ", MESI[0], ", ", tag_array[1]," ", MESI[1],  ", ", tag_array[2]," ", MESI[2],  ", ", tag_array[3]," ", MESI[3]);
								$display("no miss for tag: ", tag, "\n");
								$display("Hit: ", hit, " Miss: ", miss);
							end
							
							else if(debug === 1)
							begin
								$display("Correct.\n");
							end
						end
					end
				end
			end
		end
	end
	$display("FINISHED.");
end
endmodule
							
						