`timescale 1ns/10ps
module DelayChain (
  input iClk,
  input iRsn,
  input iEnSample,

  input signed [2:0] iFirIn,

  output signed [2:0] oDelay1,
  output signed [2:0] oDelay2,
  output signed [2:0] oDelay3,
  output signed [2:0] oDelay4,
  output signed [2:0] oDelay5,
  output signed [2:0] oDelay6,
  output signed [2:0] oDelay7,
  output signed [2:0] oDelay8,
  output signed [2:0] oDelay9,
  output signed [2:0] oDelay10,
  output signed [2:0] oDelay11,
  output signed [2:0] oDelay12,
  output signed [2:0] oDelay13,
  output signed [2:0] oDelay14,
  output signed [2:0] oDelay15,
  output signed [2:0] oDelay16,
  output signed [2:0] oDelay17,
  output signed [2:0] oDelay18,
  output signed [2:0] oDelay19,
  output signed [2:0] oDelay20,
  output signed [2:0] oDelay21,
  output signed [2:0] oDelay22,
  output signed [2:0] oDelay23,
  output signed [2:0] oDelay24,
  output signed [2:0] oDelay25,
  output signed [2:0] oDelay26,
  output signed [2:0] oDelay27,
  output signed [2:0] oDelay28,
  output signed [2:0] oDelay29,
  output signed [2:0] oDelay30,
  output signed [2:0] oDelay31,
  output signed [2:0] oDelay32,
  output signed [2:0] oDelay33,
  output signed [2:0] oDelay34,
  output signed [2:0] oDelay35,
  output signed [2:0] oDelay36,
  output signed [2:0] oDelay37,
  output signed [2:0] oDelay38,
  output signed [2:0] oDelay39,
  output signed [2:0] oDelay40
  );

  reg signed [2:0] rSftReg [0:39];
  integer i;

  always @(posedge iClk) begin
    if(!iRsn) begin //초기화
        for(i=0;i<40;i=i+1)
            rSftReg[i] <= 0;
    end
    else if(iEnSample) begin //iEnSample이 1일때만 쉬프트
        rSftReg[0] <= iFirIn; 
        for(i=1;i<40;i=i+1)
            rSftReg[i] <= rSftReg[i-1];
    end
  end
  
  assign oDelay1 = rSftReg[0];
  assign oDelay2 = rSftReg[1];
  assign oDelay3 = rSftReg[2];
  assign oDelay4 = rSftReg[3];
  assign oDelay5 = rSftReg[4];
  assign oDelay6 = rSftReg[5];
  assign oDelay7 = rSftReg[6];
  assign oDelay8 = rSftReg[7];
  assign oDelay9 = rSftReg[8];
  assign oDelay10 = rSftReg[9];
  assign oDelay11 = rSftReg[10];
  assign oDelay12 = rSftReg[11];
  assign oDelay13 = rSftReg[12];
  assign oDelay14 = rSftReg[13];
  assign oDelay15 = rSftReg[14];
  assign oDelay16 = rSftReg[15];
  assign oDelay17 = rSftReg[16];
  assign oDelay18 = rSftReg[17];
  assign oDelay19 = rSftReg[18];
  assign oDelay20 = rSftReg[19];
  assign oDelay21 = rSftReg[20];
  assign oDelay22 = rSftReg[21];
  assign oDelay23 = rSftReg[22];
  assign oDelay24 = rSftReg[23];
  assign oDelay25 = rSftReg[24];
  assign oDelay26 = rSftReg[25];
  assign oDelay27 = rSftReg[26];
  assign oDelay28 = rSftReg[27];
  assign oDelay29 = rSftReg[28];
  assign oDelay30 = rSftReg[29];
  assign oDelay31 = rSftReg[30];
  assign oDelay32 = rSftReg[31];
  assign oDelay33 = rSftReg[32];
  assign oDelay34 = rSftReg[33];
  assign oDelay35 = rSftReg[34];
  assign oDelay36 = rSftReg[35];
  assign oDelay37 = rSftReg[36];
  assign oDelay38 = rSftReg[37];
  assign oDelay39 = rSftReg[38];
  assign oDelay40 = rSftReg[39];


endmodule