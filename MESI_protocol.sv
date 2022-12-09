import mypkg::*;

module MESI( cmd,snoopResult,MESI_bits,miss,snoopResultout,busop_out,L2_L1,mesiReturned);

input reg [3:0] cmd;
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

always @ (*)
begin
	
	if(MESI_bits === 2'bxx)
	begin
		MESI_bits = 0;
	end
	busop_out = 2'bxx;
	snoopResultout = 2'bxx;
	case(MESI_bits)

	M:
		begin
			if(cmd === 0 || cmd === 3)
			begin

				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					busop_out = BWRITE;
					busop_out = BREAD;
					mesiReturned = S;
				end

				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT-1))
				begin
					busop_out = BWRITE;
					busop_out = BREAD;
					mesiReturned = E;
				end
				
				else
					mesiReturned = M;
				L2_L1 = SENDLINE;
				
			end

			else if(cmd === 1)
			begin

				if(snoopResult === HIT || snoopResult === HITM)
				begin
					L2_L1 = EVICTLINE;
					busop_out = BRWIM;

				end

				else
				begin
					L2_L1 = SENDLINE;
					busop_out = BINVAL;
				end
				
				mesiReturned = M;

				if(miss === 1)
					L2_L1 = GETLINE;

				//L2_L1 = GETLINE;
				//since it is write through only once from L1, this means that since we hit and are modified, we don't GETLINE
			end

			else if(cmd === 4 && miss != 1)
			begin
				snoopResultout = HITM;
				L2_L1 = GETLINE;
				busop_out = BWRITE;
				mesiReturned = S;
			end

			else if(cmd === 6 && miss != 1)
			begin
				snoopResultout = HITM;
				L2_L1 = EVICTLINE;
				busop_out = BWRITE;
				mesiReturned = I;
			end	
	
			else if(cmd === 8)
			begin
				L2_L1 = EVICTLINE;
				busop_out = BWRITE;
				mesiReturned = I;
			end

			else
				mesiReturned = M;
		
				
	
		end
	
	E:
		begin
			if(cmd === 0 || cmd === 2)
			begin
				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					L2_L1 = INVALLINE;
					busop_out = BREAD;

					mesiReturned = S;
				end
				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT+1))
				begin
					L2_L1 = INVALLINE;
					busop_out = BREAD;
					mesiReturned = E;
				end
				L2_L1 = SENDLINE;

			end


			else if(cmd === 1)
			begin
				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					L2_L1 = INVALLINE;
					busop_out = BRWIM;
					
				end


				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT+1))
				begin
					L2_L1 = INVALLINE;
					busop_out = BRWIM;
					//L2_L1 = SENDLINE;
				end

				L2_L1 = SENDLINE;
				mesiReturned = M;
				L2_L1 = GETLINE;
				
			end

			
			else if(cmd === 5 && miss === 0)
			begin

				mesiReturned = S;
				snoopResultout = HIT;
			end


			else if((cmd === 6 && miss === 0) || cmd === 8)
			begin
				L2_L1 = INVALLINE;
				mesiReturned = I;
			end

			else
				mesiReturned = E;


		end
		
	S:
		begin
			if(cmd === 0 || cmd === 2)
			begin
				if(miss === 1 && (snoopResult ===  HIT || snoopResult === HITM))
				begin
					L2_L1 = EVICTLINE;
					busop_out = BREAD;
					mesiReturned = S;
					L2_L1 = SENDLINE;
				end
				else if( miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT + 1))
				begin
					L2_L1 = EVICTLINE;
					busop_out = BREAD;
					mesiReturned = E;
					L2_L1 = SENDLINE;
				end

				else
				begin
					mesiReturned = S;
					L2_L1 = SENDLINE;
				end
				

			end


			else if(cmd === 1)
			begin
				if(miss === 1)
				begin
					L2_L1 = EVICTLINE;
					busop_out = BRWIM;
					L2_L1 = SENDLINE;
				end
				
				else
					busop_out = BINVAL;
				mesiReturned = M;

				L2_L1 = GETLINE;
				
			end

			else if(cmd === 3 && miss === 0)
			begin
				L2_L1 = INVALLINE;
				mesiReturned = I;
				
			end

			
			else if(cmd === 4 && miss === 0)
			begin
				snoopResultout = HIT;
				mesiReturned = S;

			end
			
			else if(cmd === 5 && miss === 0)
			begin
				snoopResultout = HIT;
				mesiReturned = I;

			end


			else if(cmd === 6 && miss === 0)
			begin
				snoopResultout = HIT;
				mesiReturned = I;
			end
			
			else if(cmd === 8)
			begin
				mesiReturned = I;
			end
	
			else
				mesiReturned = S;
				
	
		end


	I:
		begin
			if(cmd === 0 || cmd === 2) 
			begin
				if(snoopResult == HIT|| snoopResult == HITM)
				begin
					busop_out = BREAD;
					mesiReturned = S;
				end

				else if(snoopResult == NOHIT)
				begin

					busop_out = BREAD;
					mesiReturned = E;

				end
				L2_L1 = SENDLINE;
			end


			else if(cmd === 1) //not sure if this is needed. Assuming it is a write allocate
			begin
				if(snoopResult === HIT || snoopResult === HITM)
				begin 
					busop_out = BRWIM;
				end
				L2_L1 = SENDLINE;
				mesiReturned = M;
				L2_L1 = GETLINE;
			end	


			else
				mesiReturned = I;


		end

	endcase
	if(busop_out === 2'bxx)
		busop_out = 2'bzz;
	if(snoopResultout === 2'bxx)
		snoopResultout = 2'bzz;
	//$display("finished");
end

endmodule
