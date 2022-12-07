import mypkg::*;


module runcache;

integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;
integer debug;
reg flag = 0;
reg[63:0] read_address;

reg hit;
reg miss; 
bit MESI[WAY];


/* typedef struct {logic v; logic vld;} bit_rec;

I need an array bit_rec_v of 32 elements of this struct. Can I define it as following?

typedef bit_rec_v bit_rec [0:31];
typedef bit_rec bit_rec_v [32]; */

//bit tag_array[50];

cache_data my_array[10];

address_parse inst(.address(read_address), 
					.tag(tag), 
					.index(index), 
					.byte_select(byte_select));
//hit_miss #(.i_size(i_size), .c_size(c_size), .d_size(d_size), .protocol(protocol), .a_size(a_size)) inst1 (tag, /*index,*/ tag_array, MESI, hit, miss);
hit_miss inst1 (.tag(tag), 
				.tag_array(tag_array), 
				.MESI(MESI), 
				.hit(hit), 
				.miss(miss));

/* cache inst2(	.command(data_command), 
		.tag_array(tag_array),
		.hit(hit)); */
initial
//address_parse inst(read_address, tag, index, byte_select);
begin
/* //look for file name
if($test$plusargs ("debug"))
	debug = 1;
if($value$plusargs ("FILENAME=%s", retrieved_file))
    $display("Received file name");
else
	begin
	$display("No file name received");
	$finish;
	end */
//open file
retrieved_file ="tracefileLRU.txt";//for testing! to remove later 
#10
data_file = $fopen(retrieved_file, "r");//for testing! to remove later 
debug =1;  //for testing! to remove later 
if(data_file == 0)
	begin
	$display("Unable to open file");
	$finish;
	end
if($test$plusargs ("silent"))
	$display("silent mode");
else
	$display("normal mode");


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

	valid_data = $fscanf(data_file, "%h", read_address);
	if(valid_data != 0)
		begin
		if(debug == 1)
		begin
#10
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
			debug_print; 
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

task debug_print();

	$display("----debug printinggggg----");
	$write("tag: %16b",tag);
	$write(" | ");
	$write("index: %b",index);
	$write(" | ");
	$write("byteselect: %b",byte_select);




endtask


task BusOperation(string BusOp,int address,int SnoopResult);
	// string address ="data";
	//$display("data receive %d",address);
	GetSnoopResult(address,SnoopResult,snoop_text_rslt);
	//SnoopResult = final_final_snoop;
	$display("BusOp; %s, Address: %h, Snoop Result: %d", BusOp,address, SnoopResult);
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
	$display("Number of Reads: %d", cache_read);
	$display("Number of Writes: %d", cache_write);
	$display("Number of Hits: %d", cache_hit);
	$display("Number of Misses: %d", cache_miss);
	$display("Cache Hit Ratio: %d", (cache_hit / (cache_hit + cache_miss)));



endtask
