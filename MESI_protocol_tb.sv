/*import mypkg::*;

module MESI_protocol_tb;

reg [3:0] cmd;
reg [1:0] snoopResult;
reg [1:0] MESI_bits;
reg miss;

reg [1:0] busop_out;
reg [1:0] L2_L1;
reg [1:0] mesiReturned;
reg [1:0] snoopResultout;

reg [7:0] consolidated;

MESI test(cmd, snoopResult, MESI_bits, miss, snoopResultout, busop_out, L2_L1, mesiReturn);


initial
begin
	for(int i = 0; i < 9; i = i + 1) //dont need to check print, that will be handled elsewhere, also no L1_READ, as that is the same as READ
	begin
		cmd = i;
		for(int j = 0; j < 2; j = j + 1) //dont need hitm, as the protocol is the same as with hit, and dont need 2 nohits
		begin
			snoopResult = 2 * j;
			for(int k = 0; k < 4; k = k + 1)
			begin
				MESI_bits = k;
				for(int m = 0; m < 2; m = m + 1)
				begin
					miss = m;
					#1
					consolidated = {busop_out, L2_L1, mesiReturned, snoopResultout}; 
					
					if(cmd === SNOOPED_RD)
					begin
						if(miss === 0)
						begin
							if(MESI_bits != I)
							begin
								if(mesiReturned != S)
									$display("Incorrect");
							end
						end
					end
					
					if(cmd === READ || cmd === L1_READ)
					begin
						
						if(miss === 0)
						begin
							if(snoopResult === NOHIT)
							begin
								if(mesiReturned != S)
									$display("Incorrect");
							end
							else
								if(MESI_bits === S)
									if(mesiReturned != S)
										$display("Incorrect");
							end
						end
				
	

						else
						begin
							if(MESI_bits != I)
							begin
								if(miss === 0)
								begin
									if(mesiReturned != E)
										$display("Incorrect");
								end
							end
							
							else
							begin
								if(mesiReturned != E)
									$display("Incorrect");
							end
						end
					end

					if(

							
					end

					if(
									
					case(cmd)
					
					1:
						begin
							case(snoopResult)
							
							0:
								begin
									case(MESI_bits)

									M:
										begin
											if(miss === 1)
											begin
												if(mesiReturned != S)
												begin
													$display("Incorrect");
													$displayb("output should be: ", S);
													$displayb("got: ", mesiReturned);
												end
											end
											
											else
												if(mesiReturned |== M)
												begin
													$display("Incorrect");
													$displayb("output should be: ", M);
													$displayb("got: ", mesiReturned);
												end
							
							
					
		
*/
