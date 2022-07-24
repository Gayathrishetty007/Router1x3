#Router1x3
module router_sync(input clk,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,
			input [1:0] data_in,
			output reg [2:0] write_enb,
			output reg fifo_full,
			output vld_out_0,vld_out_1,vld_out_2,
			output reg soft_reset_0,soft_reset_1,soft_reset_2);
	reg [1:0] temp;
	reg [4:0] timer_0,timer_1,timer_2;

always@(posedge clk)
begin
	if(~resetn)
 		temp<=0;
 	else if(detect_add)
 		temp<=data_in;
end

always@(*)
begin
 	fifo_full=0;
 	case(temp)
 		2'b00 :fifo_full=full_0;
 		2'b01 :fifo_full=full_1;
 		2'b10 :fifo_full=full_2;
 	endcase
end

always@(*)
begin
 	if(write_enb_reg)
	begin
		write_enb=0;
		case(temp)
			2'b00 :write_enb=3'b001; //hardcode
			2'b01 :write_enb=3'b010;
			2'b10 :write_enb=3'b100;
		endcase
	end
end

always@(posedge clk)
begin
	if(~resetn)
		timer_0<=0;
	else if(vld_out_0)
	begin
		if(read_enb_0)
		begin
			timer_0<=0;
			soft_reset_0<=0;
		end
		else
		begin
			if(timer_0==30)
			begin
				timer_0<=0;
				soft_reset_0<=1;
			end
			else
			begin
				timer_0<=timer_0+1;
				soft_reset_0<=0;
			end
		end
	end
end

always@(posedge clk)
begin
	if(~resetn)
		timer_1<=0;
	else if(vld_out_1)
	begin
		if(read_enb_1)
		begin
			timer_1<=0;
			soft_reset_1<=0;
		end
		else
		begin
			if(timer_1==30)
			begin
				timer_1<=0;
				soft_reset_1<=1;
			end
			else
			begin
				timer_1<=timer_1+1;
 				soft_reset_1<=0;
 			end
		end
	end
end

always@(posedge clk)
begin
	if(~resetn)
		timer_2<=0;
	else if(vld_out_2)
	begin
		if(read_enb_2)
		begin
			timer_2<=0;
			soft_reset_2<=0;
		end 
		else
 		begin
			if(timer_2==30)
			begin
				timer_2<=0;
				soft_reset_2<=1;
 			end
			else
			begin
				timer_2<=timer_2+1;
				soft_reset_2<=0;
 			end
		end
	end
end

assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;
endmodule

