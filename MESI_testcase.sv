module test_case;
enum{Pr_Rd,Pr_Wr};
integer mesi;
integer curr_state;
integer next_state;

always 
begin
case(mesi)
	
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
				// curr_state = S;
				else:
				curr_state = E;
				end
			else if(Pr_Wr)
				curr_state = M;


		end
	end

endmodule
