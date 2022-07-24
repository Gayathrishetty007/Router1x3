# Router1x3/FIFO
module router_fifo(input [7:0] data_in,
			input clk,resetn,write_enb,read_enb,lfd_state,soft_reset,
			output reg [7:0] data_out,
			output full,empty);
	parameter width=9,
		  depth=16,
		  addr=5;
	reg [width-1:0] wr_ptr,rd_ptr;
	reg [width-1:0] mem [depth-1:0];
	reg [addr:0] count;
	reg lfd;
	integer i;

always@(posedge clk)
begin
	if(~resetn)
		lfd<=0;
	else
		lfd<=lfd_state;
end

always@(posedge clk)
begin
	if(~resetn)
		data_out<=0;
	else if (soft_reset)
		data_out<=8'bz;
	else if(count==0 && read_enb && empty)
		data_out<=8'bz;
	else
	begin
		if(read_enb && ~empty)
			data_out<=mem[rd_ptr[3:0]][7:0];
	end
end

always@(posedge clk)
begin
	if(~resetn)
	begin
		for(i=0;i<depth;i=i+1)
			mem[i]<=0;
	end
	else if(soft_reset)
	begin
		for(i=0;i<depth;i=i+1)
			mem[i]<=0;
	end
	else
	begin
		if(write_enb && ~full)
			{mem[wr_ptr[3:0]][8],mem[wr_ptr[3:0]][7:0]}={lfd,data_in};
	end
end

always@(posedge clk)
begin
	if(~resetn)
	begin
		wr_ptr<=0;
		rd_ptr<=0;
	end
	else if(soft_reset)
	begin
		wr_ptr<=0;
		rd_ptr<=0;
	end
	else
	begin
		if(write_enb && ~full)
			wr_ptr<=wr_ptr+1'b1;
		if(read_enb && ~empty)
			rd_ptr<=rd_ptr+1'b1;
	end
end

always@(posedge clk)
begin
	if(~resetn)
		count<=0;
	else if(read_enb && ~empty)
	begin
		if(mem[rd_ptr[3:0]][8])
			count<=mem[rd_ptr[3:0]][7:2]+1'b1;
		else if(count!=0)
			count<=count-1;
		else
			count<=0;
	end
end

assign full=(wr_ptr[4]==~rd_ptr[4] && wr_ptr[3:0]==rd_ptr[3:0])?1'b1:1'b0;
assign empty=(wr_ptr == rd_ptr);

endmodule
