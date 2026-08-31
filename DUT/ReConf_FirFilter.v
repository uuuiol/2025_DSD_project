`timescale 1ns/10ps

module ReConf_FirFilter(

  input             iClk,
  input             iRsn,
  input             iEnSample,
  input             iCoeffUpdateFlag,
  
  input             iCsn,
  input             iWrn,
  input [5:0]       iAddr,
  input [15:0]      iWrDt,
  input [5:0]       iNumOfCoeff,

  input signed [2:0] iFirIn,

  output [15:0]     oFirOut
  );

  reg           [3:0] rCnt1;
  reg           [3:0] rCnt2;
  reg           [3:0] rCnt3;
  reg           [3:0] rCnt4;

  wire signed [15:0]   wMacOut1;
  wire signed [15:0]   wMacOut2;
  wire signed [15:0]   wMacOut3;
  wire signed [15:0]   wMacOut4;

  wire signed [19:0]   wFinalSum;

  wire signed [2:0] wDelay1;
  wire signed [2:0] wDelay2;
  wire signed [2:0] wDelay3;
  wire signed [2:0] wDelay4;
  wire signed [2:0] wDelay5;
  wire signed [2:0] wDelay6;
  wire signed [2:0] wDelay7;
  wire signed [2:0] wDelay8;
  wire signed [2:0] wDelay9;
  wire signed [2:0] wDelay10;
  wire signed [2:0] wDelay11;
  wire signed [2:0] wDelay12;
  wire signed [2:0] wDelay13;
  wire signed [2:0] wDelay14;
  wire signed [2:0] wDelay15;
  wire signed [2:0] wDelay16;
  wire signed [2:0] wDelay17;
  wire signed [2:0] wDelay18;
  wire signed [2:0] wDelay19;
  wire signed [2:0] wDelay20;
  wire signed [2:0] wDelay21;
  wire signed [2:0] wDelay22;
  wire signed [2:0] wDelay23;
  wire signed [2:0] wDelay24;
  wire signed [2:0] wDelay25;
  wire signed [2:0] wDelay26;
  wire signed [2:0] wDelay27;
  wire signed [2:0] wDelay28;
  wire signed [2:0] wDelay29;
  wire signed [2:0] wDelay30;
  wire signed [2:0] wDelay31;
  wire signed [2:0] wDelay32;
  wire signed [2:0] wDelay33;
  wire signed [2:0] wDelay34;
  wire signed [2:0] wDelay35;
  wire signed [2:0] wDelay36;
  wire signed [2:0] wDelay37;
  wire signed [2:0] wDelay38;
  wire signed [2:0] wDelay39;
  wire signed [2:0] wDelay40;


  // iNumOfCoeff개수에 따라 각 MacUnit에서 계산할 Coeff 개수 값을 설정
  // 33 -> MacUnit1 : 10개, MacUnit2: 10개, MacUnit3: 10개, MacUnit4: 3개
  always @(*) begin
    rCnt1 = 4'd10; 
    rCnt2 = 4'd10; 
    rCnt3 = 4'd10; 
    rCnt4 = 4'd10;

    if (iNumOfCoeff < 10) begin
            rCnt1 = iNumOfCoeff[3:0];
            rCnt2 = 0; rCnt3 = 0; rCnt4 = 0;
    end
    else if (iNumOfCoeff < 20) begin
        rCnt2 = iNumOfCoeff - 10; 
        rCnt3 = 0; rCnt4 = 0;
    end
    else if (iNumOfCoeff < 30) begin
        rCnt3 = iNumOfCoeff - 20;
        rCnt4 = 0;
    end
    else if (iNumOfCoeff < 40) begin
        rCnt4 = iNumOfCoeff - 30;
    end

  end

  DelayChain inst_dc(
    .iClk           (iClk),
    .iRsn           (iRsn),
    .iEnSample      (iEnSample),

    .iFirIn         (iFirIn[2:0]),

    .oDelay1        (wDelay1),
    .oDelay2        (wDelay2),
    .oDelay3        (wDelay3),
    .oDelay4        (wDelay4),
    .oDelay5        (wDelay5),
    .oDelay6        (wDelay6),
    .oDelay7        (wDelay7),
    .oDelay8        (wDelay8),
    .oDelay9        (wDelay9),
    .oDelay10       (wDelay10),
    .oDelay11        (wDelay11),
    .oDelay12        (wDelay12),
    .oDelay13        (wDelay13),
    .oDelay14        (wDelay14),
    .oDelay15        (wDelay15),
    .oDelay16        (wDelay16),
    .oDelay17        (wDelay17),
    .oDelay18        (wDelay18),
    .oDelay19        (wDelay19),
    .oDelay20       (wDelay20),
    .oDelay21        (wDelay21),
    .oDelay22        (wDelay22),
    .oDelay23        (wDelay23),
    .oDelay24        (wDelay24),
    .oDelay25        (wDelay25),
    .oDelay26        (wDelay26),
    .oDelay27        (wDelay27),
    .oDelay28        (wDelay28),
    .oDelay29        (wDelay29),
    .oDelay30       (wDelay30),
    .oDelay31        (wDelay31),
    .oDelay32        (wDelay32),
    .oDelay33        (wDelay33),
    .oDelay34        (wDelay34),
    .oDelay35        (wDelay35),
    .oDelay36        (wDelay36),
    .oDelay37        (wDelay37),
    .oDelay38        (wDelay38),
    .oDelay39        (wDelay39),
    .oDelay40       (wDelay40)
    
  );
  wire [3:0] wAddr_ft2;
  wire [3:0] wAddr_ft3;
  wire [3:0] wAddr_ft4;

  // 6비트 입력에서 값을 뺀 뒤, 하위 4비트만 취함
  assign wAddr_ft2 = iAddr - 6'd10; 
  assign wAddr_ft3 = iAddr - 6'd20;
  assign wAddr_ft4 = iAddr - 6'd30;
  FsmTop inst_ft1(
    .iClk           (iClk),
    .iRsn           (iRsn),
    .iEnSample      (iEnSample),

    .iCoeffUpdateFlag (iCoeffUpdateFlag),
    .iCsn           ((iAddr >= 0 && iAddr<10) ? iCsn : 1'b1), //iAddr 값에 따른 동작여부 설정
    .iWrn           (iWrn),
    .iAddr          (iAddr[3:0]),
    .iWrDt          (iWrDt),

    .iCnt           (rCnt1),

    .iDelay1        (wDelay1),
    .iDelay2        (wDelay2),
    .iDelay3        (wDelay3),
    .iDelay4        (wDelay4),
    .iDelay5        (wDelay5),
    .iDelay6        (wDelay6),
    .iDelay7        (wDelay7),
    .iDelay8        (wDelay8),
    .iDelay9        (wDelay9),
    .iDelay10       (wDelay10),

    .oAccOut        (wMacOut1)
  );

  FsmTop inst_ft2(
    .iClk           (iClk),
    .iRsn           (iRsn),
    .iEnSample      (iEnSample),

    .iCoeffUpdateFlag (iCoeffUpdateFlag),
    .iCsn           ((iAddr >= 10 && iAddr<20) ? iCsn : 1'b1),
    .iWrn           (iWrn),
    .iAddr          (wAddr_ft2),
    .iWrDt          (iWrDt),

    .iCnt           (rCnt2),

    .iDelay1        (wDelay11),
    .iDelay2        (wDelay12),
    .iDelay3        (wDelay13),
    .iDelay4        (wDelay14),
    .iDelay5        (wDelay15),
    .iDelay6        (wDelay16),
    .iDelay7        (wDelay17),
    .iDelay8        (wDelay18),
    .iDelay9        (wDelay19),
    .iDelay10       (wDelay20),

    .oAccOut        (wMacOut2)
  );

  FsmTop inst_ft3(
    .iClk           (iClk),
    .iRsn           (iRsn),
    .iEnSample      (iEnSample),

    .iCoeffUpdateFlag (iCoeffUpdateFlag),
    .iCsn           ((iAddr >= 20 && iAddr<30) ? iCsn : 1'b1),
    .iWrn           (iWrn),
    .iAddr          (wAddr_ft3),
    .iWrDt          (iWrDt),

    .iCnt           (rCnt3),

    .iDelay1        (wDelay21),
    .iDelay2        (wDelay22),
    .iDelay3        (wDelay23),
    .iDelay4        (wDelay24),
    .iDelay5        (wDelay25),
    .iDelay6        (wDelay26),
    .iDelay7        (wDelay27),
    .iDelay8        (wDelay28),
    .iDelay9        (wDelay29),
    .iDelay10       (wDelay30),

    .oAccOut        (wMacOut3)
  );

  FsmTop inst_ft4(
    .iClk           (iClk),
    .iRsn           (iRsn),
    .iEnSample      (iEnSample),

    .iCoeffUpdateFlag (iCoeffUpdateFlag),
    .iCsn           ((iAddr >= 30 && iAddr<40) ? iCsn : 1'b1),
    .iWrn           (iWrn),
    .iAddr          (wAddr_ft4),
    .iWrDt          (iWrDt),

    .iCnt           (rCnt4),

    .iDelay1        (wDelay31),
    .iDelay2        (wDelay32),
    .iDelay3        (wDelay33),
    .iDelay4        (wDelay34),
    .iDelay5        (wDelay35),
    .iDelay6        (wDelay36),
    .iDelay7        (wDelay37),
    .iDelay8        (wDelay38),
    .iDelay9        (wDelay39),
    .iDelay10       (wDelay40),

    .oAccOut        (wMacOut4)
  );
  FinalSum inst_finalsum (
    .iClk       (iClk),
    .iRsn       (iRsn),
    .iEnSample  (iEnSample),
    
    .iMacOut1   (wMacOut1),  // FsmTop 1번 결과
    .iMacOut2   (wMacOut2),  // FsmTop 2번 결과
    .iMacOut3   (wMacOut3),  // FsmTop 3번 결과
    .iMacOut4   (wMacOut4),  // FsmTop 4번 결과

    .oFirOut    (oFirOut)    // 최종 출력 포트로 연결
  );


endmodule