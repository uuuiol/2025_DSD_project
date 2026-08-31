`timescale 1ns/10ps

module Accumulator (

  // Clock & reset
  input                 iClk,     // Rising edge
  input                 iRsn,     // Sync. & low reset

  // SpSram read data from SpSram.v
  input signed   [15:0] iRdDt,

  // Accumulator's input selection from CtrlFsm.v
  input                 iInSel,  //0:초기화 1:누적
                                  
  input                 iEnAcc, //1:레지스터 저장,  0:유지
  // Final out enable form CtrlFsm.v
  input                 iEnOut, //이 신호가 1이 되면 결과가 oAccOut으로 나감

  // Final out
  output reg signed [15:0] oAccOut // 최종 누적 결과 출력

  );



  // wire & reg declaration
  wire signed  [15:0]   wAccInA;
  wire signed  [15:0]   wAccInB;
  wire signed  [15:0]   wAccSum;

  wire                  wSatCon_1;
  wire                  wSatCon_2;
  wire signed   [15:0]   wAccSumSat;

  reg signed   [15:0]   rAccDt; //중간 누적값 저장용 레지스터



  /*************************************************************/
  // Accumulator function
  /*************************************************************/
  // wAccInA : 16'h0        @ iInSel == 2'b0
  //           rAccDt[15:0] @ else
  assign wAccInA = (iInSel == 1'b0) ? 16'h0 : rAccDt[15:0];


  // wAccInB : iRdDt[15:0]
  assign wAccInB = iRdDt[15:0];


  assign wAccSum = wAccInA[15:0] + wAccInB[15:0];


  /*************************************************************/
  // Saturation condition check
  /*************************************************************/
  // Condition #1 양수+양수 -> 음수가 되는 상황
  assign wSatCon_1 =  (  wAccInA[15] == 1'b0
                      && wAccInB[15] == 1'b0
                      && wAccSum[15] == 1'b1) ? 1'b1 : 1'b0;

  // Condition #2 음수+음수 -> 양수가 되는 상황
  assign wSatCon_2 =  (  wAccInA[15] == 1'b1
                      && wAccInB[15] == 1'b1
                      && wAccSum[15] == 1'b0) ? 1'b1 : 1'b0;


  // Output decision @ saturation condition
  // Condition #1 -> + Max 최대 양수로 고정
  // Condition #2 -> - Min 최소 음수로 고정
  // else         -> Normal result
  assign wAccSumSat = (wSatCon_1 == 1'b1) ? 16'h7FFF :
                      (wSatCon_2 == 1'b1) ? 16'h8000 : wAccSum[15:0];



  /*************************************************************/
  // Accumulator update
  /*************************************************************/
  always @(posedge iClk)
  begin

    // Synchronous & low reset
    if (!iRsn)
      rAccDt <= 16'h0;
    else if(iEnAcc)
      rAccDt <= wAccSumSat[15:0];

  end
    


  /*************************************************************/
  // Final output
  /*************************************************************/
  always @(posedge iClk)
  begin

    // Synchronous & low reset
    if (!iRsn)
      oAccOut <= 16'h0;
    else if (iEnOut == 1'b1) 
      oAccOut <= rAccDt[15:0];

  end


endmodule
