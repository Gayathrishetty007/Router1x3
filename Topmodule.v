module router_top(data_in, pkt_valid, clk, resetn, read_enb_0, read_enb_1, read_enb_2, data_out_0, data_out_1,
					data_out_2, vld_out_0, vld_out_1, vld_out_2, err, busy);
	
	input [7:0] data_in;
	input clk, resetn, pkt_valid;
	input read_enb_0, read_enb_1, read_enb_2;
	
	output [7:0] data_out_0, data_out_1, data_out_2;
	output vld_out_0, vld_out_1, vld_out_2;
	output err, busy;
	
	wire [7:0]dout;
	wire[2:0]write_enb;
	
	router_fifo F0( .clk	(clk), .data_out (data_out_0),
					.resetn (resetn), .read_enb (read_enb_0),
					.write_enb (write_enb[0]), .empty (empty_0),
					.full (full_0), .soft_reset (soft_reset_0), 
					.lfd_state (lfd_state), .data_in (dout));

	router_fifo F1( .clk	(clk), .data_out (data_out_1),
					.resetn (resetn), .read_enb (read_enb_1),
					.write_enb (write_enb[1]), .empty (empty_1),
					.full (full_1), .soft_reset (soft_reset_1), 
					.lfd_state (lfd_state), .data_in (dout));
	
	router_fifo F2( .clk	(clk), .data_out (data_out_2),
					.resetn (resetn), .read_enb (read_enb_2),
					.write_enb (write_enb[2]), .empty (empty_2),
					.full (full_2), .soft_reset (soft_reset_2), 
					.lfd_state (lfd_state), .data_in (dout) );
					
	router_sync S1( .clk (clk) , .resetn (resetn),
					.read_enb_0 (read_enb_0), .read_enb_1(read_enb_1),
					.read_enb_2 (read_enb_2), .write_enb (write_enb), 
					.vld_out_0(vld_out_0), .vld_out_1(vld_out_1),
					.vld_out_2(vld_out_2), .detect_add (detect_add),
					.empty_0 (empty_0), .empty_1 (empty_1),
					.empty_2 (empty_2), .write_enb_reg(write_enb_reg),
					.full_0(full_0), .full_1(full_1), .full_2(full_2),
					.fifo_full(fifo_full), .soft_reset_0(soft_reset_0),
					.soft_reset_1(soft_reset_1), .soft_reset_2 (soft_reset_2),
					.data_in (data_in[1:0]));
					
	router_fsm FSM ( .clk (clk), .resetn(resetn),
					 .parity_done (parity_done), .busy(busy),
					 .pkt_valid (pkt_valid), .data_in (data_in[1:0]),
					 .detect_add (detect_add), .write_enb_reg (write_enb_reg),
					 .ld_state (ld_state), .laf_state (laf_state),
					 .lfd_state (lfd_state), .full_state (full_state),
					 .rst_int_reg(rst_int_reg), .fifo_full(fifo_full),
					 .fifo_empty_0 (empty_0), .fifo_empty_1 (empty_1),
					 .fifo_empty_2 (empty_2), .soft_reset_0 (soft_reset_0),
					 .soft_reset_1 (soft_reset_1), .soft_reset_2 (soft_reset_2),
					 .low_pkt_valid(low_pkt_valid));
					 
	router_reg R1( .clk(clk), .resetn(resetn),
						.pkt_valid (pkt_valid), .data_in (data_in),
						.fifo_full (fifo_full), .detect_add (detect_add),
						.ld_state (ld_state) , .laf_state(laf_state),
						.full_state (full_state), .lfd_state (lfd_state),
						.rst_int_reg (rst_int_reg), .err(err), .parity_done (parity_done),
						.low_pkt_valid (low_pkt_valid), .dout(dout)); 
endmodule
	
