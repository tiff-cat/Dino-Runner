//module dino_jump
//	(
//		CLOCK_50,						//	On Board 50 MHz
//		// Your inputs and outputs here
//        KEY,
//        SW,
//		// The ports below are for the VGA output.  Do not change.
//		VGA_CLK,   						//	VGA Clock
//		VGA_HS,							//	VGA H_SYNC
//		VGA_VS,							//	VGA V_SYNC
//		VGA_BLANK_N,						//	VGA BLANK
//		VGA_SYNC_N,						//	VGA SYNC
//		VGA_R,   						//	VGA Red[9:0]
//		VGA_G,	 						//	VGA Green[9:0]
//		VGA_B,   						//	VGA Blue[9:0]
//		PS2_DAT,
//		PS2_CLK
//	);
//
//	input			CLOCK_50;				//	50 MHz
//	input   [9:0]   SW;
//	input   [3:0]   KEY;
//	input PS2_CLK;
//	input PS2_DAT;
//
//	// Declare your inputs and outputs here
//	// Do not change the following outputs
//	output			VGA_CLK;   				//	VGA Clock
//	output			VGA_HS;					//	VGA H_SYNC
//	output			VGA_VS;					//	VGA V_SYNC
//	output			VGA_BLANK_N;				//	VGA BLANK
//	output			VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
//	
//	wire resetn;
//	assign resetn = KEY[0];
//	//assign jump = KEY[3];
//	
//	// Create the colour, x, y and writeEn wires that are inputs to the controller.
//	wire [2:0] colour;
//	wire [7:0] x;
//	wire [7:0] y;
//	wire writeEn;
//	wire load_colour;
//	wire enable;
//
//	// Create an Instance of a VGA controller - there can be only one!
//	// Define the number of colours as well as the initial background
//	// image file (.MIF) for the controller.
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
//			
//	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
//	// for the VGA controller, in addition to any other functionality your design may require.
//	
//	
//	// KEYBOARD SET UP
//	 wire valid, makeBreak;
//	 keyboard_press_driver kpd(CLOCK_50, valid, makeBreak, outCode, PS2_DAT, PS2_CLK, resetn);
//	 localparam SPACE = 8'h5A;	
//
//	 wire jump_key;
//	 assign jump_key = valid && makeBreak && (outCode == SPACE);
//	 reg jump;
//	 
//	 always @(posedge jump_key)
//	 begin
//		if(jump_key)
//			jump <= 1'b1;
//		else
//			jump <= 1'b0;
//	 end
//	
//    // Instantiate datapath
//	 datapath d(enable, CLOCK_50, load_colour, resetn, KEY[3], x, y, colour);
//	 
//	 //datapath d(enable, CLOCK_50, load_colour, resetn, up_enable, down_enable, x, y, colour);
//	 
//	 control c(enable, CLOCK_50, resetn, ~KEY[1], load_colour, writeEn); 
//	 
//	
//
//    // Instantiate FSM control
// 
//endmodule

// CREATE 4X4 BOX

