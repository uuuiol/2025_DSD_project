`timescale 1ns/10ps

module SpSram #(

  // Parameter
  parameter SRAM_DEPTH = 16, //데이터 개수
  parameter DATA_WIDTH = 32 ) ( //데이터 비트 수


  // Clock & reset
  input                             iClk,     // Rising edge
  input                             iRsn,     // Sync. & low reset


  // SP-SRAM Input & Output
  input                             iCsn,     // 0일때 Sram 동작
  input                             iWrn,     // 0:Write, 1:Read
  input  [log_b2(SRAM_DEPTH-1)-1:0] iAddr,    // 주소 입력

  input  [DATA_WIDTH-1:0]           iWrDt,    // Write data
  output [DATA_WIDTH-1:0]           oRdDt     // Read data

  );



  // Integer declaration
  integer          i;

  // wire & reg declaration
  reg  [DATA_WIDTH-1:0] rMem[0:SRAM_DEPTH-1];    // 데이터 저장되는 메모리 공간
  reg  [DATA_WIDTH-1:0] rRdDt;



  /*************************************************************/
  // Function for caculation iAddr bit width
  /*************************************************************/
  // log_b2 (base 2 log function)
  function integer log_b2(input integer iDepth);
  begin

    log_b2 = 0;

    while (iDepth)
    begin
      log_b2 = log_b2  + 1;
      iDepth = iDepth >> 1;
    end

  end
  endfunction
  


  /*************************************************************/
  // SP-SRAM function
  /*************************************************************/
  // rMem write operation
  always @(posedge iClk)
  begin

    // Synchronous & low reset
    if (!iRsn)
    begin
      for (i=0 ; i<SRAM_DEPTH ; i=i+1)
      begin
        rMem[i] <= {DATA_WIDTH{1'b0}};
      end
    end

    // Write condition 칩 사용 & 쓰기모드일때
    else if (iCsn == 1'b0 && iWrn == 1'b0)
    begin
      rMem[iAddr] <= iWrDt[DATA_WIDTH-1:0];
    end

  end


  // rMem read operation
  always @(posedge iClk)
  begin

    // Synchronous & low reset
    if (!iRsn)
    begin
      rRdDt <= {DATA_WIDTH{1'b0}};
    end

    // Read codition 칩 사용 & 읽기모드일때 
    else if (iCsn == 1'b0 && iWrn == 1'b1)
    begin
      rRdDt <= rMem[iAddr][DATA_WIDTH-1:0];
    end

  end


  // Output mapping
  assign oRdDt = rRdDt[DATA_WIDTH-1:0];


endmodule
