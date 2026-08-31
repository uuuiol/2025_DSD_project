`timescale 1ns/10ps

module CtrlFsm (

  // Clock & reset
  input                 iClk,          // Rising edge
  input                 iRsn,          // Sync. & low reset
  input                 iEnSample,


  // Update flag
  input                 iCoeffUpdateFlag,   // 1'b1: Write, 1'b0: Accmulation

  // 몇 개의 계수를 누적해서 더할지 
  input [3:0]           iCnt,


  // SP-SRAM access output to SpSram.v
  output wire           oCsn_Fsm,
  output wire           oWrn_Fsm,
  output reg  [3:0]     oAddr_Fsm,


  // Accumulator control output to Accumulator.v
  output wire           oEnOut,
  output wire           oEnAcc,
  output wire           oEnMul,
  output wire           oEnAdd

  );



  // Parameter
  parameter   p_Idle   = 3'b00, //대기 상태
              p_Update = 3'b001, //업데이트 대기
              p_MemRd  = 3'b010, //sram 읽기
              p_Wait   = 3'b011, //잠깐 기다림
              p_Wait2  = 3'b101,
              p_Out    = 3'b100; //Acc가 최종결과 출력하게



  // wire & reg
  reg    [2:0]     rCurState;     // Current state
  reg    [2:0]     rNxtState;     // Next    state

  wire             wLastRd; //마지막 덧셈인지 확인하는 신호



  /*************************************************************/
  // FSM(Finite State Machine)
  /*************************************************************/
  // Part 1: Current state update
  always @(posedge iClk)
  begin
    if (!iRsn)
      rCurState <= p_Idle;
    else
      rCurState <= rNxtState[2:0];
  end



  // Part 2: Next state decision
  always @(*)
  begin
    case (rCurState)
      p_Idle     :
        if (iCoeffUpdateFlag == 1'b1) //쓰기모드로 전환
          rNxtState <= p_Update;
        else if (iEnSample)
          rNxtState <= p_MemRd;
        else
          rNxtState <= p_Idle;


      p_Update   :
        if (iCoeffUpdateFlag == 1'b0) 
          rNxtState <= p_Idle;
        else
          rNxtState <= p_Update;

      //계산기(MacUnit): 데이터가 도착해서 더해지는 데 2클럭
      // (SRAM 읽기 1 + 곱셈 저장 1)-> wait 2개로
      p_MemRd  :
        if (wLastRd == 1'b1) //마지막으로 읽었냐(=aCc가 마지막으로 더했냐)
          rNxtState <= p_Wait;
        else
          rNxtState <= p_MemRd;

      p_Wait  :
        rNxtState <= p_Wait2;

      p_Wait2  :
        rNxtState <= p_Out; 

      p_Out  :
        rNxtState <= p_Idle;

      default    :
        rNxtState <= p_Idle;

    endcase

  end



  // Part 3: Output & enable making
  // oCsn_Fsm
  assign oCsn_Fsm = (rCurState == p_MemRd) ? 1'b0 : 1'b1;
  // oEnOut
  assign oEnOut   = (rCurState == p_Out)   ? 1'b1 : 1'b0;
  // oWrn_Fsm
  assign oWrn_Fsm  = 1'b1;

  assign oEnMul = (rCurState == p_MemRd) ? 1'b1 : 1'b0;

  // oAddr_Fsm[3:0]
  always @(posedge iClk)
  begin
    // Reset condition
    if (!iRsn)
    begin
      oAddr_Fsm <= 4'h0;
    end
    // Initial condition
    else if (rCurState == p_Idle)
    begin
      oAddr_Fsm <= 4'h0;
    end
    // Increase condition
    else if (oCsn_Fsm == 1'b0)
    begin
      if (oAddr_Fsm == iCnt-1'b1) 
        oAddr_Fsm <= oAddr_Fsm[3:0];
      else
        oAddr_Fsm <= oAddr_Fsm[3:0] + 1'b1;

    end

  end


  /*************************************************************/
  // Last read condition
  /*************************************************************/
  // Last read for FSM
  assign wLastRd = (oAddr_Fsm[3:0] == iCnt[3:0]-1'b1) ? 1'b1 : 1'b0;
  //wLastRd는 iNumOfCoeff에 맞춰 설정해야한다.

  // --------------------------------------------------------
  // Pipeline Control Generation
  // --------------------------------------------------------

  reg rPipeEnAcc_d1, rPipeEnAcc_d2; 
  reg rPipeEnAdd_d1, rPipeEnAdd_d2;
  
  wire wCurrentEnAdd;   

  // 1. 현재 상태가 읽기(p_MemRd) 모드이고
  // 2. 주소가 0이 아니면 -> 누적(1)
  // 3. 주소가 0이면      -> 초기화(0)
  assign wCurrentEnAdd = (rCurState == p_MemRd && oAddr_Fsm != 4'h0) ? 1'b1 : 1'b0;

  always @(posedge iClk) begin
    if(!iRsn) begin
        rPipeEnAcc_d1 <= 1'b0; rPipeEnAcc_d2 <= 1'b0;
        rPipeEnAdd_d1 <= 1'b0; rPipeEnAdd_d2 <= 1'b0;
    end
    else begin
        // Stage 1: SRAM Read 단계 지연
        rPipeEnAcc_d1 <= oEnMul;
        rPipeEnAdd_d1 <= wCurrentEnAdd;

        // Stage 2: Multiplier Reg 단계 지연
        rPipeEnAcc_d2 <= rPipeEnAcc_d1;
        rPipeEnAdd_d2 <= rPipeEnAdd_d1;
    end
  end

  // 2클럭 뒤에 Accumulator에 도착하는 신호들
  assign oEnAcc = rPipeEnAcc_d2;
  assign oEnAdd = rPipeEnAdd_d2;// 이 신호가 최종적으로 Accumulator의 iInSel로 연결됨

endmodule