//-------------------------------------------------------------
module length_counter(enable, clk, reset, out);
	input reset, clk, enable;
	output reg [1:0] out;
	
	always @(posedge clk)
	begin
		if(~reset)
			out <= 2'b0;
		else if (enable)
		begin
			if (out == 2'b11)
				out <= 2'b0;
			else 
				out <= out + 1'b1;
		end
	end
			
endmodule

module rate_counter(enable, clk, reset, out);
	input clk, reset, enable;
	output reg [1:0] out;
	
	always @(posedge clk)
	begin
		if (~reset)
			out <= 2'b11;
		else if (enable)
		begin
			if (out == 2'b0)
				out <= 2'b11;
			else
				out <= out - 1'b1;
		end
	end
endmodule

//-------------------------------------------------------------


// REDRAW THE BOX AT CORRECT RATE
//-------------------------------------------------------------
module delay_counter(enable, clk, reset, out, q);
	input enable, clk, reset;
	
	// 1/60 second equal to 60hz
	// 50Mhz/60hz = 833333.333
	// ceil(log2(833333.333)) = 20
	output reg [19:0] out;
	output reg q;
	
	always @(posedge clk)
	begin 
		if(~reset) begin
			out <= 20'd0;
			q <= 1'b0;
		end
		else if (enable)
		begin
			if (out == 20'b0) begin
				out <= 20'd1666666;
				q <= 1'b1;
			end
			else begin
				out <= out - 1'b1;
				q <= 1'b0;
			end
		end
	end
endmodule

module frame_counter(enable, clk, reset, out);
	input enable, clk, reset;
	output reg [3:0] out;
	
	always @(posedge clk)
	begin
		if(~reset)
			out <= 4'b0;
		else if(enable)
		begin
		  if(out == 4'd7)
			  out <= 4'b0;
		  else
			  out <= out + 1'b1;
		end
   end
endmodule

//-------------------------------------------------------------



// Counter - Jump
//-------------------------------------------------------------

module jump_counter(enable, clk, reset, jump_sig, out);
	input enable, clk, reset, jump_sig;
	output reg [7:0] out;
	
	always @(negedge clk)
	begin
		if(~reset)
			out <= 8'd110;
		
		else if (enable)
		begin
			if (~jump_sig)
			begin
				 if (out == 8'd40)
					out <= 8'd110;
				 else if(8'd40 < out)
					out <= out - 1'b1;
			end
			else
			begin
				if (out < 8'd111)
					out <= out + 1'b1;
			end
			
		end
		
	end
endmodule
				
		
// DATAPATH - DRAW BOX
//-------------------------------------------------------------
module lab7_part2_datapath (x_in, y_in, c_in, load_colour, clk, reset, enable, x_out, y_out, c_out);
	input clk, enable, load_colour, reset;
	input [2:0] c_in;
	input [7:0] x_in, y_in;
	 
	output [2:0] c_out;
	output [7:0] x_out, y_out;
	
	reg [7:0] x_init, y_init, c_init;
	
	wire [1:0] width_out;
	wire [1:0] rate_out;
	wire [1:0] height_out;
	
	
	always @(posedge clk)
	begin
		if(~reset)
		begin
			x_init <= 8'b0;
			y_init <= 8'b0;
			c_init <= 3'b0;
		end
		else
		begin
			x_init <= x_in;
			y_init <= y_in;
			
			if (load_colour)
				c_init <= c_in;
		end
	end
	
	length_counter wc(.enable(enable), .clk(clk), .reset(reset), .out(width_out));
	
	rate_counter next_row(.enable(enable), .clk(clk), .reset(reset), .out(rate_out));
	
	assign y_enable = (rate_out == 2'b0) ? 1 : 0;
	
	length_counter hc(.enable(y_enable), .clk(clk), .reset(reset), .out(height_out));
	
	assign x_out = x_init + width_out;
	assign y_out = y_init + height_out;
	assign c_out = c_init;
endmodule
//-------------------------------------------------------------

module dino_datapath(enable, clk, load_colour,  reset, jump_sig,  x_out, y_out, c_out);
	input enable, clk, reset, load_colour, jump_sig;

	output [7:0] x_out;
	output reg [6:0] y_out;
	output [2:0] c_out;
	
	wire [19:0] delay_value;
	wire delay_out;
	wire [3:0] frame_out;
	wire [7:0] jump_out;
	wire [2:0] col;
	wire [7:0] y_out_temp;
	
	delay_counter dc(.enable(enable), .clk(clk), .reset(reset), .out(delay_value), .q(delay_out));
	
	assign frame_en = (delay_value == 20'd0) ? 1 : 0;
	
	frame_counter fc(.enable(frame_en), .clk(clk), .reset(reset), .out(frame_out));
	
	assign jump_en = (frame_out == 4'd7) ? 1 : 0;
//	assign jump_en = (delay_out == 1'b1) ? 1 : 0;
	
	jump_counter jc(
		.clk(jump_en), 
		.enable(enable), 
		.reset(reset), 
		.jump_sig(jump_sig),
		.out(jump_out)
	);
	
	//track_height j_height(.clk(clk), .reset(reset), .y_val(jump_out), .jump_sig(jump_out));
	
	assign col = (frame_out == 4'd7) ? 3'b000 : 3'b010;
//	assign col = (delay_out == 1'b1) ? 3'b000 : 3'b010;
	
	lab7_part2_datapath d0(
		.x_in(8'd24), 
		.y_in(jump_out), 
		.c_in(col), 
		.load_colour(load_colour), 
		.clk(clk), 
		.reset(reset), 
		.enable(enable), 
		.x_out(x_out), 
		.y_out(y_out_temp), 
		.c_out(c_out)
	);
	
	always @(*)
		y_out = y_out_temp[6:0];
endmodule

module dino_control(pause, enable, clk, reset, go, load_colour, plot);
	input clk, reset, go, pause;
	output reg enable, plot, load_colour;
	
	reg [2:0] current_state, next_state;
	
	localparam S_LOAD_DINO = 3'd0,
				  S_LOAD_DINO_WAIT = 3'd1,
				  S_JUMP_DINO = 3'd2,
				  PAUSE_STATE = 3'd3;
				  
				  
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD_DINO: next_state = go ? S_LOAD_DINO_WAIT : S_LOAD_DINO;
			S_LOAD_DINO_WAIT: next_state = go ? S_JUMP_DINO : S_LOAD_DINO_WAIT;
			S_JUMP_DINO: next_state = pause ? PAUSE_STATE : S_JUMP_DINO;
			PAUSE_STATE: next_state = pause ? PAUSE_STATE: S_JUMP_DINO;
		default: next_state = S_LOAD_DINO;
		endcase
	end
	
	always @(*)
	begin: enable_signals

		enable = 1'b0;
		load_colour = 1'b0;
		plot = 1'b0;
		
		case(current_state)
			S_JUMP_DINO: begin
				load_colour = 1'b1;
				enable = 1'b1;
				plot = 1'b1;
			end
			PAUSE_STATE: begin
				enable = 1'b0;
			end
		endcase
	end
	
	always @(posedge clk)
	begin: state_FFs
		if(~reset)
			current_state <= S_LOAD_DINO;
		else
			current_state <= next_state;
	end
endmodule
	
				





