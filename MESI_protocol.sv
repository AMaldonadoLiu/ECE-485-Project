import mypkg::*;
module MESI( cmd,snoopResult,block_select,way, hit,snoopResultout,Busopt_out,L2_L1,mesiReturned);

input reg cmd;
input reg snoopResult;
input reg block_select;
input reg hit;
input reg way;
output reg snoopResultout;
output reg Busopt_out;
output reg L2_L1;
output reg mesiReturned;
//input reg hit=1;
enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands
cache_data mesiState;

always @ (cmd)
begin
	case(hit)
	
	M:
		begin
			mesiState.protocol_bits = M;
			if(cmd == READ || cmd ==L1_READ || cmd == WRITE )
			begin
				mesiState.protocol_bits = mesi_bits.M; //assign mesi ststus
			end
			
		end
	
	E:
		begin
			if(cmd == READ)
			begin
				mesiState.protocol_bits = E;
			end
			else if(cmd == WRITE)
			begin
				mesiState.protocol_bits = M;
			end
		end
		
	S:
		begin
			if(cmd == READ)
				mesiState.protocol_bits = S;
			else if(cmd == WRITE)
				mesiState.protocol_bits = M;
	
		end
	I:
		begin
			if(cmd == READ) 
			begin
				if(snoopResult == HIT|| snoopResult == HITM)
				begin
					mesiState.protocol_bits = S;
				end
				else if(snoopResult == NOHIT)
				begin
					mesiState.protocol_bits = S;
				//if other cache have valid copy 
				end
			end
			else if(cmd == WRITE)
			begin
				mesiState.protocol_bits = M;
			end

		end
	endcase
	$display("finished");
end

endmodule