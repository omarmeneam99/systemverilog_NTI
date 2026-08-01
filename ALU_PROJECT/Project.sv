module Project;
logic [15:0] A, B;
logic [3:0]  ALU_FUN;
logic        CLK;
wire         Arith_Flag, Carry_Flag, Logic_Flag, CMP_Flag, Shift_Flag;
wire [15:0]  ALU_OUT;

ALU_16B DUT(.A(A),.B(B),.ALU_FUN(ALU_FUN),.CLK(CLK),.Arith_Flag(Arith_Flag),.Carry_Flag(Carry_Flag),.Logic_Flag(Logic_Flag),.CMP_Flag(CMP_Flag),.Shift_Flag(Shift_Flag),.ALU_OUT(ALU_OUT));

logic checkflag,checkout;

//clock
initial begin
    CLK=0;
    forever begin
        #5 CLK=~CLK;
    end
end

//inputs for mailbox
typedef struct {
    logic [15:0] A;
    logic [15:0] B;
    logic [3:0] ALU_FUN;
} inputs; //

//expected for mailbox
typedef struct {
    logic [15:0] result;
    logic        arith;
    logic        carry;
    logic        logic_flag;
    logic        cmp;
    logic        shift;
} expected; //

mailbox #(inputs) gen2drive; // random inputs to drive to dut
mailbox #(inputs) gen2pred; // random inputs for golden model
mailbox #(expected) pred2check; // give golden model output to check

//generate random inputs
task generator(int count);
        inputs ip;
        repeat(count)begin
            ip.A=$random;
            ip.B=$random;
            ip.ALU_FUN=$random;
            gen2drive.put(ip);
            gen2pred.put(ip);
        end
endtask : generator

//drive inputs to dut
task driver();
    inputs ip;
	forever begin
        gen2drive.get(ip);    
        A = ip.A;
        B = ip.B;
        ALU_FUN = ip.ALU_FUN;
        @(negedge CLK);
	end
endtask : driver

//monitor all signals
task monitor_inout();
    forever begin
        @(posedge CLK);
        #1;
        $display("[ACTUAL] A=%h B=%h OPCODE=%b | OUT=%h | Flags -> Arith=%b Carry=%b Logic=%b CMP=%b Shift=%b | Scoreboard flag_check=%b output_check=%b",A, B, ALU_FUN,ALU_OUT,Arith_Flag,Carry_Flag,Logic_Flag,CMP_Flag,Shift_Flag,checkflag,checkout);
    end
endtask : monitor_inout

//golden model :take from generate , give to check
task predictor();
    inputs ip;
    expected golden;
    forever begin
    gen2pred.get(ip);
    golden.result=0; golden.arith=0; golden.carry=0; golden.logic_flag=0; golden.cmp=0; golden.shift=0;
    case(ip.ALU_FUN)
    4'b0000: begin
        {golden.carry,golden.result} = ip.A+ip.B;
		golden.arith = 1'b1 ;
    end
    4'b0001: begin
        {golden.carry,golden.result} = ip.A-ip.B;
		golden.arith = 1'b1 ;
    end
    4'b0010: begin 
        golden.result = ip.A*ip.B;
		golden.arith = 1'b1 ;
    end
    4'b0011: begin 
        golden.result = ip.A/ip.B;
		golden.arith = 1'b1 ;
    end
    4'b0100: begin 
        golden.result = ip.A & ip.B;
		golden.logic_flag = 1'b1 ;
    end
    4'b0101: begin 
        golden.result = ip.A | ip.B;
		golden.logic_flag = 1'b1 ;
    end
    4'b0110: begin 
        golden.result = ~ (ip.A & ip.B);
		golden.logic_flag = 1'b1 ;
    end
    4'b0111: begin 
        golden.result = ~ (ip.A | ip.B);
		golden.logic_flag = 1'b1 ;
    end
    4'b1000: begin 
        golden.result =  (ip.A ^ ip.B);
		golden.logic_flag = 1'b1 ;
    end
    4'b1001: begin 
        golden.result = ~ (ip.A ^ ip.B);
		golden.logic_flag = 1'b1 ;
    end
    4'b1010: begin 
        golden.cmp = 1'b1 ;
              if (ip.A==ip.B)                               
                 golden.result= 16'b1;
              else
                 golden.result = 16'b0;
    end
    4'b1011: begin 
        golden.cmp = 1'b1 ;
               if (ip.A>ip.B)
                 golden.result = 16'b10;                  
               else
                 golden.result = 16'b0;
    end
    4'b1100: begin 
        golden.cmp = 1'b1 ;
               if (ip.A<ip.B)                                 
                 golden.result = 16'b11;
               else
                 golden.result = 16'b0;
    end
    4'b1101: begin 
        golden.shift = 1'b1 ;
        golden.result = ip.A>>1;
    end
    4'b1110: begin 
        golden.shift = 1'b1 ;
        golden.result = ip.A<<1;
    end
    default: begin 
        golden.carry = 1'b0 ;
        golden.arith = 1'b0 ;
        golden.logic_flag = 1'b0 ; 
        golden.cmp   = 1'b0 ;
        golden.shift = 1'b0 ;
        golden.result = 16'b0;
    end
    endcase
    // $display("[golden] A=%h B=%h OPCODE=%b | OUT=%h | Flags -> Arith=%b Carry=%b Logic=%b CMP=%b Shift=%b",ip.A, ip.B, ip.ALU_FUN,golden.result,golden.arith,golden.carry,golden.logic_flag,golden.cmp,golden.shift);
    pred2check.put(golden);
    end
endtask : predictor

//compare : take from predictor and dut and display comparing results 
task check();
    expected golden;
	forever begin
        pred2check.get(golden);
        @(posedge CLK);
        #1;
		if (golden.result == ALU_OUT && golden.arith == Arith_Flag && golden.carry == Carry_Flag && golden.logic_flag == Logic_Flag && golden.cmp == CMP_Flag && golden.shift  == Shift_Flag) begin
            checkflag =1;
            checkout=1;
            #1 $display("[CHECK]%t pass flags and output ",$time);
        end 
        else begin
            checkflag=0;
            checkout=0;
            #1 $display("[CHECK]%t fail flags and output ",$time);
        end 
    end
endtask : check

initial begin
    gen2drive = new();
    gen2pred =new();
    pred2check=new();
    fork
        monitor_inout();
        generator(100);
        driver();
        predictor();
        check();
    join_any
end

initial begin
    #1000;
    $stop;
end
endmodule
