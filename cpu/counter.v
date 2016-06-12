module counter(input isHalt, input clk, input [2:0]W_v, output cycle);

    reg [22:0] count = 0;
    reg real insCount = 0;

    always @(posedge clk) begin
        insCount <= insCount + W_v;
        if (isHalt) begin
            $display("@%d cycles\t%d instrs\tCPI=%f",count, insCount, count / insCount);
            $finish;
        end
        if (count == 100000) begin
            $display("#ran for 100000 cycles");
            $finish;
        end
        count <= count + 1;
    end

    assign cycle = count;

endmodule

