-- FSM 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is 
  Port
  ( CLK       : in std_logic;
    RST       : in std_logic;       
    RxDataRdy : in std_logic;
    UART_TXD_IN : in std_logic;
    DisplayData : out std_logic
    --TxStart : out std_logic
  );
end FSM;

architecture Moore of FSM is    

  type FSM_State is (Init, WaitForData, Received, Encoded1);
  signal CurrentState : FSM_State;
  signal NextState    : FSM_State;

begin

  -- Current State Register
  process(CLK, RST)
  begin
    if RST = '1' then
      CurrentState <= Init;
    elsif rising_edge(CLK) then
      CurrentState <= NextState;
    end if;
  end process;
  
  -- Next State Process
  process (CurrentState, RxDataRdy)
  begin
    case CurrentState is
      when Init =>
        NextState <= WaitForData;
      when WaitForData =>
        if RxDataRdy = '1' then
          NextState <= Received;
        else 
          NextState <= WaitForData;
        end if;
      when Received =>
        DisplayData <= UART_TXD_IN;
        NextState <= Encoded1;
      when Encoded1 =>
        DisplayData <= '1';
        NextState <= WaitForData;
      end case;
    end process;
    
    -- Output Function
    
end Moore;