import mypkg::*;

module cache(command, instruction, hit, miss, bus_op_out, snoop_input, snoop_result, L2_L1, silent, file);
/*This module takes in the command, tag_array, and output 
**the bus operation
**the snoop_result
**and L2_L1

*/
//this uses powers of 2
parameter integer i_size = 32; 
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2; 
parameter integer busopsize = 3;


//this one is in bits
parameter integer a_size = 8;
parameter integer max_array = a_size + (protocol + i_size - c_size + $clog2(a_size) - d_size) * a_size - 2;

input [3:0] command; // command from trace file 
input [i_size - 1 : 0] instruction;
input reg silent;
input [31:0] file;

reg debug = 0;
int out_file;

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int counter = 0;
int i=0;
int flag = 0;


reg [protocol-1:0] protocol_bits_temp;




//input common;

output reg hit;
output reg miss;
output reg [1:0] snoop_input;
output reg [protocol - 1:0] bus_op_out [busopsize]; //bus operation commands 
output reg [protocol - 1:0] snoop_result; //update snoop_result 
output reg [1:0] L2_L1[busopsize]; // this is for communication between the L1 and L2


cache_data tag_info[2 ** (c_size - $clog2(a_size)) - d_size];

reg [i_size - 1 : 0] instruction_temp;
reg [1:0] L2_L1_temp [busopsize];
reg [protocol - 1:0] bus_op_out_temp[busopsize];
reg [protocol - 1:0] snoop_result_temp;
reg miss_temp;
reg hit_temp;
reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag; //tag bits
reg [(c_size - $clog2(a_size)) - d_size - 1 : 0] index; // num of index bits
reg [d_size - 1 : 0] byte_select; //num of byte_select bits
reg [$clog2(a_size) - 1 : 0] block_select; // num of block_select (ways)
reg [$clog2(a_size) - 1 : 0] evict_block;
reg [a_size - 2 : 0] returned; // temp variable to hold data for tag_info.PLRU
reg [protocol - 1:0] temp_snoop; //this is to hold the returned snoop result from get_snoop_result
reg [protocol - 1:0] mesi_return_temp;

reg [i_size - (c_size - d_size - $clog2(a_size)) - d_size - 1 : 0] tag_temp;
reg [(c_size - $clog2(a_size)) - d_size - 1 : 0] index_temp;
reg [$clog2(a_size) - 1 : 0] block_select_temp;




address_parse #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size)) a_parse (instruction_temp, tag_temp, index_temp, byte_select);
hit_miss  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) hitmiss (tag, tag_info[index].tag, tag_info[index].protocol_bits, hit_temp, miss_temp, block_select_temp);
update_LRU #(.a_size(a_size)) uL (block_select, tag_info[index].PLRU, returned);
eviction_LRU #(.a_size(a_size)) eL (evict_block, tag_info[index].PLRU, tag_info[index].protocol_bits, miss_temp);
get_snoop_result #(.protocol(protocol)) snooping(byte_select[protocol - 1:0], temp_snoop);
MESI mesi_protocol(command, temp_snoop, protocol_bits_temp, miss_temp, snoop_result_temp, bus_op_out, L2_L1, mesi_return_temp, silent);





