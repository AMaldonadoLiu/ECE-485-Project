import mypkg::*;

module MESI( cmd,snoopResult,MESI_bits,miss,snoopResultout,busop_out,L2_L1,mesiReturned, silent);

parameter integer busopsize = 3;


input reg [3:0] cmd;
input reg [1:0] snoopResult;
//input reg block_select;
input reg [1:0] MESI_bits;
input reg miss;
input reg silent;

//input reg way;
//output reg snoopResultout;
output reg [1:0] busop_out[busopsize];
output reg [1:0] L2_L1[busopsize];
output reg [1:0] mesiReturned;
output reg [1:0] snoopResultout;
//input reg hit=1;
enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands

always @ (*)
begin
	//$display("snoop = ", snoopResult);
	//$display("MESI PROTOCOL");
	if(MESI_bits === 2'bxx)
	begin
		MESI_bits = 0;
	end
	for(int i = 0; i < busopsize; i = i + 1)
	begin
		busop_out[i] = 2'bxx;
	end
	for(int n = 0; n < busopsize; n = n + 1)
	begin
		L2_L1[n] = 2'bxx;
	end

	snoopResultout = 2'bxx;
	case(MESI_bits)

	M:
		begin
			if(cmd === 0 || cmd === 3)
			begin

				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					busop_out[0] = BWRITE;

					busop_out[1] = BREAD;

					mesiReturned = S;
				end

				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT-1))
				begin
					busop_out[0] = BWRITE;

					busop_out[1] = BREAD;

					mesiReturned = E;
				end
				
				else
					mesiReturned = M;
				L2_L1[0] = SENDLINE;

			end

			else if(cmd === 1)
			begin

				if(miss === 1)
				begin
					L2_L1[0] = EVICTLINE;
					busop_out[0] = BRWIM;
					L2_L1[1] = SENDLINE;
					L2_L1[2] = GETLINE;

				end

				else if(miss === 0)
				begin
					L2_L1[0] = SENDLINE;
					busop_out[0] = BINVAL;

				end
				
				mesiReturned = M;


				//L2_L1 = GETLINE;
				//since it is write through only once from L1, this means that since we hit and are modified, we don't GETLINE
			end

			else if(cmd === 4 && miss != 1)
			begin
				snoopResultout = HITM;
				L2_L1[0] = GETLINE;
				busop_out[0] = BWRITE;

				mesiReturned = S;
			end

			else if(cmd === 6 && miss != 1)
			begin
				snoopResultout = HITM;
				L2_L1[0] = EVICTLINE;
				busop_out[0] = BWRITE;

				mesiReturned = I;
			end	
	
			else if(cmd === 8)
			begin
				L2_L1[0] = EVICTLINE;
				busop_out[0] = BWRITE;

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
					L2_L1[0] = INVALLINE;
					busop_out[0] = BREAD;


					mesiReturned = S;
				end
				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT+1))
				begin
					L2_L1[0] = INVALLINE;
					busop_out[0] = BREAD;

					mesiReturned = E;
				end
				L2_L1[1] = SENDLINE;

			end


			else if(cmd === 1)
			begin
				if(miss === 1 && (snoopResult === HIT || snoopResult === HITM))
				begin
					L2_L1[0] = INVALLINE;
					busop_out[0] = BRWIM;

					
				end


				else if(miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT+1))
				begin
					L2_L1[0] = INVALLINE;
					busop_out[0] = BRWIM;

					//L2_L1 = SENDLINE;
				end

				L2_L1[1] = SENDLINE;
				mesiReturned = M;
				L2_L1[2] = GETLINE;
				
			end

			
			else if(cmd === 5 && miss === 0)
			begin

				mesiReturned = S;
				snoopResultout = HIT;
			end


			else if((cmd === 6 && miss === 0) || cmd === 8)
			begin
				L2_L1[0] = INVALLINE;
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
					L2_L1[0] = EVICTLINE;
					busop_out[0] = BREAD;

					mesiReturned = S;
					L2_L1[1] = SENDLINE;
				end
				else if( miss === 1 && (snoopResult === NOHIT || snoopResult === NOHIT + 1))
				begin
					L2_L1[0] = EVICTLINE;
					busop_out[0] = BREAD;

					mesiReturned = E;
					L2_L1[1] = SENDLINE;
				end

				else
				begin
					mesiReturned = S;
					L2_L1[0] = SENDLINE;
				end
				

			end


			else if(cmd === 1)
			begin
				if(miss === 1)
				begin
					L2_L1[0] = EVICTLINE;
					busop_out[0] = BRWIM;

					L2_L1[1] = SENDLINE;
				end
				
				else
					busop_out[0] = BINVAL;
				mesiReturned = M;

				L2_L1[2] = GETLINE;
				
			end

			else if(cmd === 3 && miss === 0)
			begin
				L2_L1[0] = INVALLINE;
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
					busop_out[0] = BREAD;

					mesiReturned = S;
				end

				else if(snoopResult == NOHIT)
				begin

					busop_out[0] = BREAD;

					mesiReturned = E;

				end
				L2_L1[0] = SENDLINE;
			end


			else if(cmd === 1) //not sure if this is needed. Assuming it is a write allocate
			begin
				if(snoopResult === HIT || snoopResult === HITM)
				begin 
					busop_out[0] = BRWIM;

				end
				L2_L1[0] = SENDLINE;
				mesiReturned = M;
				L2_L1[1] = GETLINE;
			end	


			else
				mesiReturned = I;


		end

	endcase

	//$display("finished");
end

endmodule
