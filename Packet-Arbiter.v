module PacketArbiter#
 ( parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter DLOG2 = 3,
    parameter KLOG2 = 3)
 (  input   clk,  
    input   reset, 
    input  [WIDTH-1:0]  A_tdata,
    input   A_tvalid,
    input   A_tlast,
    output reg A_tready,
   
   input  [WIDTH-1:0]  B_tdata,
   input   B_tvalid,
   input   B_tlast,
   output reg B_tready,
   
   output reg [WIDTH-1:0]  K_tdata,
   output reg K_tvalid,
   output reg K_tlast,
   input   K_tready);
  
   reg [WIDTH-1:0]  A_mem[DEPTH-1:0];
   reg [WIDTH-1:0]  B_mem[DEPTH-1:0];
   reg [WIDTH-1:0]  K_mem[DEPTH-1:0];
  
   reg [DLOG2-1:0]  A_taddr, Atemp_taddr;
   wire [DLOG2-1:0] A_taddr_next, Atemp_taddr_next;
  
   reg [DLOG2-1:0]  B_taddr, Btemp_taddr;
   wire [DLOG2-1:0] B_taddr_next, Btemp_taddr_next;
  
   reg [KLOG2-1:0]  K_taddr, Ktemp_taddr;
   wire [KLOG2-1:0] K_taddr_next, Ktemp_taddr_next;
  
   reg [KLOG2-1:0]  A_temp,B_temp;
   reg grant;
   
   always @(posedge clk, posedge reset) begin
     if (reset) begin
       A_taddr <= 'b0;
       A_tready <= 'b0;
       B_taddr <= 'b0;
       B_tready <= 'b0;
       A_temp <= 'b0;	
       B_temp <= 'b0;	end 
     
    else begin
       if(A_tvalid) begin
         A_tready <= 'b1; 
         A_mem[A_taddr] <= A_tdata;
         A_taddr <= A_taddr_next;    
         if(A_tlast) begin
           A_temp <= A_taddr;
           A_taddr <= 'b0;
           A_tready <= 'b0; end
       end
       if(B_tvalid) begin 
         B_tready <= 'b1; 
         B_mem[B_taddr] <= B_tdata;
         B_taddr <= B_taddr_next;    
         if(B_tlast) begin
          B_temp <= B_taddr;
          B_taddr <= 'b0;
          B_tready <= 'b0; end
      end
    end  
  end
       
  always @(posedge clk, posedge reset) begin
     if (reset) begin
        Atemp_taddr <= 'b0;
        Btemp_taddr <= 'b0;
        Ktemp_taddr <= 'b0;
        grant <= 'b0;
     end
     else if(!grant) begin
         K_mem[Ktemp_taddr] <= A_mem[Atemp_taddr];
         Atemp_taddr <= Atemp_taddr_next; 
         Ktemp_taddr <= Ktemp_taddr_next;
         if((A_temp==Ktemp_taddr) && (A_temp!= 'b0)) begin
            grant <= ~ grant; 
            Ktemp_taddr <= 'b0; end
     end 
     else begin
         K_mem[Ktemp_taddr] <= B_mem[Btemp_taddr];
         Btemp_taddr <= Btemp_taddr_next; 
         Ktemp_taddr <= Ktemp_taddr_next;
         if((B_temp==Ktemp_taddr) && (B_temp!= 'b0)) begin
         grant <= ~ grant; 
         Ktemp_taddr <= 'b0; end
     end
  end
        
  always @(posedge clk, posedge reset) begin
     if (reset) begin
        K_tdata<= 'b0;
        K_tvalid <= 'b0;
        K_tlast <= 'b0;
        K_taddr <= 'b0; end
     else if (K_tready) begin
         K_tlast <= 'b0; 
         K_tvalid <= 'b1;
         K_tdata <= K_mem[K_taddr];
         K_taddr <= K_taddr_next;  
         if((A_temp==K_taddr) && (A_temp!= 'b0) && grant) begin
            K_tlast <= 'b1;
            K_taddr <= 'b0; end 
         else if((B_temp==K_taddr) && (B_temp!= 'b0) && !grant) begin
            K_tlast <= 'b1;
            K_taddr <= 'b0; end 
    end  
  end
    
  assign A_taddr_next = A_taddr+1;
  assign B_taddr_next = B_taddr+1;
  assign K_taddr_next = K_taddr+1;
  assign Atemp_taddr_next = Atemp_taddr+1;
  assign Btemp_taddr_next = Btemp_taddr+1;
  assign Ktemp_taddr_next = Ktemp_taddr+1;
endmodule 
