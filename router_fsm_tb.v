// Testbench
module router_fsm_tb;
  reg [1:0] data_in;
  reg clock, resetn, pkt_valid, parity_done, soft_reset_0, soft_reset_1, soft_reset_2, fifo_full, low_pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2;
  wire busy, detect_add, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state;
  
  parameter T = 20,
            DECODE_ADDRESS = 3'b000,
            LOAD_FIRST_DATA = 3'b001,
			WAIT_TILL_EMPTY = 3'b010,
			LOAD_DATA = 3'b011,
			FIFO_FULL_STATE = 3'b100,
			LOAD_PARITY = 3'b101,
			LOAD_AFTER_FULL = 3'b110,
			CHECK_PARITY_ERROR = 3'b111;

  router_fsm DUT(.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .parity_done(parity_done), .soft_reset_0(soft_reset_0), .soft_reset_1(soft_reset_1), .soft_reset_2(soft_reset_2), .fifo_full(fifo_full), .low_pkt_valid(low_pkt_valid), .fifo_empty_0(fifo_empty_0), .fifo_empty_1(fifo_empty_1), .fifo_empty_2(fifo_empty_2), .data_in(data_in), .busy(busy), .detect_add(detect_add), .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), .write_enb_reg(write_enb_reg), .rst_int_reg(rst_int_reg), .lfd_state(lfd_state));
  
  reg [(18*8)-1:0] present_state, next_state;
  
  initial
    begin
	  clock = 1'b0;
	  forever #(T/2) clock = ~clock; 
	end

  task initialize;
    {pkt_valid, parity_done, soft_reset_0, soft_reset_1, soft_reset_2, fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2, low_pkt_valid, resetn} = 11'd1;
  endtask

  task rst_ip;
    begin
	  repeat(2)
	    begin
	      @(negedge clock);
		    resetn = ~resetn;
		end  
	end
  endtask

  task task1; //DA-LFD-LD-LP-CPE-DA (000 - 001 - 011 - 101 - 111 - 000)
    begin
	  @(negedge clock);
		{data_in, low_pkt_valid, fifo_empty_0, pkt_valid} = 5'd3;
	  #40;
	  @(negedge clock);
		{fifo_full, pkt_valid, low_pkt_valid} = 3'b001;
	end
  endtask

  task task2; //DA-LFD-LD-FFS-LAF-LP-CPE-DA (000 - 001 - 011 - 100 - 110 - 101 - 111 - 000)
    begin
	  @(negedge clock);
		{data_in, low_pkt_valid, fifo_empty_0, pkt_valid} = 5'd3;
	  #40;
	  @(negedge clock);
		fifo_full = 1'b1;
	  #40;
	  @(negedge clock);
	    {fifo_full, pkt_valid, low_pkt_valid} = 3'b001;
	end
  endtask

  task task3; //DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA (000 - 001 - 011 - 100 - 110 - 011 - 101 - 111 - 000)
    begin
	  @(negedge clock);
		{data_in, low_pkt_valid, fifo_empty_0, pkt_valid} = 5'd3;
	  #40;
	  @(negedge clock);
		fifo_full = 1'b1;
	  #40;
	  @(negedge clock);
	    fifo_full = 1'b0;
	  #40;
	  @(negedge clock);
	    pkt_valid = 1'b0;
	end
  endtask

  task task4; //DA-LFD-LD-LP-CPE-FFS-LAF-DA (000 - 001 - 011 - 101 - 111 - 100 - 110 - 000)
    begin
	  @(negedge clock);
		{data_in, low_pkt_valid, fifo_empty_0, pkt_valid} = 5'd3;
	  #40;
	  @(negedge clock);
	    pkt_valid = 1'b0;
	  @(negedge clock);
	    fifo_full = 1'b1;
	  #40;
	  @(negedge clock);
	    {fifo_full, parity_done} = 2'b01;
	end
  endtask
  
  // To display the present state in string format
  always@(DUT.present_state)
    begin
	  case(DUT.present_state)
	    DECODE_ADDRESS: present_state = "DECODE_ADDRESS";
        LOAD_FIRST_DATA: present_state = "LOAD_FIRST_DATA";
	    WAIT_TILL_EMPTY: present_state = "WAIT_TILL_EMPTY";
	    LOAD_DATA: present_state = "LOAD_DATA";
	    FIFO_FULL_STATE: present_state = "FIFO_FULL_STATE";
	    LOAD_PARITY: present_state = "LOAD_PARITY";
	    LOAD_AFTER_FULL: present_state = "LOAD_AFTER_FULL";
	    CHECK_PARITY_ERROR: present_state = "CHECK_PARITY_ERROR";
		default: present_state = "ERROR";
	  endcase
	end

  // To display the next state in string format
  always@(DUT.next_state)
    begin
	  case(DUT.next_state)
	    DECODE_ADDRESS: next_state = "DECODE_ADDRESS";
        LOAD_FIRST_DATA: next_state = "LOAD_FIRST_DATA";
	    WAIT_TILL_EMPTY: next_state = "WAIT_TILL_EMPTY";
	    LOAD_DATA: next_state = "LOAD_DATA";
	    FIFO_FULL_STATE: next_state = "FIFO_FULL_STATE";
	    LOAD_PARITY: next_state = "LOAD_PARITY";
	    LOAD_AFTER_FULL: next_state = "LOAD_AFTER_FULL";
	    CHECK_PARITY_ERROR: next_state = "CHECK_PARITY_ERROR";
		default: next_state = "ERROR";
	  endcase
	end
  
  initial
    begin
	  initialize;  
	  rst_ip;
	  task1; //DA-LFD-LD-LP-CPE-DA
	  #300;

      initialize;
      rst_ip;
	  task2; //DA-LFD-LD-FFS-LAF-LP-CPE-DA
	  #300;

      initialize;
      rst_ip;
	  task3; //DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA
	  #300;

      initialize;
      rst_ip;
	  task4; //DA-LFD-LD-LP-CPE-FFS-LAF-DA
	end

  initial
    $monitor ($time, " resetn= %b, pkt_valid= %b, parity_done= %b, soft_reset_0= %b, low_pkt_valid= %b, fifo_empty_0= %b, present_state= %s, next_state= %s", resetn, pkt_valid, parity_done, soft_reset_0, low_pkt_valid, fifo_empty_0, present_state, next_state);
endmodule