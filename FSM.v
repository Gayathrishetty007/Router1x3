module router_fsm(input [1:0] data_in,
	input clk,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_pkt_valid,
	output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

	parameter DECODE_ADDRESS = 3'b000,
	  	  LOAD_FIRST_DATA = 3'b001,
 	  	  LOAD_DATA = 3'b010,
 	  	  WAIT_TILL_EMPTY = 3'b011,
 	  	  LOAD_PARITY = 3'b100,
 	  	  FIFO_FULL_STATE = 3'b101,
 	  	  LOAD_AFTER_FULL = 3'b110,
 	 	  CHECK_PARITY_ERROR = 3'b111;
	reg [1:0] temp;
	reg [7:0] state,next_state;

always@(posedge clk)
begin
	if(~resetn)
		temp<=2'b00;
	else if(detect_add)
		temp<=data_in;
end

always@(posedge clk)
begin
	if(~resetn)
		state<=DECODE_ADDRESS;
	else if((soft_reset_0 && temp==0) || (soft_reset_1 && temp==1) || (soft_reset_2 && temp==2))
		state<=DECODE_ADDRESS;
	else
		state<=next_state;
end

always@(*)
begin
	next_state=DECODE_ADDRESS;
	case(state)
	DECODE_ADDRESS: begin
 			if((pkt_valid & (data_in[1:0]==0) && fifo_empty_0) |(pkt_valid & (data_in[1:0]==1) && fifo_empty_1) |(pkt_valid & (data_in[1:0]==2) && fifo_empty_2))
				next_state=LOAD_FIRST_DATA;
 			else if ((pkt_valid & (data_in[1:0]==0) && ~fifo_empty_0) |(pkt_valid & (data_in[1:0]==1) && ~fifo_empty_1) |(pkt_valid & (data_in[1:0]==2) && ~fifo_empty_2))
 				next_state=WAIT_TILL_EMPTY; 
 			end
	LOAD_FIRST_DATA: next_state=LOAD_DATA;
	LOAD_DATA: begin 
 		   if(fifo_full)
 			next_state=FIFO_FULL_STATE;
 		   else if(fifo_full==0 && pkt_valid==0)
 			next_state=LOAD_PARITY;
		   else
 			next_state=LOAD_DATA;
 		   end
	WAIT_TILL_EMPTY: begin
 			if((fifo_empty_0 && temp==0) ||(fifo_empty_1 && temp==1) || (fifo_empty_2 && temp==2))
			 	next_state=LOAD_FIRST_DATA;
			else if(~fifo_empty_0 || ~fifo_empty_1 || ~fifo_empty_2)
				next_state=WAIT_TILL_EMPTY;
			end
	LOAD_PARITY:next_state=CHECK_PARITY_ERROR;
	FIFO_FULL_STATE: begin
 			if(fifo_full)
 				next_state=FIFO_FULL_STATE;
 			else
 				next_state=LOAD_AFTER_FULL;
 			end
 	LOAD_AFTER_FULL: begin
 			if(parity_done)
 				next_state=DECODE_ADDRESS;
			else
			begin
 				if(low_pkt_valid)
 					next_state=LOAD_PARITY;
 				else
 					next_state=LOAD_DATA;
 			end
 			end
	CHECK_PARITY_ERROR : begin 
 			if(~fifo_full)
 				next_state=DECODE_ADDRESS;
 			else
 				next_state=FIFO_FULL_STATE;
 			end
	endcase
end
//output logic
assign detect_add=(state==DECODE_ADDRESS);
assign lfd_state=(state==LOAD_FIRST_DATA );
assign busy=(state==LOAD_FIRST_DATA || state==LOAD_PARITY || state== FIFO_FULL_STATE || state== LOAD_AFTER_FULL || state==WAIT_TILL_EMPTY ||state==CHECK_PARITY_ERROR);
assign ld_state=(state==LOAD_DATA);
assign write_enb_reg=(state==LOAD_DATA ||state==LOAD_PARITY || state== LOAD_AFTER_FULL );
assign full_state=(state==FIFO_FULL_STATE);
assign laf_state=(state==LOAD_AFTER_FULL); 
assign rst_int_reg=(state==CHECK_PARITY_ERROR);

endmodule




