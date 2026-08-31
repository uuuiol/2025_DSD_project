`timescale 1ns/10ps
module FinalSum(
  input iClk,
  input iRsn,
  input iEnSample,

  input signed [15:0] iMacOut1,
  input signed [15:0] iMacOut2,
  input signed [15:0] iMacOut3,
  input signed [15:0] iMacOut4,
  output reg signed [15:0] oFirOut

  );
  wire signed [19:0] wFinalSum;


  assign wFinalSum = iMacOut1 + iMacOut2 + iMacOut3 + iMacOut4;

  always @(posedge iClk) begin
    if (!iRsn) begin
      oFirOut <= 16'd0; // 리셋 시 0으로 초기화
    end
    else if (iEnSample) begin //saturation check
      if (wFinalSum > 20'sd32767) 
        oFirOut <= 16'h7FFF;       
      else if (wFinalSum < -20'sd32768) 
        oFirOut <= 16'h8000; 
      else 
        oFirOut <= wFinalSum[15:0]; 
    end
  end
endmodule 