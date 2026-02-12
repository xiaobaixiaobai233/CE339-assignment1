library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main1_final is
    Port ( 
        CLK100MHZ : in  STD_LOGIC;
        btnC      : in  STD_LOGIC;
        btnU      : in  STD_LOGIC;
        btnD      : in  STD_LOGIC;
        seg       : out STD_LOGIC_VECTOR (6 downto 0);
        an        : out STD_LOGIC_VECTOR (3 downto 0);
        dp        : out STD_LOGIC
    );
end main1_final;

architecture Structural of main1_final is
    -- 内部连接信号
    signal s_pulse_2s  : STD_LOGIC;
    signal s_clk_ref   : STD_LOGIC;
    signal s_sync      : STD_LOGIC;
    signal s_mins      : integer range 0 to 60;
    signal s_secs      : integer range 0 to 59;
begin

    -- 例化分频器模块，并传入 generic 参数
    U_CLK: entity work.clock_divider
        generic map (
            TICKS_2S  => 199999999, -- 这里可以自由修改计数值
            TICKS_REF => 99999      -- 修改此值可改变数码管闪烁感
        )
        port map (
            clk         => CLK100MHZ,
            reset_2s    => s_sync,
            pulse_2sec  => s_pulse_2s,
            clk_refresh => s_clk_ref
        );

    -- 例化计时控制器
    U_CTRL: entity work.timer_controller
        port map (
            clk         => CLK100MHZ,
            pulse_2sec  => s_pulse_2s,
            btnC        => btnC,
            btnU        => btnU,
            btnD        => btnD,
            mins        => s_mins,
            secs        => s_secs,
            sync_reset  => s_sync
        );

    -- 例化显示驱动
    U_DISP: entity work.display_driver
        port map (
            clk_ref     => s_clk_ref,
            mins        => s_mins,
            secs        => s_secs,
            seg         => seg,
            an          => an,
            dp          => dp
        );

end Structural;