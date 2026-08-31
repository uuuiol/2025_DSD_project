`timescale 1ns/10ps

module tb_ReConf_FirFilter;

    reg iClk;
    reg iRsn;
    reg iEnSample;
    reg iCoeffUpdateFlag;

    // SRAM Write Control
    reg iCsn;
    reg iWrn;
    reg [5:0] iAddr;
    reg [15:0] iWrDt;
    reg [5:0] iNumOfCoeff;

    // Input Data
    reg signed [2:0] iFirIn;

    // Output
    wire signed [15:0] oFirOut;

    reg [4:0] cnt20; // 12MHz -> 600kHz 
    reg [5:0] cnt64; // Impulse generation counter
    
    integer k; // 루프 변수
    
    // 출력 제어용 신호
    reg rEnSample_d1; // iEnSample 1클럭 지연
    reg rOutputValid;  // 출력 유효 신호

    // ------------------------------------------------
    // DUT Instantiation
    // ------------------------------------------------
    ReConf_FirFilter UUT (
        .iClk               (iClk),
        .iRsn               (iRsn),
        .iEnSample          (iEnSample),
        .iCoeffUpdateFlag   (iCoeffUpdateFlag),
        
        .iCsn               (iCsn),
        .iWrn               (iWrn),
        .iAddr              (iAddr),
        .iWrDt              (iWrDt),
        .iNumOfCoeff        (iNumOfCoeff),

        .iFirIn             (iFirIn),
        .oFirOut            (oFirOut)
    );

    // ------------------------------------------------
    // Clock Generation (12MHz)
    // ------------------------------------------------
    initial begin
        iClk = 1'b0;
        forever #41.66 iClk = ~iClk; 
    end

    // ------------------------------------------------
    // Reset Generation
    // ------------------------------------------------
    initial begin
        iRsn = 1'b0;
        #200;       
        @(posedge iClk);
        iRsn = 1'b1; 
    end

    // ------------------------------------------------
    // Sampling Enable Generation (600kHz)
    // ------------------------------------------------
    // 12MHz / 20 = 600kHz
    always @(posedge iClk) begin
        if(!iRsn) begin
            cnt20 <= 0;
            iEnSample <= 1'b0;
        end
        else if(cnt20 == 19) begin
            cnt20 <= 0;
            iEnSample <= 1'b1; // 20클럭마다 1번씩 High (Sample Start)
        end
        else begin
            cnt20 <= cnt20 + 1;
            iEnSample <= 1'b0;
        end
    end 

    // ------------------------------------------------
    // Input Data Generation 
    // ------------------------------------------------
    // iEnSample이 뜰 때마다 카운트를 세서, 64번째 샘플마다 1을 입력
    always @(posedge iClk) begin
        if(!iRsn) begin
            cnt64 <= 0;
            iFirIn <= 3'sd0;
        end
        else if(iEnSample) begin // 샘플링 타이밍에만 동작
            if(cnt64 == 63) begin
                cnt64 <= 0;
                iFirIn <= 3'b001; // 1입력
                $display("[Input] Impulse(1) Injected at Time: %0t", $time);
            end
            else begin
                cnt64 <= cnt64 + 1;
                iFirIn <= 3'sd0; // 평소에는 0
            end
        end
    end

    // ------------------------------------------------
    // Output Valid Signal Generation
    // ------------------------------------------------
    // iEnSample의 지연 신호 생성
    always @(posedge iClk) begin
        if(!iRsn) begin
            rEnSample_d1 <= 1'b0;
        end
        else begin
            rEnSample_d1 <= iEnSample;
        end
    end

    // 출력 유효 신호: iEnSample이 1이었던 다음 클럭에만 1
    always @(posedge iClk) begin
        if(!iRsn) begin
            rOutputValid <= 1'b0;
        end
        else begin
            rOutputValid <= rEnSample_d1; // iEnSample 1클럭 후
        end
    end

    // ------------------------------------------------
    // Raised Cosine Filter Coefficients
    // ------------------------------------------------
    reg signed [15:0] rCoeff [0:39];

    initial begin
        // 모든 계수 0으로 초기화
        for(k=0; k<40; k=k+1) rCoeff[k] = 16'd0;

        // 유효 계수 설정 
        rCoeff[0]  = 16'd3;     // n-16
        rCoeff[1]  = 16'd0;
        rCoeff[2]  = -16'd6;
        rCoeff[3]  = 16'd7;
        rCoeff[4]  = 16'd0;
        rCoeff[5]  = -16'd11;
        rCoeff[6]  = 16'd13;
        rCoeff[7]  = 16'd0;
        rCoeff[8]  = -16'd19;
        rCoeff[9]  = 16'd24;
        rCoeff[10] = 16'd0;
        rCoeff[11] = -16'd37;
        rCoeff[12] = 16'd48;
        rCoeff[13] = 16'd0;
        rCoeff[14] = -16'd102;
        rCoeff[15] = 16'd206;
        rCoeff[16] = 16'd500;   // Center 
        rCoeff[17] = 16'd206;
        rCoeff[18] = -16'd102;
        rCoeff[19] = 16'd0;
        rCoeff[20] = 16'd48;
        rCoeff[21] = -16'd37;
        rCoeff[22] = 16'd0;
        rCoeff[23] = 16'd24;
        rCoeff[24] = -16'd19;
        rCoeff[25] = 16'd0;
        rCoeff[26] = 16'd13;
        rCoeff[27] = -16'd11;
        rCoeff[28] = 16'd0;
        rCoeff[29] = 16'd7;
        rCoeff[30] = -16'd6;
        rCoeff[31] = 16'd0;
        rCoeff[32] = 16'd3;     // n+16
    end

    // ------------------------------------------------
    // Main Test Scenario
    // ------------------------------------------------
    initial begin
        // Initialize Inputs
        iCoeffUpdateFlag = 0;
        iCsn = 1;
        iWrn = 1;
        iAddr = 0;
        iWrDt = 0;
        iNumOfCoeff = 33; // 실제 계수 개수

        // Wait for Reset release
        @(posedge iRsn);
        #100;

        // ============================================================
        // [Phase 1] Coefficient Update Sequence
        // ============================================================
        $display("---------------------------------------------------");
        $display(" Phase 1: Coefficient Update Start (Real Coefficients)");
        $display("---------------------------------------------------");
        
        iCoeffUpdateFlag = 1; // 업데이트 모드 진입
        @(posedge iClk);

        // Address 0~32에 실제 필터 계수(rCoeff) 쓰기
        for (k = 0; k < 33; k = k + 1) begin
            @(posedge iClk);
            iAddr = k;              // 주소
            iWrDt = rCoeff[k];      // 실제 계수값 입력
            
            iCsn = 0; iWrn = 0;     // Write
            @(posedge iClk);
            iCsn = 1; iWrn = 1;     // Off
            
            // 디버그용 출력 (0이 아닌 것만 출력)
            if(rCoeff[k] != 0)
                $display("Write SRAM Addr[%0d] = %0d", k, rCoeff[k]);
        end
        
        @(posedge iClk);
        iCoeffUpdateFlag = 0; // 필터 동작 모드

        $display("---------------------------------------------------");
        $display(" Phase 1: Coefficient Update Done");
        $display("---------------------------------------------------");

        // ============================================================
        // [Phase 2] Filter Operation
        // ============================================================
        $display("---------------------------------------------------");
        $display(" Phase 2: Filter Operation Start");
        $display("---------------------------------------------------");

        // Impulse Response 확인을 위해 충분히 대기
        repeat (5000) @(posedge iClk);
        $display("---------------------------------------------------");
        $display(" Test Finished");
        $display("---------------------------------------------------");
        $finish;
    end

    // ------------------------------------------------
    // Output Monitoring
    // ------------------------------------------------
    always @(posedge iClk) begin
        if (rOutputValid && oFirOut !== 16'h0) begin
            $display("[Output] Time: %0t, Sample#: %0d, oFirOut: %0d (Hex: %h)", 
                     $time, cnt64, oFirOut, oFirOut);
        end
    end

endmodule
