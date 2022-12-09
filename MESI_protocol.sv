import mypkg::*;

module MESI( cmd,snoopResult,MESI_bits,miss,snoopResultout,busop_out,L2_L1,mesiReturned);

input reg cmd;
input reg [1:0] snoopResult;
//input reg block_select;
input reg [1:0] MESI_bits;
input reg miss;

//input reg way;
//output reg snoopResultout;
output reg [1:0] busop_out;
output reg [1:0] L2_L1;
output reg [1:0] mesiReturned;
output reg [1:0] snoopResultout;
//input reg hit=1;
enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands

always @ (cmd)
begin
	case(MESI_bits)
	
	M:
		begin
			if(cmd === READ || cmd === L1_READ)
			begin

				if(snoopResult === HIT || snoopResult === HITM)
				begin
					busop_out = BREAD;
					mesiReturned = S;
				end

				else
					mesiReturned = M;
				L2_L1 = SENDLINE;
				
			end

			else if(cmd === WRITE)
			begin

				if(snoopResult === HIT || snoopResult === HITM)
				begin
					L2_L1 = EVICTLINE;

				end
				busop_out = BRWIM;
				L2_L1 = SENDLINE;
				
				mesiReturned = M;

				L2_L1 = GETLINE;
			end

			else if(cmd === SNOOPED_RD && miss != 1)
			begin
				snoopResultout = HITM;
				L2_L1 = GETLINE;
				busop_out = BWRITE;
				mesiReturned = S;
			end

			else if((cmd === SNOOP_RDWITM && miss != 1) || cmd === CLR)
			begin
				snoopResultout = HITM;
				L2_L1 = EVICTLINE;
				busop_out = BWRITE;
				mesiReturned = I;
			end	
				

			
		end
	
	E:
		begin
			if(cmd === READ || cmd === L1_READ)
			begin
				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					L2_L1 = INVALLINE;
					busop_out = BREAD;

					mesiReturned = S;
				end
				else	
					mesiReturned = E;
				L2_L1 = SENDLINE;

			end


			else if(cmd === WRITE)
			begin
				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					L2_L1 = INVALLINE;
					busop_out = BRWIM;
					L2_L1 = SENDLINE;
				end

				mesiReturned = M;
				L2_L1 = GETLINE;
				
			end

			
			else if(cmd === SNOOPED_RD)
			begin

				mesiReturned = S;
				snoopResultout = HIT;
			end


			else if(cmd === SNOOP_RDWITM || cmd === CLR)
			begin
				L2_L1 = INVALLINE;
				mesiReturned = I;
			end


		end
		
	S:
		begin
			if(cmd === READ)
			begin
				if(miss === 1 && (snoopResult === 1 || snoopResult === 2))
				begin
					L2_L1 = EVICTLINE;
					busop_out = BREAD;
					mesiReturned = S;
					L2_L1 = SENDLINE;
				end
				else if( miss === 1 && (snoopResult === 3 || snoopResult === 4))
				begin
					L2_L1 = EVICTLINE;
					busop_out = BREAD;
					mesiReturned = E;
					L2_L1 = SENDLINE;
				end

				else
				begin
					mesiReturned = S;
				end
				

			end


			else if(cmd === WRITE)
			begin
				if(miss === 1)
				begin
					L2_L1 = EVICTLINE;
					busop_out = BRWIM;
					L2_L1 = SENDLINE;
				end
				
				mesiReturned = M;

				L2_L1 = GETLINE;
				
			end

			
			else if(cmd === SNOOPED_RD)
			begin
				snoopResultout = HIT;
				mesiReturned = S;

			end
			
			else if(cmd === SNOOP_WR)
			begin
				snoopResultout = HIT;
				mesiReturned = I;

			end


			else if(cmd === SNOOP_RDWITM)
			begin
				snoopResultout = HIT;
				mesiReturned = I;
			end
			
			else if(cmd === CLR)
			begin
				mesiReturned = I;
			end
				
	
		end
	I:
		begin
			if(cmd === READ) 
			begin
				if(snoopResult == HIT|| snoopResult == HITM)
				begin
					busop_out = BREAD
					mesiReturned = S;
				end

				else if(snoopResult == NOHIT)
				begin

					busop_out = BREAD
					mesiReturned = E;

				end
			end


			else if(cmd === WRITE)
			begin
				if(snoopResult === HIT || snoopResult === HITM)
				begin 
					busop_out = BINVAL;
				end
				
				mesiReturned = M;
			end



		end
	endcase
	$display("finished");
end

endmodule
