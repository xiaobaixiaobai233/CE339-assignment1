library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    Port ( 
        clk_ref : in  STD_LOGIC;                         -- 约 1kHz 的刷新时钟
        mins    : in  integer range 0 to 60;             -- 分钟输入
        secs    : in  integer range 0 to 59;             -- 秒钟输入
        seg     : out STD_LOGIC_VECTOR (6 downto 0);     -- 7段码 (CA-CG)
        an      : out STD_LOGIC_VECTOR (3 downto 0);     -- 位选 (AN0-AN3)
        dp      : out STD_LOGIC                          -- 小数点
    );
end display_driver;

architecture Behavioral of display_driver is
    signal digit_select : unsigned(1 downto 0) := "00";  -- 扫描计数器
    signal current_digit : integer range 0 to 9;         -- 当前显示的数值
begin

    -- 1. 扫描计数器：在 clk_ref 的上升沿切换显示的位数
    process(clk_ref)
    begin
        if rising_edge(clk_ref) then
            digit_select <= digit_select + 1;
        end if;
    end process;

    -- 2. 位选与数据多路复用逻辑
    -- Basys3 数码管为共阳极，位选信号 '0' 表示激活该位
    process(digit_select, mins, secs)
    begin
        case digit_select is
            when "00" => -- 最左侧位：显示分钟的十位
                an <= "0111";
                current_digit <= mins / 10;
                dp <= '1'; -- '1' 表示关闭小数点
            when "01" => -- 第二位：显示分钟的个位
                an <= "1011";
                current_digit <= mins rem 10;
                dp <= '0'; -- '0' 表示点亮小数点（用于区分分和秒）
            when "10" => -- 第三位：显示秒钟的十位
                an <= "1101";
                current_digit <= secs / 10;
                dp <= '1';
            when "11" => -- 最右侧位：显示秒钟的个位
                an <= "1110";
                current_digit <= secs rem 10;
                dp <= '1';
            when others =>
                an <= "1111";
                current_digit <= 0;
                dp <= '1';
        end case;
    end process;

    -- 3. 7 段译码器逻辑 (BCD to 7-segment)
    -- 段码 '0' 表示点亮，'1' 表示熄灭 [cite: 164, 244]
    process(current_digit)
    begin
        case current_digit is
            when 0 => seg <= "1000000"; -- "0"
            when 1 => seg <= "1111001"; -- "1"
            when 2 => seg <= "0100100"; -- "2"
            when 3 => seg <= "0110000"; -- "3"
            when 4 => seg <= "0011001"; -- "4"
            when 5 => seg <= "0010010"; -- "5"
            when 6 => seg <= "0000010"; -- "6"
            when 7 => seg <= "1111000"; -- "7"
            when 8 => seg <= "0000000"; -- "8"
            when 9 => seg <= "0010000"; -- "9"
            when others => seg <= "1111111";
        end case;
    end process;

end Behavioral;