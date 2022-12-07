module MESI(input cmd, input index, input snoopResult, input hit);
enum{Pr_Rd,Pr_Wr};
enum{M,E,S,I};
integer mesi;
integer curr_state;
integer next_state;

parameter cmd;
parameter index; 
parameter snoopResult;
parameter hit;

always 
begin
case(hit)
	
	M:
		begin
			curr_state = M;
			if(Pr_Rd)
				curr_state = M; //Read to the  block Cache Hit
			else if(Pr_Wr)
				curr_state = M; // write to block Cache Hit			
			
		end
	
	E:
		begin
			curr_state = E;
			if(Pr_Rd)
				curr_state = E;
			else if(Pr_Wr)
				curr_state = M;
		
		end
		
	S:
		begin
			curr_state = S;
			if(Pr_Rd)
				curr_state = S;
			else if(Pr_Wr)
				curr_state = M;
	
		end
	I:
		begin
			curr_state = I;
			if(Pr_Rd) begin
				//if other cache have valid copy 
				//ask Getsnoopresult fucntion if it's hit ot miss
				if(HIT or HITM)begin
					curr_state = S;
				else:
					curr_state = E;
				end
			else if(Pr_Wr)
				curr_state = M;


		end
	end

endmodule