import mypkg::*;

module get_snoop_result(byte_select, snoop_result);

// data line size in bits
//parameter integer d_size = 6;
// number of bits needed for the protocol
parameter integer protocol = 2;

input [protocol - 1:0] byte_select;

output [protocol - 1:0] snoop_result;



// snoop_result of 0 is nohit, 1 is hit, 2 is hitm

assign snoop_result = byte_select[protocol - 1:0] === 0 ? HIT : byte_select[protocol -1:0] === 1 ? HITM : NOHIT;

endmodule
