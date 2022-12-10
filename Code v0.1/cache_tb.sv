import mypkg::*;

module cache_tb;

/*This module takes in the command, tag_array, and output 
**the bus operation
**the snoop_result
**and L2_L1

*/
//this uses powers of 2
/*parameter integer i_size = 32; 
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2; 

//this one is in bits
parameter integer a_size = 8;*/
parameter integer max_array = a_size + (protocol + i_size - c_size + $clog2(a_size) - d_size) * a_size - 2;

reg [3:0] command; // command from trace file 
//reg [i_size - 1 : 0] instruction;

// inout [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];
int i=0;
reg common;

reg hit;
reg miss;
reg [1:0] bus_op_out; //bus operation commands 
reg [1:0] snoop_result; //update snoop_result 
reg [1:0] L2_L1; // this is for communication between the L1 and L2

reg [i_size - 1:0] read_address;


integer data_file;
integer valid_data;
integer debug;
integer data_command;

integer hit_rate = 0;
integer miss_rate = 0;
integer num_read = 0;
integer num_write = 0;
integer silent = 0;

string retrieved_file;





//wire [i_size - c_size + $clog2(a_size) - d_size - 1 :0] tag; //tag bits
//wire [(c_size - $clog2(a_size)) - d_size - 1 : 0] index; // num of index bits
//wire [d_size - 1 : 0] byte_select; //num of byte_select bits
//reg [$clog2(a_size) - 1 : 0] block_select; // num of block_select (ways)
//reg [max_array : max_array - a_size + 1] returned;

cache testing(data_command, read_address, hit, miss, bus_op_out, snoop_result, L2_L1, debug);


initial
//address_parse inst(read_address, tag, index, byte_select);
begin

data_command = CLR;
read_address = 0;
debug = 1;

#50
 //look for file name
if($test$plusargs ("debug"))
	debug = 1;
if($value$plusargs ("FILENAME=%s", retrieved_file))
    $display("Received file name");
else
	begin
	$display("No file name received");
	$finish;
	end 
//open file
//retrieved_file ="tracefileLRU.txt";//for testing! to remove later 
//#10
data_file = $fopen(retrieved_file, "r");//for testing! to remove later 
debug =1;  //for testing! to remove later 
if(data_file == 0)
	begin
	$display("Unable to open file");
	$finish;
	end
if($test$plusargs ("silent"))
begin
	$display("silent mode");
	silent = 1;
end

else
begin
	silent = 0;
	$display("normal mode");
end


while(!$feof(data_file))
	begin
//$display("Valid data: ", data_command);     //for testing
	valid_data = $fscanf(data_file, "%d", data_command);
	if(valid_data != 0)
		begin
		if(debug == 1)
			$display("Read command number: ", data_command);
			
		//send data into modules
		end
	else
		begin
		$display("No command read.");
		$finish;
		end
	read_address = 1'bz;
	#1
	valid_data = $fscanf(data_file, "%h", read_address);
	if(valid_data != 0)
		begin
		#250
		if(hit === 1)
			hit_rate = hit_rate + 1;

		if(miss === 1)
			miss_rate = miss_rate + 1;

		if(data_command === 0 || data_command === 2)
			num_read = num_read + 1;

		if(data_command === 1)
			num_write = num_write + 1;

		if(debug == 1)
		begin
			
			$display("Read address: 0x%8h ", read_address);
			//busOps(data_command,read_address);
			//GetSnoopResult(read_address,final_final_snoop,snoop_text_rslt);
			cmd_translator(data_command,translator);
			$display("From cmd translator %s",translator);
			BusOperation( translator, read_address,final_final_snoop);
			if(hit)
			begin
			$display("HIT #%d: address %h",hit,read_address);
			end
			else if(miss)
			$display("MISS #%d : address %h", miss,read_address);
		/*	case(final_final_snoop)
			'h0 	: $display("HIT:%b",final_final_snoop);
			'h1 	:$display("HITM:%b",final_final_snoop);
			'h2	: $display("NOHIT:%b",final_final_snoop);
			default : $display("NOHIT:%b",final_final_snoop);
			endcase */
			//$display("tag: %16b",tag);
			///$display("index: %b",index);
			//$display("byteselect: %b",byte_select);
			//$display ("------------cacheStruct---------------");
		// 	PrintCmd(data_command,read_address);
			debug_print(read_address); 
			//store_cache(tag,index,byte_select);
		/* for(int k=0; k< WAY; k++)
		begin
		$display (" T array :%h",tag_array[k]);
		end */
		end
		//send data into modules
		end
	else
		begin
		$display("No address read.");
		$finish;
		end
	end
