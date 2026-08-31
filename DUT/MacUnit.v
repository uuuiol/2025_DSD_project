`timescale 1ns/10ps
module MacUnit(
  input iClk,
  input iRsn,

  input iEnOut,

  input [3:0] iAddr,
  input iEnMul, //곱할 타이밍 fsm 에서 넘어옴
  input iEnAdd, //새로 시작할지 누적할지 (Accumulator의 iInSel로 넘겨준다)
  input iEnAcc, //레지스터 저장타이밍 신호

  input signed [2:0] iDelay1,
  input signed [2:0] iDelay2,
  input signed [2:0] iDelay3,
  input signed [2:0] iDelay4,
  input signed [2:0] iDelay5,
  input signed [2:0] iDelay6,
  input signed [2:0] iDelay7,
  input signed [2:0] iDelay8,
  input signed [2:0] iDelay9,
  input signed [2:0] iDelay10,

  input signed [15:0] iCoeff, //곱할 계수 값

  output signed [15:0] oMac //누산기 최종 결과값
  );

  // ----------------------------------------------------------
  // 주소(iAddr)에 따라 10개의 Delay 중 하나 선택
  // ----------------------------------------------------------
  reg signed [2:0] rSelDelay;
  always @(*) begin
    case(iAddr)
      4'd0: rSelDelay = iDelay1;
      4'd1: rSelDelay = iDelay2;
      4'd2: rSelDelay = iDelay3;
      4'd3: rSelDelay = iDelay4;
      4'd4: rSelDelay = iDelay5;
      4'd5: rSelDelay = iDelay6;
      4'd6: rSelDelay = iDelay7;
      4'd7: rSelDelay = iDelay8;
      4'd8: rSelDelay = iDelay9;
      4'd9: rSelDelay = iDelay10;
      default: rSelDelay = 3'sd0;
    endcase
  end


  // ----------------------------------------------------------
  // Timing Alignment (SRAM Latency 보정)
  // ----------------------------------------------------------
  // SRAM 데이터(iCoeff)가 주소보다 1클럭 늦게 나오므로, 
  // Delay 값과 Enable 신호도 1클럭 지연시켜서 박자를 맞춤.
  

  reg signed [2:0] rSelDelay_d1;
  reg              rEnMul_d1;

  always @(posedge iClk) begin
    if(!iRsn) begin
      rSelDelay_d1 <= 3'sd0;
      rEnMul_d1    <= 1'b0;
    end
    else begin
      // iEnMul 구간(유효 주소 구간)일 때만 값 업데이트
      if (iEnMul) rSelDelay_d1 <= rSelDelay;
      
      rEnMul_d1 <= iEnMul; // Enable 신호도 1클럭 지연
    end
  end 

  
  // ----------------------------------------------------------
  // Multiplier & Pipeline Register 
  // ----------------------------------------------------------
  wire signed [18:0] wRawMult;     // 조합회로 곱셈 결과
  reg  signed [18:0] rMultResult;  // 결과를 저장하는 레지스터 (1클럭 지연 효과)

  // SRAM값 * 지연된 입력값
  assign wRawMult = iCoeff * rSelDelay_d1;

  // 결과 래치 (DFF)
  // rEnMul_d1이 1일 때(데이터가 유효할 때) 곱셈 결과를 저장함.
  always @(posedge iClk) begin
      if(!iRsn) begin
          rMultResult <= 19'sd0;
      end
      else if(rEnMul_d1) begin
          rMultResult <= wRawMult;
      end
      else begin
          rMultResult <= 19'sd0; // 유효하지 않은 구간에서는 0으로 밀어버림 (Acc 오염 방지)
      end
  end
  
  Accumulator inst_Accumulator (
    .iClk               (iClk),
    .iRsn               (iRsn),

    .iRdDt              (rMultResult[15:0]),

    .iInSel             (iEnAdd),
    .iEnAcc             (iEnAcc),
    .iEnOut             (iEnOut),

    .oAccOut            (oMac[15:0])
  );


endmodule