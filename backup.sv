module cache ;

parameter Sets = 2**14;                    // 16K sets
parameter Address_bits = 32;               // Address bits (32-bit processor)
parameter D_Ways = 8;                      // 8-way Data Cache
parameter I_Ways = 4;                      // 4-way Instruction Cache 
parameter Byte_lines = 64;                 // 64-byte Cache lines 

localparam Index_bits = $clog2(Sets);      // Index bits
localparam Byte_offset = $clog2(Byte_lines); // byte select bits
localparam Tag_bits = (Address_bits)-(Index_bits+Byte_offset);       // Tag bits
localparam D_ways_bits = $clog2(D_Ways);    // Data way select bits 
localparam I_ways_bits = $clog2(I_Ways);     // Instruction way select bits

logic x;                                     // Mode select
logic Hit;                                   // Indicates a Hit or a Miss 
logic NotValid;                              // Indicates if there is a invalid line
logic [3:0] n;                               // Instruction code from trace file
logic [Tag_bits - 1 :0] Tag;                 // Tag
logic [Byte_offset- 1 :0] Byte;              // Byte select
logic [Index_bits - 1 :0] Index;             // Index
logic [Address_bits-1 :0] Address;           // Address

int TRACE; // file descriptor
int temp_display;

int DATA_CacheHitCounter = 0;                                 // Data Cache Hits
int DATA_CacheMissCounter = 0;                                // Data Cache Misses
int DATA_CacheReadCounter = 0;                                // Data Cache read count
int DATA_CacheWriteCounter = 0;                               // Data Cache write count
int INSTRUCTION_CacheHitCounter = 0;                          // Instruction Cache Hits
int INSTRUCTION_CacheMissCounter = 0;                         // Instruction Cache Misses
int INSTRUCTION_CacheReadCounter = 0;                         // Instruction Cache read count

real DATA_CacheHitRatio;                                      // Data Cache Hit ratio
real INSTRUCTION_CacheHitRatio;                               // Instruction Cache Hit Ratio

longint CacheIterations = 0;                                  // No. of Cache accesses

typedef enum logic [1:0]{                                     // typedef for MESI states
                          Invalid = 2'b00,
                          Shared = 2'b01, 
                          Modified = 2'b10, 
                          Exclusive = 2'b11
                         } mesi;
typedef struct packed {                                       // typedef for L1 Data Cache
                        mesi MESI_bits;
                        bit [D_ways_bits-1:0] LRU_bits;
                        bit [Tag_bits -1:0] Tag_bits;
                      } CacheLine_DATA;
                      
CacheLine_DATA [Sets-1:0] [D_Ways-1:0] L1_DATA_Cache; 
typedef struct packed {                                        // typedef for L1 Instruction Cache
                       mesi MESI_bits;
                       bit [I_ways_bits-1:0] LRU_bits;
                       bit [Tag_bits -1:0] Tag_bits; 
                      } CacheLine_INSTRUCTION;
                      
CacheLine_INSTRUCTION [Sets-1:0][I_Ways-1:0] L1_INSTRUCTION_Cache;


//---------------------------------------
// Read instructions from Trace File 
//---------------------------------------
initial
begin
    ClearCache();
    TRACE = $fopen("trace.txt" , "r");
     if ($test$plusargs("USER_MODE")) 
        x=0;
     else
        x=1;
    while (!$feof(TRACE))
    begin
    temp_display = $fscanf(TRACE, "%h %h\n",n,Address);
   {Tag,Index,Byte} = Address;
 
       case (n) inside
             4'd0: ReadDataFromL1DataCache(Tag,Index,x); 
             4'd1: WriteDatatoL1DataCache (Tag,Index,x);
             4'd2: InstructionFetch (Tag,Index,x);
             4'd3: SendInvalidateCommandFromL2Cache(Tag,Index,x); 
             4'd4: DataRequestFromL2Cache (Tag,Index,x);
             4'd8: ClearCache();
             4'd9: Print_Cache_Contents_MESIstates();
       endcase
end
$fclose(TRACE);

$finish;
end

//Read Data From L1 Cache

task ReadDataFromL1DataCache ( logic [Tag_bits-1 :0] Tag, logic [Index_bits-1:0] Index, logic x); 
DATA_CacheReadCounter++ ;
DATA_Address_Valid (Index,Tag,Hit,Data_ways);
if (Hit == 1)
    begin
       DATA_CacheHitCounter++ ;
       UpdateLRUBits_data(Index, Data_ways );
       L1_DATA_Cache[Index][Data_ways].MESI_bits = (L1_DATA_Cache[Index][Data_ways].MESI_bits == Exclusive) ? Shared : L1_DATA_Cache[Index][Data_ways].MESI_bits ;
    end
else
   begin
   DATA_CacheMissCounter++ ;
   NotValid = 0;
   If_Invalid_DATA (Index , NotValid , Data_ways );
if (NotValid)
   begin
   DATA_Allocate_CacheLine(Index,Tag, Data_ways);
   UpdateLRUBits_data(Index, Data_ways );
   L1_DATA_Cache[Index][Data_ways].MESI_bits = Exclusive; 
     if (x==1)
        $display("Read from L2 address %d'h%h" ,Address_bits,Address);
   end
else 
   begin
   Eviction_DATA(Index, Data_ways);
   DATA_Allocate_CacheLine(Index, Tag, Data_ways);
   UpdateLRUBits_data(Index, Data_ways );
   L1_DATA_Cache[Index][Data_ways].MESI_bits = Exclusive; 
     if (x==1)
        $display("Read from L2 address %d'h%h" ,Address_bits,Address);
   end
end
endtask
