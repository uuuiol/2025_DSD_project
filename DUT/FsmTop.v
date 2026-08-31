`timescale 1ns/10ps

module FsmTop (

  // Clock & reset
  input                 iClk,          // Rising edge
  input                 iRsn,          // Sync. & low reset
  input                 iEnSample,


  // Update flag
  input                 iCoeffUpdateFlag,   // 1'b1: Write, 1'b0: Accmulation


  // SP-SRAM write input from Top
  input                 iCsn,
  input                 iWrn,
  input  [3:0]          iAddr,
  input  [15:0]         iWrDt,

  input  [3:0]          iCnt, //읽어야 하는 Coeff 개수가 입력으로 들어온다.

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


  // Accumulated out
  output signed [15:0]  oAccOut 

  );



  /*********************************************/
  // wire & reg
  /*********************************************/
  wire             wCsn_Fsm;
  wire             wWrn_Fsm;
  wire   [3:0]     wAddr_Fsm;

  wire             wCsn_Mux;
  wire             wWrn_Mux;
  wire   [3:0]     wAddr_Mux;

  wire signed [15:0] wRdDt;

  wire             wEnOut;

  wire             wEnMul;
  wire             wEnAdd;



  /*********************************************/
  // AccessMux.v instantiation
  /*********************************************/
  AccessMux inst_AccessMux (

    .iCoeffUpdateFlag        (iCoeffUpdateFlag),

    .iCsn               (iCsn),
    .iWrn               (iWrn),
    .iAddr              (iAddr[3:0]),

    .iCsn_Fsm           (wCsn_Fsm),
    .iWrn_Fsm           (wWrn_Fsm),
    .iAddr_Fsm          (wAddr_Fsm[3:0]),

    .oCsn_Mux          (wCsn_Mux),
    .oWrn_Mux          (wWrn_Mux),
    .oAddr_Mux         (wAddr_Mux[3:0])
    
  );



  /*********************************************/
  // CtrlFsm.v instantiation
  /*********************************************/
  CtrlFsm inst_CtrlFsm (

    .iClk               (iClk),
    .iRsn               (iRsn),
    .iEnSample          (iEnSample),

    .iCoeffUpdateFlag        (iCoeffUpdateFlag),
    .iCnt               (iCnt),

    .oCsn_Fsm           (wCsn_Fsm),
    .oWrn_Fsm           (wWrn_Fsm),
    .oAddr_Fsm          (wAddr_Fsm[3:0]),

    .oEnOut             (wEnOut),

    .oEnMul             (wEnMul),
    .oEnAdd             (wEnAdd),
    .oEnAcc             (wEnAcc)

  );



  /*********************************************/
  // SpSram.v instantiation
  /*********************************************/
  SpSram #(
    // Parameter
    .SRAM_DEPTH      (10),
    .DATA_WIDTH      (16)
  ) inst_SpSram (

    .iClk               (iClk),
    .iRsn               (iRsn),

    .iCsn               (wCsn_Mux),
    .iWrn               (wWrn_Mux),
    .iAddr              (wAddr_Mux[3:0]),
    .iWrDt              (iWrDt[15:0]),

    .oRdDt              (wRdDt[15:0])

  );



  /*********************************************/
  // MacUnit.v instantiation
  /*********************************************/
  MacUnit inst_MacUnit (

    .iClk               (iClk),
    .iRsn               (iRsn),

    .iCoeff              (wRdDt[15:0]),

    .iEnOut             (wEnOut),


    .iEnAdd             (wEnAdd),
    .iEnAcc             (wEnAcc),
    .iEnMul            (wEnMul),
    .iAddr             (wAddr_Fsm[3:0]),

    .iDelay1            (iDelay1),
    .iDelay2            (iDelay2),
    .iDelay3            (iDelay3),
    .iDelay4            (iDelay4),
    .iDelay5            (iDelay5),
    .iDelay6            (iDelay6),
    .iDelay7            (iDelay7),
    .iDelay8            (iDelay8),
    .iDelay9            (iDelay9),
    .iDelay10           (iDelay10),

    .oMac            (oAccOut[15:0])

  );



endmodule
