//`include "address_parse.sv"
import mypkg::*;

module toptop;


//tag,index,byteselext
//parameter integer protocol = 2;
//this one isnt in bits


integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;
integer debug;
reg flag = 0;
reg[63:0] read_address;


address_parse inst(read_address, tag, index, byte_select);
initial
//address_parse inst(read_address, tag, index, byte_select);
begin
//look for file name
//if($test$plusargs ("debug"))
	//debug = 1;
//if($value$plusargs ("FILENAME=%s", retrieved_file))
 //   $display("Received file name");
//else
	//begin
	//$display("No file name received");
	///$finish;
	//end
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
			//address_parse inst(address, tag, index, byte_select);
			GetSnoopResult(read_address,final_final_snoop);
			case(final_final_snoop)
			'h0 	: $display("HIT:%b",final_final_snoop);
			'h1 	:$display("HITM:%b",final_final_snoop);
			'h2	: $display("NOHIT:%b",final_final_snoop);
			default : $display("NOHIT:%b",final_final_snoop);
			endcase
			//$display("tag: %16b",tag);
			///$display("index: %b",index);
			//$display("byteselect: %b",byte_select);
			//$display ("------------cacheStruct---------------");
			PrintCmd(data_command,read_address);
			debug_print;
			//store_cache(tag,index,byte_select);

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

//Function to dispaly BusOperation
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

task store_cache(int tag_inf,int index_inf,int bit_select); //store data from the file

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
endtask

task debug_print();

$display("----debug printinggggg----");
$write("tag: %16b",tag);
$write(" | ");
$write("index: %b",index);
$write(" | ");
$write("byteselect: %b",byte_select);




endtask


task PrintCmd(input reg [3:0]data_command,input reg [31:0]address);
	// string address ="data";
	//$display("data receive %d",address);
	case(data_command)
		READ: $display("Busop: Read, address 0x%8h",address);
		WRITE:$display("Busop: Write, address 0x%8h",address);
		L1_READ:$display("Busop: L1_Read, address 0x%8h",address);
		SNOOP_INVAL:$display("Busop: address 0x%8h",address);
		SNOOPED_RD:$display("Busop: SNOOP_RD, address 0x%8h",address);
		SNOOP_WR:$display("Busop: SNOOP_WR, address 0x%8h",address);
		SNOOP_RDWITM:$display("Busop: address 0x%8h",address); //Read with intent to modify
		CLR:$display("Busop: clear_cach, address 0x%8h",address);
		PRINT:$display("Busop: Print, address 0x%8h",address);
		default:$display("Busop: INVALID CMD!! %d 0x%8h",data_command,address);
	endcase
endtask

task GetSnoopResult(input [i_size-1:0]address, output reg [1:0]snoop_Rslt);
	bit [1:0]snoop;
	snoop = address[1:0];
	case(snoop)
			'h0 	: snoop_Rslt = HIT;
			'h1 	: snoop_Rslt = HITM;
			'h2	: snoop_Rslt = NOHIT;
			default : snoop_Rslt = NOHIT;
	endcase
	final_Snoop = snoop_Rslt;
endtask : GetSnoopResult