library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    -- 使用 generic 定义可配置参数
    generic (
        TICKS_2S   : integer := 199999999; -- 100MHz 下产生 2 秒脉冲 (2s * 10^8 - 1)
        TICKS_REF  : integer := 99999      -- 100MHz 下产生 ~1kHz 刷新率
    );
    Port ( 
        clk          : in  STD_LOGIC;
        reset_2s     : in  STD_LOGIC;
        pulse_2sec   : out STD_LOGIC;
        clk_refresh  : out STD_LOGIC
    );
end clock_divider;

architecture Behavioral of clock_divider is
    -- 使用信号定义计数器范围，以适应 generic 参数
    signal count_2s : integer range 0 to TICKS_2S := 0;
    signal count_ref : integer range 0 to TICKS_REF := 0;
    signal ref_reg   : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- 倒计时分频逻辑
            if reset_2s = '1' then
                count_2s <= 0;
                pulse_2sec <= '0';
            elsif count_2s = TICKS_2S then
                count_2s <= 0;
                pulse_2sec <= '1';
            else
                count_2s <= count_2s + 1;
                pulse_2sec <= '0';
            end if;

            -- 数码管刷新分频逻辑
            if count_ref = TICKS_REF then
                count_ref <= 0;
                ref_reg <= not ref_reg;
            else
                count_ref <= count_ref + 1;
            end if;
        end if;
    end process;

    clk_refresh <= ref_reg;
end Behavioral;