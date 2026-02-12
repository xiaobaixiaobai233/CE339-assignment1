library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_controller is
    Port ( 
        clk          : in  STD_LOGIC;
        pulse_2sec   : in  STD_LOGIC;
        btnC, btnU, btnD : in  STD_LOGIC;
        mins         : out integer range 0 to 60;
        secs         : out integer range 0 to 59;
        sync_reset   : out STD_LOGIC  -- 新增：同步复位输出
    );
end timer_controller;

architecture Behavioral of timer_controller is
    type mode_type is (SET, GO);
    signal current_mode : mode_type := SET;
    signal reg_mins : integer range 0 to 60 := 0;
    signal reg_secs : integer range 0 to 59 := 0;
    signal btnC_last, btnU_last, btnD_last : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- 边缘检测
            btnC_last <= btnC; btnU_last <= btnU; btnD_last <= btnD;
            sync_reset <= '0'; -- 默认不复位

            -- 模式切换逻辑
            if btnC = '1' and btnC_last = '0' then
                if current_mode = SET then 
                    current_mode <= GO;
                    sync_reset <= '1'; -- 切换到GO时立即复位计时器，确保第一个2秒是完整的
                else 
                    current_mode <= SET;
                end if;
            end if;

            if current_mode = SET then
                if (btnU = '1' and btnU_last = '0') or (btnD = '1' and btnD_last = '0') then
                    sync_reset <= '1'; -- 按下设置键时复位计时 
                    if btnU = '1' then
                        if reg_mins < 60 then reg_mins <= reg_mins + 1; end if;
                    else
                        if reg_secs > 0 then null; -- 仅清零秒
                        elsif reg_mins > 0 then reg_mins <= reg_mins - 1; end if;
                    end if;
                    reg_secs <= 0;
                end if;
            else -- GO 模式
                if pulse_2sec = '1' then
                    if reg_secs = 0 then
                        if reg_mins > 0 then reg_mins <= reg_mins - 1; reg_secs <= 59; end if;
                    else reg_secs <= reg_secs - 1; end if;
                end if;
            end if;
        end if;
    end process;
    mins <= reg_mins; secs <= reg_secs;
end Behavioral;