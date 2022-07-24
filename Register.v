module router_reg(input clk,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
			input [7:0] data_in,
			output reg err, parity_done,low_pkt_valid,
			output reg [7:0] dout);
			reg [7:0] header_byte,fifo_full_byte,internal_parity,packet_parity;

always@(posedge clk)
begin
	if(~resetn)
		header_byte<=8'b0;
	else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)
		header_byte<=data_in;
end

always@(posedge clk)
begin
	if(~resetn)
		fifo_full_byte<=8'b0;
	else if(ld_state && fifo_full )
		fifo_full_byte<=data_in;
end

always@(posedge clk)
begin
	if(~resetn)
		internal_parity<=8'b0;
	else if(detect_add )
		internal_parity<=8'b0;
	else if(lfd_state && pkt_valid && ~full_state)
		internal_parity<=internal_parity ^ header_byte;
	else if(ld_state && pkt_valid && ~full_state)
		internal_parity<=internal_parity ^ data_in;
end

always@(posedge clk)
begin
	if(~resetn)
		packet_parity<=8'b0;
	else if(ld_state && ~pkt_valid )
		packet_parity<=data_in;
end

always@(posedge clk)
begin
	if(~resetn)
		parity_done<=0;
	else if(detect_add)
		parity_done<=0;
	else if((ld_state && ~pkt_valid && ~fifo_full) || (laf_state && low_pkt_valid && ~parity_done))
		parity_done<=1;
end

always@(posedge clk)
begin
	if(~resetn)
		dout<=0;
	else if(lfd_state )
		dout<=header_byte;
	else if(ld_state && ~fifo_full)
		dout<=data_in;
	else if(laf_state)
		dout<=fifo_full_byte;
end

always@(posedge clk)
begin
	if(~resetn || rst_int_reg)
		low_pkt_valid<=0;
	else if(ld_state && ~pkt_valid )
		low_pkt_valid<=1;
end

always@(posedge clk)
begin
	if(~resetn)
		err<=0;
	else if(parity_done )
	begin
		if(internal_parity != packet_parity)
			err<=1;
		else
			err<=0;
	end
end
endmodule
