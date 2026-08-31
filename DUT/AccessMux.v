`timescale 1ns/10ps

module AccessMux ( //Sram이 어떤 일을 할지 정하는 모듈

  // Update flag
  input            iCoeffUpdateFlag, //1=필터 업데이트, 0=필터 읽어오기


  // SP-SRAM write input from Top. 계수 업데이트 할때 사용하는 신호
  input            iCsn,
  input            iWrn, 
  input  [3:0]     iAddr,


  // SP-SRAM read input form FSM. 계수 읽어올때 사용하는 신호
  input            iCsn_Fsm,
  input            iWrn_Fsm, 
  input  [3:0]     iAddr_Fsm,


  // SpSram.v access output to SpSram.v. SpSram모듈의 입력으로 사용될 신호
  output            oCsn_Mux,
  output            oWrn_Mux,
  output  [3:0]     oAddr_Mux

  );


  /*************************************************************/
  // Mux. function. 업데이트신호에 따라 아웃으로 나가는 신호가 결정됨.
  /*************************************************************/
  // Csn mux
  assign oCsn_Mux  = (iCoeffUpdateFlag == 1'b1) ? iCsn : iCsn_Fsm;

  // Wrn mux
  assign oWrn_Mux  = (iCoeffUpdateFlag == 1'b1) ? iWrn : iWrn_Fsm;

  // Addr mux
  assign oAddr_Mux = (iCoeffUpdateFlag == 1'b1) ? iAddr[3:0] : iAddr_Fsm[3:0];


endmodule
