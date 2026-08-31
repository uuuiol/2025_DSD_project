# 2025 DSD Project

FIR 필터 설계

##목표
본 프로젝트는 디지털 통신 시스템에서 핵심적인 역할을 하는 FIR(Finite Impulse Response)Filter를 FPGA상에서 동작 가능한 하드웨어로 설계하는 것을 목표로 합니다.

1) : 600kHz Sampling Rate 200kHz Symbol Rate , 4개의 병렬 구조로 처리 제한 시간내에 연산을 MAC Sample (20clock) 33-Tap 완료한다.
2) 가변성 필터 (Reconfigurability): 필터 계수를 ROM이 아닌 SpSram에 저장하여 하드웨어 변경 없이 필터 특성을 실시간으로 업데이트할 수 있도록 한다.
3) 병렬 구조 최적화: 4개의 MAC UNIT과 4-BANK SRAM을 활용한 병렬 처리 구조를 통해 연산 효율을 극대화한다.
## 폴더 구성

- `DUT/` – Reconfigurable FIR Filter Verilog 소스
  - `ReConf_FirFilter.v` – 최상위 모듈
  - `FsmTop.v`, `CtrlFsm.v` – 제어 FSM
  - `MacUnit.v`, `Accumulator.v`, `FinalSum.v` – MAC 연산 및 누산
  - `DelayChain.v`, `SpSram.v`, `AccessMux.v` – 지연 체인 및 메모리 접근
- `Testbench/` – 테스트벤치
  - `tb_ReConf_FirFilter.v`
- `Reconfigurable FIR filter_이정우_박도유_이다정.pdf` – 설계 보고서
