import mypkg::*;

module top;

//using bits
parameter integer i_size = 32;
parameter integer c_size = 24;
parameter integer d_size = 6;
parameter integer protocol = 2;

//this one isnt in bits
parameter integer a_size = 8;



integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;
integer debug;
reg flag = 0;
reg[63:0] read_address;
reg [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];


address_parse inst(read_address, tag, index, byte_select);
initial
begin
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
#10
data_file = $fopen(retrieved_file, "r");
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
			$display("Read address: 0x%8h ", read_address);
			busOps(data_command,read_address);
			
			$display("tag: %16b",tag);
			$display("index: %b",index);
			$display("byteselect: %b",byte_select);
			$display ("------------cacheStruct---------------");
			store_cache(tag,index,byte_select);

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
	enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command;
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