$fclose(data_file);

Cache_stat(num_read, num_write, hit_rate, miss_rate);
end
	

endmodule


//Function to display BusOperation
task busOps(input reg [3:0]data_command,input reg [31:0]address);
	// string address ="data";
	//$display("data receive %d",address);
	case(data_command)
		READ: $display("Busop: Read, address 0x%8h",address);
		WRITE:$display("Busop: Write, address 0x%8h",address);
		L1_READ:$display("Busop: L1_Read, address 0x%8h",address);
		SNOOP_INVAL:$display("Busop: SNOOP_INVALIDATE:%d , address 0x%8h",SNOOP_INVAL,
		address);
		SNOOPED_RD:$display("Busop: SNOOP_RD, address 0x%8h",address);
		SNOOP_WR:$display("Busop: SNOOP_WR, address 0x%8h",address);
		SNOOP_RDWITM:$display("Busop: SNOOP_RDWITM:%d, address 0x%8h",SNOOP_RDWITM,address); //Read with intent to modify
		CLR:$display("Busop: clear_cach, address 0x%8h",address);
		PRINT:$display("Busop: Print, address 0x%8h",address);
		default:$display("Busop: INVALID CMD!! %d 0x%8h",data_command,address);
	endcase
endtask

/* task store_cache(int tag_inf,int index_inf,int bit_select); //store data from the file

  //parameter integer i=0;
    for(int i=0;i<12;i++)
      begin
        cache_data.tag_info[i] = tag_inf;
        cache_data.index_info[i] =index_inf;
 
      end
    for(int i=0;i<9;i++)
      begin
        $display ("tag in cache %b", cache_data.tag_info[i]);
        $display ("index = %b",cache_data.index_info[i]);
 
      end
endtask */

task debug_print(input reg [i_size - 1 : 0 ] read_address);

	$display("----debug printinggggg----");
	$write("tag: %16b", read_address[i_size - 1 : i_size - tag_bits]);
	$write(" | ");
	$write("index: %b",read_address [index_bits + d_size - 1: d_size]);
	$write(" | ");
	$write("byteselect: %b\n",read_address [ d_size - 1: 0]);




endtask


task BusOperation(string BusOp,int address,int SnoopResult);
	// string address ="data";
	//$display("data receive %d",address);
	GetSnoopResult(address,SnoopResult,snoop_text_rslt);
	//SnoopResult = final_final_snoop;
	$display("BusOp; %s, Address: %h, Snoop Input: %d", BusOp,address, SnoopResult);
endtask

task cmd_translator(input [3:0]cmd,output string cpu_cmd);
	
	case(cmd)
	READ:
	begin
	cpu_cmd = "read";
	read= read +1;
	end
	WRITE: 
	begin 
	cpu_cmd = "write";
	write++;
	end
	L1_READ: cpu_cmd = "L1_Instruct";
	SNOOP_INVAL: cpu_cmd ="SNOOP Invalidate";
	SNOOPED_RD: cpu_cmd = "SNOOPED_RD Rq";
	SNOOP_WR: cpu_cmd = "SNOOP_WR Rq";
	SNOOP_RDWITM: cpu_cmd = "SNOOP_RDWITM";
	CLR: cpu_cmd ="Clear cache";
	PRINT: cpu_cmd = "PrintCmd";
	endcase

endtask

task GetSnoopResult(input [i_size-1:0]address, 
					output reg [1:0]snoop_Rslt, 
					output string snoop_status);
					
	bit [1:0]snoop;
	snoop = address[1:0];
	case(snoop)
			'h0: 
				begin
				snoop_Rslt = HIT;
				snoop_status= "HIT";
				end
			'h1: 
				begin
				snoop_Rslt = HITM;
				snoop_status= "HITM";
				end
			'h2: 
				begin
				snoop_Rslt = NOHIT;
				snoop_status= "NOHIT";
				end
			default: 
				begin
				snoop_Rslt = NOHIT;
				snoop_status= "NOHIT";
				end
	endcase
	 final_final_snoop = snoop_Rslt ;
	/*  $write("--------------------------");
	 $write(" final_final_snoop: &d",final_final_snoop);
	 $write(" \n"); */
endtask : GetSnoopResult


task Cache_stat(int cache_read, int cache_write, int cache_hit, int cache_miss);
	$display("\nNumber of Reads: %d", cache_read);
	$display("Number of Writes: %d", cache_write);
	$display("Number of Hits: %d", cache_hit);
	$display("Number of Misses: %d", cache_miss);
	$display("Cache Hit Ratio: %d", (cache_hit / (cache_hit + cache_miss)));



endtask
