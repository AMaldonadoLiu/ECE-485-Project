import mypkg::*;

module cache(command, instruction, hit, miss, bus_op_out, snoop_result, L2_L1, debug);
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

//this one is in bits
parameter integer a_size = 8;
parameter integer max_array = a_size + (protocol + i_size - c_size + $clog2(a_size) - d_size) * a_size - 2;

input [3:0] command; // command from trace file 
input [i_size - 1 : 0] instruction;
input reg debug;

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int i=0;
int flag = 0;






//input common;

output reg hit;
output reg miss;
output reg [protocol - 1:0] bus_op_out; //bus operation commands 
output reg [protocol - 1:0] snoop_result; //update snoop_result 
output reg [1:0] L2_L1; // this is for communication between the L1 and L2


cache_data tag_info[2 ** (c_size - $clog2(a_size)) - d_size];


reg [1:0] L2_L1_temp;
reg [protocol - 1:0] bus_op_out_temp;
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




address_parse #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size)) a_parse (instruction, tag_temp, index_temp, byte_select);
hit_miss  #(.i_size(i_size), .d_size(d_size), .c_size(c_size), .a_size(a_size), .protocol(protocol)) hitmiss (tag, tag_info[index].tag, tag_info[index].protocol_bits, hit_temp, miss_temp, block_select);
update_LRU #(.a_size(a_size)) uL (block_select, tag_info[index].PLRU, returned);
eviction_LRU #(.a_size(a_size)) eL (evict_block, tag_info[index].PLRU, tag_info[index].protocol_bits);
get_snoop_result #(.protocol(protocol)) snooping(byte_select[protocol - 1:0], temp_snoop);
MESI mesi_protocol(command, temp_snoop, tag_info[index].protocol_bits[evict_block], miss_temp, snoop_result_temp, bus_op_out, L2_L1_temp, mesi_return_temp);





always @(command, instruction)
begin

	if(command == 8)
	begin
		for(int i = 0; i < 2 ** index_bits; i = i + 1)
		begin
			for(int j = 0; j < a_size; j = j + 1)
			begin
				tag_info[i].protocol_bits[j] = 0;
				//$display("tag prot: ", tag_info[i].protocol_bits[j]);
			end
		end
		$display("changed bits");
	end
	#1
	tag = tag_temp;
	index = index_temp;

	while(returned[0] === 1'bx)
	begin
		#1;
		//$display(miss);
		$display("stuck: ", returned[0]);
		$display(block_select);
		$display(index);
	end
		
	#20;
	
	if(hit_temp == 1 && (command == 0 || command == 1 || command == 2))
	begin
		$display("GOT A HIT WOOOOHOOOOOOOOO");
		tag_info[index].PLRU = returned;
		tag_info[index].protocol_bits[block_select] = mesi_return_temp;
		hit = hit_temp;
	end


	else if(miss_temp == 1 && (command == 0 || command == 1 || command == 2))
	begin
		$display("TAG: ", tag);
		$display("PLRU: ", returned);
		$display("evicted: ", evict_block);
		$display("block_select: ", block_select);
		tag_info[index].PLRU = returned;
		#1
		tag_info[index].tag[block_select] = tag;
		tag_info[index].protocol_bits[block_select] = mesi_return_temp;
		miss = miss_temp;
		
	end
	#1
	
	if(command != 0 && command != 1 && command != 2)
	begin
		hit = 0;
		miss = 0;
	end
	
	if(command === 3 || command === 4 || command === 5 || command === 6 || command === 7)
	begin
		#1
		snoop_result = snoop_result_temp;
		//if(
	end

	

	if(command == 9)
	begin
		$display("got here");
		for(i = 0; i < 2 ** index_bits; i = i + 1)
		begin
			
			for(int j = 0; j < a_size; j = j + 1)
			begin
				#1
				//$display("\n\nProtocol bits", tag_info[index].protocol_bits[j]);
				if(tag_info[index].protocol_bits[j] != 0 || tag_info[index].protocol_bits[j] != 2'bxx)
				begin
					if(flag == 0)
					begin
						$display("\n\nINDEX: \t", i);
						$display("PLRU: \t", tag_info[index].PLRU);
						flag = 1;
					end
					$write("Block: ", j);
					$writeh("\tMESI: ", tag_info[index].protocol_bits[j], "\tTag: ", tag_info[index].tag[j], "\n");
				end
				flag = (j = a_size - 1) ? 0: flag;
			end
		end
	end
			

	if(debug == 1)
	begin
		$display("Tag: ", tag_info[index].tag[block_select]);
		$display("Index: ", index);
		$display("PLRU: ",tag_info[index].PLRU);
		$display("Snoop result ", snoop_result);
	end

			



end 

endmodule
