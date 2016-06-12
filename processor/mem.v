/* memory */

`timescale 1ps/1ps

// Protocol:
//  set fetchEnable = 1
//      fetchAddr = read address
//
//  A few cycles later:
//      fetchReady = 1
//      fetchData = data
//
module mem(input clk,
    // fetch port
    input fetchEnable,
    input [15:0]fetchAddr,
    output fetchReady,
    output [15:0]fetchData,
    output [15:0]fetchOutpc,

    // 2nd fetch port
    input fetchEnable1,
    input [15:0]fetchAddr1,
    output fetchReady1,
    output [15:0]fetchData1,
    output [15:0]fetchOutpc1,

    // load port 0
    input loadEnable0,
    input [15:0]loadAddr0,
    output loadReady0,
    output [15:0]loadData0,

    // load port 1
    input loadEnable1,
    input [15:0]loadAddr1,
    output loadReady1,
    output [15:0]loadData1

);

    reg [15:0]data[1023:0];

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("testing/mem.hex",data);
    end

    reg [15:0]fetchPtr = 16'hxxxx;
    reg [15:0]fetchCounter = 0;

    assign fetchReady = (fetchCounter == 1);
    assign fetchData = (fetchCounter == 1) ? data[fetchPtr] : 16'hxxxx;
    assign fetchOutpc = (fetchCounter == 1) ? fetchPtr : 16'hxxxx;

    reg [15:0]fetchPtr1 = 16'hxxxx;
    reg [15:0]fetchCounter1 = 0;

    assign fetchReady1 = (fetchCounter1 == 1);
    assign fetchData1 = (fetchCounter1 == 1) ? data[fetchPtr1] : 16'hxxxx;
    assign fetchOutpc1 = (fetchCounter1 == 1) ? fetchPtr1 : 16'hxxxx;
    
    always @(posedge clk) begin
        if (fetchEnable) begin
            fetchPtr <= fetchAddr;
            fetchCounter <= 1;
        end else begin
            if (fetchCounter > 0) begin
                fetchCounter <= fetchCounter - 1;
            end else begin
                fetchPtr <= 16'hxxxx;
            end
        end
        
	if (fetchEnable1) begin
            fetchPtr1 <= fetchAddr1;
            fetchCounter1 <= 1;
        end else begin
            if (fetchCounter1 > 0) begin
                fetchCounter1 <= fetchCounter1 - 1;
            end else begin
                fetchPtr1 <= 16'hxxxx;
            end
        end
    end

    reg [15:0]loadPtr0 = 16'hxxxx;
    reg [15:0]loadCounter0 = 0;

    reg [15:0]loadPtr1 = 16'hxxxx;
    reg [15:0]loadCounter1 = 0;

    assign loadReady0 = (loadCounter0 == 1);
    assign loadData0 = (loadCounter0 == 1) ? data[loadPtr0] : 16'hxxxx;

    assign loadReady1 = (loadCounter1 == 1);
    assign loadData1 = (loadCounter1 == 1) ? data[loadPtr1] : 16'hxxxx;
    
    always @(posedge clk) begin
        if (loadEnable0) begin
            loadPtr0 <= loadAddr0;
            loadCounter0 <= 100;
        end else begin
            if (loadCounter0 > 0) begin
                loadCounter0 <= loadCounter0 - 1;
            end else begin
                loadPtr0 <= 16'hxxxx;
            end
        end
        if (loadEnable1) begin
            loadPtr1 <= loadAddr1;
            loadCounter1 <= 100;
        end else begin
            if (loadCounter1 > 0) begin
                loadCounter1 <= loadCounter1 - 1;
            end else begin
                loadPtr1 <= 16'hxxxx;
            end
        end
    end

endmodule