always @(command, instruction)
begin
		out_file = file;
		if(debug === 1)
		begin//
			//$display("Starting --------------------\n\n");
			//$display("\nTag: ", tag_info[index].tag[block_select]);
			//$display("Index: ", index);
			//$display("PLRU: ",tag_info[index].PLRU);
			//$display("Snoop result ", snoop_result);
		end

		while(instruction[0] === 1'bz)
		begin
		
			#1;
			hit = 0;
			miss = 0;
			evict_block[0] = 1'bz;
		end

		if(command == 8)
		begin
			for(int i = 0; i < 2 ** index_bits; i = i + 1)
			begin
				for(int j = 0; j < a_size; j = j + 1)
				begin
					tag_info[i].protocol_bits[j] = 2'b00;
					tag_info[i].tag[j] = 5'bxxxxx;		//this is needed because the code would remember what was previously in the memory and flag it as a false hit.
				//$display("tag prot: ", tag_info[i].protocol_bits[j]);
				end
				tag_info[i].PLRU = 1'bx;
			end
		//$display("changed bits");
		end
	/*else
	begin
		for(int i = 0; i < 2 ** index_bits; i = i + 1)
			begin
				for(int j = 0; j < a_size; j = j + 1)
				begin
					if(tag_info[i].protocol_bits[j] != 0)
					begin

						//$display("tag prot: ", tag_info[i].protocol_bits[j]);
						//$display("tag: ", tag_info[i].tag[j], "index: ", i);
					end
				end
			end
	end*/
		block_select[0] = 1'bz;
		instruction_temp[0] = 1'bz;
		tag[0] = 1'bz;
		index[0] = 1'bz;
		#2
		instruction_temp = instruction;
		#2
	
		tag = tag_temp;
		index = index_temp;
		#1
		//$display("Is this a hit? ", hit_temp);
		block_select = block_select_temp;
		while(returned[0] === 1'bx)
		begin
			#5;
			//$display("help me", miss);
			//tag = tag_temp;
			index = index_temp;
			block_select = block_select_temp;
			$displayh("\nInstruction: ", instruction);
			$display("Command: ", command);
			$display("Tag: ", tag);
			$display("index: ", index);
			$display("stuck: ", returned[0]);
			$display(block_select);
			$display("temp_snoop: ", temp_snoop);
		end

		protocol_bits_temp = tag_info[index].protocol_bits[block_select];
		
		#20;
	//tag = tag_temp;
		//$display("Evicted block: ", evict_block);
	
		if(hit_temp == 1 && (command == 0 || command == 1 || command == 2))
		begin
			//$display("GOT A HIT WOOOOHOOOOOOOOO");
			//$display("\nTAG: ", tag);
			tag_info[index].PLRU = returned;
			tag_info[index].protocol_bits[block_select] = mesi_return_temp;
			hit = hit_temp;
		end


		else if(miss_temp == 1 && (command == 0 || command == 1 || command == 2))
		begin
			//$display("\nTAG: ", tag);
			//$display("PLRU: ", returned);
			//$display("evicted: ", evict_block);
			//$display("block_select: ", block_select, "\n\n\n\n");
			miss = miss_temp;
			
			#1
			//$display("uno\n");
			#1
			
			#1
			//$display("dos\n");
			#1;
			//$display("Evict_block: ", evict_block);
			//$display("BLOCK_SELECT: ", block_select);
			if(evict_block[0] === 1'bz)
			begin
				//$display("using block select.\n");
				tag_info[index].tag[block_select] = tag;
				//$display("tres\n");
				//#1
				tag_info[index].protocol_bits[block_select] = mesi_return_temp;
				//$display("tag.tagtagtagtag: ", tag_info[index].tag[block_select]);
				tag_info[index].PLRU = returned;
				//$display("MISMISMISSS: ", miss);
			end

			else
			begin
				//$display("using evict select.\n");
				tag_info[index].tag[evict_block] = tag;
				//$display("tres\n");
				//#5
				tag_info[index].protocol_bits[evict_block] = mesi_return_temp;
				//$display("tag.tag: ", tag_info[index].tag[evict_block]);
				tag_info[index].PLRU = returned;
			end
		
		end
		#5

		//$display("I am after the miss\n\n\n");
	
		if(command != 0 && command != 1 && command != 2)
		begin
			hit = 0;
			miss = 0;
		end
	
		if(command === 3 || command === 4 || command === 5 || command === 6 || command === 7)
		begin
			#1
			snoop_result = snoop_result_temp;
			snoop_input = temp_snoop;
			//if(
		end

	

		if(command == 9)
		begin
			counter = 0;
			//$display("got here");
			for(i = 0; i < 1/*2 ** index_bits*/; i = i + 1)
			begin
			
				for(int j = 0; j < a_size; j = j + 1)
				begin
					//#1
					//$display("\n\nProtocol bits", tag_info[index].protocol_bits[j]);
					if(tag_info[i].protocol_bits[j] != 0 && tag_info[i].protocol_bits[j] !== 2'bxx)
					begin
						if(flag == 0)
						begin
							$display("\n\nINDEX: ", i);
							$display("PLRU: ", tag_info[i].PLRU);
							$fdisplay(out_file, "\n\nINDEX: ", i);
							$fdisplay(out_file,"PLRU: ", tag_info[i].PLRU);
							flag = 1;
						end
						$write("Block: ", j);
						$writeh("  MESI: ", tag_info[i].protocol_bits[j], "  Tag: ", tag_info[i].tag[j], "\n");
						$fwrite(out_file, "Block: ", j);
						$fwriteh(out_file, "  MESI: ", tag_info[i].protocol_bits[j], "  Tag: ", tag_info[i].tag[j], "\n");
						counter++;
					end
					flag = (j == a_size - 1) ? 0: flag;
				end
			end
			$display("counter: ", counter);
		end
			
	
	if(debug === 1)
	begin
		$display("\nTag: ", tag_info[index].tag[block_select]);
		$display("Index: ", index);
		$display("PLRU: ",tag_info[index].PLRU);
		$display("Snoop result ", snoop_result);
		$display("HIT/MISS:\t", hit, "/", miss);
	end
	
	/*if(silent == 0)
	begin
		for(int p = 0; p < busopsize; p = p + 1)
		begin
			if(bus_op_out_temp[p][0] === 1'bx)
			begin
				break;
			end
			else
			$display("BusOp: %d, Address: %h, Snoop Input: %d\n", bus_op_out_temp[p], instruction, temp_snoop);
			$fdisplay("BusOp: %d, Address: %h, Snoop Input: %d\n", out_file, bus_op_out_temp[p], instruction, temp_snoop);
		end
		for(int m = 0; m < busopsize; m = m + 1)
		begin
			if(L2_L1_temp[m][0] === 1'bx)
			begin
				break;
			end
			else
			$display("L2: %d %h\n", L2_L1_temp[m], instruction);
			//$fdisplay("L2: %d %h\n",out_file, L2_L1_temp[m], instruction);
		end
		
		if(snoop_result_temp[0] != 1'bx)
		begin
			$display("Snooped Address: %h, Snoop Output: %d\n", instruction, snoop_result_temp);
			//$fdisplay("Snooped Address: %h, Snoop Output: %d\n", instruction, snoop_result_temp);
		end
	end*/

			
	/*for(int g = 0; g < a_size; g = g + 1)
	begin
		$display("MESI BITS WOOO: ", tag_info[index].protocol_bits[g]);
		$display("tag at end: ", tag_info[index].tag[g]);
	end*/
	//$display("hola");
	//$display("BLOCK_SELECT: ", block_select);
	//$display("PLRU Bits: ", tag_info[index].PLRU);

	//$fclose(out_file);
end 

endmodule
