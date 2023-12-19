`timescale 1ns / 1ps
module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    output  reg                     awready,
    output  reg                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  reg                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  reg                      rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,    
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  reg                     ss_tready, 
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  reg  [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire  [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n,
    //output wire [(pDATA_WIDTH-1):0]   dadadata,
    //output wire [(pDATA_WIDTH-1):0]   dadadata1,
    //output wire [(pDATA_WIDTH-1):0]   dadadata2,
    output reg [3:0] cnt,
    output reg [(pDATA_WIDTH-1):0] y,
    output reg [2:0] ap_reg
        //output wire  dddd,
        //output wire [(pDATA_WIDTH-1):0] dadadata3
);

reg [3:0] index, n_index;
reg [12:0] times;
reg [1:0] state, n_state;
//wire [2:0] ap;

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
        ap_reg <= 4;
    else if(wdata[0] && times==5)
        ap_reg <= 3'd1;
    else if(sm_tlast && times==610 && cnt>=7 || sm_tlast)
        ap_reg <= rdata[2:0];
    else if(wdata[0] && times>5)
        ap_reg <= 3'd0;
    else
        ap_reg <= 4;
end


//assign ap = rdata[2:0];

assign sm_tdata = y;
assign sm_tvalid = (sm_tready&&ss_tready&&(times>13'd10))? 1 : 0;
assign sm_tlast = (times>13'd609 && cnt >=1)? 1 : 0;

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
        awready <= 0;
    else if(awvalid)
        awready <= 1;
    else
        awready <= 0;
end


always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
        wready <= 0;
    else if(wvalid)
        wready <= 1;
    else
        wready <= 0;
end 

always@(*)begin 
    case(awaddr)
        12'h20: tap_A = 12'h0;  
        12'h24: tap_A = 12'h4;  
        12'h28: tap_A = 12'h8;  
        12'h2c: tap_A = 12'hc;  
        12'h30: tap_A = 12'h10; 
        12'h34: tap_A = 12'h14; 
        12'h38: tap_A = 12'h18; 
        12'h3c: tap_A = 12'h1c; 
        12'h40: tap_A = 12'h20; 
        12'h44: tap_A = 12'h24; 
        12'h48: tap_A = 12'h28; 
    default : tap_A = 12'hfff;
    endcase
end


//assign rdata = tap_Do;
assign tap_Di = wdata;
assign tap_EN = 1;
assign tap_WE = (wready)? 4'b1111:4'b0000;

assign data = data_Do;
assign data_Di = ss_tdata;
assign data_EN = 1;
assign data_WE = (sm_tready)? 4'b1111:4'b0000;



/**********************axi_lite_read************************/
always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
        arready <= 0;
    else if(arvalid)
        arready <= 1;
    else
        arready <= 0;
end

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
        rvalid <= 0;
    else if(arvalid)
        rvalid <= 1;
    else
        rvalid <= 0;
end

always@(*)begin 
    case(araddr)
        12'h20: tap_A = 12'h0;  
        12'h24: tap_A = 12'h4;  
        12'h28: tap_A = 12'h8;  
        12'h2c: tap_A = 12'hc;  
        12'h30: tap_A = 12'h10; 
        12'h34: tap_A = 12'h14; 
        12'h38: tap_A = 12'h18; 
        12'h3c: tap_A = 12'h1c; 
        12'h40: tap_A = 12'h20; 
        12'h44: tap_A = 12'h24; 
        12'h48: tap_A = 12'h28; 
    default : tap_A = 12'hfff;
    endcase
end

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n) begin
        cnt <= 0;
        times <= 0;
    end

    else begin
        cnt <= (cnt==4'd11)? 4'd0 : cnt + 4'd1;
        times <= (cnt==4'd11)? times + 13'd1 : times;
    end    
end

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n) begin
        ss_tready <= 0;
    end
    else if(times>13'd9) begin
        ss_tready <= (index == 4'd10)? 1 : 0;
    end    
    else begin
        ss_tready <= 0;
    end    
end


reg [(pDATA_WIDTH-1):0] h [0:10];

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n)
    begin
        h[0] <= 32'd0;
        h[1] <= 32'd0;
        h[2] <= 32'd0;
        h[3] <= 32'd0;
        h[4] <= 32'd0;
        h[5] <= 32'd0;
        h[6] <= 32'd0;
        h[7] <= 32'd0;
        h[8] <= 32'd0;
        h[9] <= 32'd0;
        h[10] <= 32'd0;
end
    else if(rvalid) 
    begin
        h[0] <= (ss_tlast)? h[0] : tap_Do;
        h[1] <= (ss_tlast)? h[1] : h[0];
        h[2] <= (ss_tlast)? h[2] : h[1];
        h[3] <= (ss_tlast)? h[3] : h[2];
        h[4] <= (ss_tlast)? h[4] : h[3];
        h[5] <= (ss_tlast)? h[5] : h[4];
        h[6] <= (ss_tlast)? h[6] : h[5];
        h[7] <= (ss_tlast)? h[7] : h[6];
        h[8] <= (ss_tlast)? h[8] : h[7];
        h[9] <= (ss_tlast)? h[9] : h[8];
        h[10] <= (ss_tlast)? h[10] : h[9];
        end
	else begin
	h[0] <= h[0];
        h[1] <= h[1];
        h[2] <= h[2];
        h[3] <= h[3];
        h[4] <= h[4];
        h[5] <= h[5];
        h[6] <= h[6];
        h[7] <= h[7];
        h[8] <= h[8];
        h[9] <= h[9];
        h[10] <= h[10]; 
        end
end

reg [(pDATA_WIDTH-1):0] x [0:10];

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n) 
    begin
        x[0] <= 32'd0;
        x[1] <= 32'd0;
        x[2] <= 32'd0;
        x[3] <= 32'd0;
        x[4] <= 32'd0;
        x[5] <= 32'd0;
        x[6] <= 32'd0;
        x[7] <= 32'd0;
        x[8] <= 32'd0;
        x[9] <= 32'd0;
        x[10] <= 32'd0;
end
    else if(ss_tready) 
    begin
        x[0] <= ss_tdata;
        x[1] <= x[0];
        x[2] <= x[1];
        x[3] <= x[2];
        x[4] <= x[3];
        x[5] <= x[4];
        x[6] <= x[5];
        x[7] <= x[6];
        x[8] <= x[7];
        x[9] <= x[8];
        x[10] <= x[9];
end
    else
    begin
        x[0] <= x[0];
        x[1] <= x[1];
        x[2] <= x[2];
        x[3] <= x[3];
        x[4] <= x[4];
        x[5] <= x[5];
        x[6] <= x[6];
        x[7] <= x[7];
        x[8] <= x[8];
        x[9] <= x[9];
        x[10] <= x[10];
end
end


always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n) 
    begin
        index <= 4'd0;
end
    else
    begin
        index <= n_index;
end
end


always@(*)
case(index)
4'd0: n_index = (ss_tready)?4'd0:4'd1;
4'd1: n_index = (ss_tready)?4'd0:4'd2;
4'd2: n_index = (ss_tready)?4'd0:4'd3;
4'd3: n_index = (ss_tready)?4'd0:4'd4;
4'd4: n_index = (ss_tready)?4'd0:4'd5;
4'd5: n_index = (ss_tready)?4'd0:4'd6;
4'd6: n_index = (ss_tready)?4'd0:4'd7;
4'd7: n_index = (ss_tready)?4'd0:4'd8;
4'd8: n_index = (ss_tready)?4'd0:4'd9;
4'd9: n_index = (ss_tready)?4'd0:4'd10;
4'd10: n_index = 4'd0;
endcase

always@(posedge axis_clk or negedge axis_rst_n)begin 
    if(!axis_rst_n) 
    begin
        y <= 32'd0;
end
 
    else if(ss_tready)
    begin
        y <= 32'd0;
end
    else
    begin
        y <= y + h[index] * x[index];
end
end

assign rdata = (sm_tlast && times==610 && cnt>=7)? 4 : ((sm_tlast)? 2 : ((wdata[0])? 0 : ((arvalid && rready)? tap_Do : 4)));
endmodule


