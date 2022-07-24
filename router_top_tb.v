// Testbench
module router_top_tb;

  parameter T = 20,
            DECODE_ADDRESS = 3'b000,
            LOAD_FIRST_DATA = 3'b001,
			WAIT_TILL_EMPTY = 3'b010,
			LOAD_DATA = 3'b011,
			FIFO_FULL_STATE = 3'b100,
			LOAD_PARITY = 3'b101,
			LOAD_AFTER_FULL = 3'b110,
			CHECK_PARITY_ERROR = 3'b111;
  integer i;

  reg [7:0] data_in;
  reg clock, resetn, pkt_valid, read_enb_0, read_enb_1, read_enb_2;
  wire [7:0] data_out_0, data_out_1, data_out_2;
  wire vld_out_0, vld_out_1, vld_out_2, error, busy;
  
  event e1, e2;

  router_top ROUTER_DUT(.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2), .data_in(data_in), .data_out_0(data_out_0), .data_out_1(data_out_1), .data_out_2(data_out_2), .vld_out_0(vld_out_0), .vld_out_1(vld_out_1), .vld_out_2(vld_out_2), .error(error), .busy(busy));
  
  reg [7*20:0] string;

  always@(ROUTER_DUT.ROUTER_FSM.present_state)
    begin
      case(ROUTER_DUT.ROUTER_FSM.present_state)
        DECODE_ADDRESS :     begin 
                               $write("DECODE_ADDRESS > ");             
                               string = "DA";  
                             end
        LOAD_FIRST_DATA :    begin 
                               $write("LOAD_FIRST_DATA > ");            
                               string = "LFD";  
                             end
        WAIT_TILL_EMPTY :    begin 
                               $write("WAIT_TILL_EMPTY > ");            
                               string = "WTE";  
                             end
        LOAD_DATA :          begin 
                               $write("LOAD_DATA > ");                  
                               string = "LD";  
                             end
        FIFO_FULL_STATE :    begin 
                               $write("FIFO_FULL_STATE > ");                
                               string = "FFS";  
                             end
        LOAD_PARITY :        begin 
                               $write("LOAD_PARITY > ");            
                               string = "LP"; 
                             end
        LOAD_AFTER_FULL :    begin 
                               $write("LOAD_AFTER_FULL > ");         
                               string = "LAF";  
                             end
        CHECK_PARITY_ERROR : begin 
                               $write("CHECK_PARITY_ERROR > ");            
                               string = "CPE";  
                             end
      endcase
    end

  initial
    begin
	  clock = 1'b0;
	  forever #(T/2) clock = ~clock;
	end

  task initialize;
    {pkt_valid, read_enb_0, read_enb_1, read_enb_2, resetn} = 5'b1;
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
  
  task packet_generation(input [5:0] x);
    reg [7:0] payload_data, parity, header;
	reg [5:0] payload_len;
	reg [1:0] addr;
	begin
	  @(negedge clock);
	    wait(~busy)
	  @(negedge clock);
	    begin
		  payload_len = x;
		  addr = 2'b01;
		  header = {payload_len, addr};
		  parity = 0;
		  data_in = header;
		  pkt_valid = 1;
		  parity = parity ^ header;
		end
	  @(negedge clock);
	    wait(~busy)
	  for(i=0; i<payload_len; i=i+1)
	    begin
		  @(negedge clock);
		    begin
		      wait(~busy)
			  payload_data = {$random} % 256;
			  data_in = payload_data;
			  parity = parity ^ payload_data;
			end
		end
	  @(negedge clock);
	    begin
	      wait(~busy)
		  pkt_valid = 0;
		  data_in = parity;
		end
	end
  endtask
  
  task pkt_gen_17_with_event;
    reg [7:0] payload_data, parity, header;
	reg [5:0] payload_len;
	reg [1:0] addr;
	begin
	  @(negedge clock);
	    wait(~busy)
	  @(negedge clock);
	    begin
		  payload_len = 6'd17;
		  addr = 2'b01;
		  header = {payload_len, addr};
		  parity = 0;
		  data_in = header;
		  pkt_valid = 1;
		  parity = parity ^ header;
		end
	  @(negedge clock);
	    wait(~busy)
	  for(i=0; i<payload_len; i=i+1)
	    begin
		  @(negedge clock);
		    begin
		      wait(~busy)
			  payload_data = {$random} % 256;
			  data_in = payload_data;
			  parity = parity ^ payload_data;
			end
		end
	  ->e1;
	  @(negedge clock);
	    begin
	      wait(~busy)
		  pkt_valid = 0;
		  data_in = parity;
		end
	end
  endtask
  
  task random_pkt_with_event;
    reg [7:0] payload_data, parity, header;
	reg [5:0] payload_len;
	reg [1:0] addr;
	begin
	  ->e2;
	  @(negedge clock);
	    wait(~busy)
	  @(negedge clock);
	    begin
		  payload_len = {$random} % 63 + 1;
		  addr = 2'b01;
		  header = {payload_len, addr};
		  parity = 0;
		  data_in = header;
		  pkt_valid = 1;
		  parity = parity ^ header;
		end
	  @(negedge clock);
	    wait(~busy)
	  for(i=0; i<payload_len; i=i+1)
	    begin
		  @(negedge clock);
		    begin
		      wait(~busy)
			  payload_data = {$random} % 256;
			  data_in = payload_data;
			  parity = parity ^ payload_data;
			end
		end
	  @(negedge clock);
	    begin
	      wait(~busy)
		  pkt_valid = 0;
		  data_in = parity;
		end
	end
  endtask
  
  initial
    begin
	  initialize;
	  rst_ip;
	  repeat(3)
	    @(negedge clock);
	  packet_generation(6'd4); // payload length - 4 (payload length < 14)
	  @(negedge clock);
	    read_enb_1 = 1'b1;
	  wait(~vld_out_1)
	  @(negedge clock);
	    read_enb_1 = 1'b0;
		
	  #300;
	  
	  packet_generation(6'd14); // payload length - 14 (payload length = 14)
	  repeat(2)
	    @(negedge clock);
	  read_enb_1 = 1'b1;
	  wait(~vld_out_1)
	  @(negedge clock);
	    read_enb_1 = 1'b0;
		
	  #300;
	  
	  packet_generation(6'd15); // payload length - 15 (payload length > 14)
	  repeat(2)
	    @(negedge clock);
	  read_enb_1 = 1'b1;
	  wait(~vld_out_1)
	  @(negedge clock);
	    read_enb_1 = 1'b0;
		
	  #300;
	  
	  packet_generation(6'd16); // payload length - 16 (payload length > 14)
	  repeat(2)
	    @(negedge clock);
	  read_enb_1 = 1'b1;
	  wait(~vld_out_1)
	  @(negedge clock);
	    read_enb_1 = 1'b0;
	  
	  
	  $display("\n\nPacket Generation with payload 17 (>14) with reading\n");
	  pkt_gen_17_with_event;
	  #300;
	  
	  random_pkt_with_event;
	end

  initial
    begin
	  @(e1)
	    begin
		  @(negedge clock);
	        read_enb_1 = 1'b1;
	      wait(~vld_out_1)
	      @(negedge clock);
	        read_enb_1 = 1'b0;
		end
	end

  initial
    begin
	  @(e2)
	    begin
		  wait(~vld_out_1)
		  wait(vld_out_1)
		  @(negedge clock);
	        read_enb_1 = 1'b1;
	      wait(~vld_out_1)
	      @(negedge clock);
	        read_enb_1 = 1'b0;
		end
	end
endmodule