# 2025 DSD Project

FIR 필터 설계

## 폴더 구성

- `DUT/` – Reconfigurable FIR Filter Verilog 소스
  - `ReConf_FirFilter.v` – 최상위 모듈
  - `FsmTop.v`, `CtrlFsm.v` – 제어 FSM
  - `MacUnit.v`, `Accumulator.v`, `FinalSum.v` – MAC 연산 및 누산
  - `DelayChain.v`, `SpSram.v`, `AccessMux.v` – 지연 체인 및 메모리 접근
- `Testbench/` – 테스트벤치
  - `tb_ReConf_FirFilter.v`
- `Reconfigurable FIR filter_이정우_박도유_이다정.pdf` – 설계 보고서
