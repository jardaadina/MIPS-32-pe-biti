library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ID is
  Port (RegWrite: in std_logic;
        Instr: in std_logic_vector(25 downto 0);
        RedDest: in std_logic;
        EN: in std_logic;
        ExtOp: in std_logic;
        WD: in std_logic_vector(31 downto 0);
        RD1: out std_logic_vector(31 downto 0); 
        RD2: out std_logic_vector(31 downto 0);
        Ext_Imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0);
        clk: in std_logic);
end ID;

architecture Behavioral of ID is

component reg_file
port ( clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(31 downto 0);
regwr : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0);
en: in std_logic);
end component;

signal Instr2016: std_logic_vector(4 downto 0):=(others=>'0');
signal Instr1511: std_logic_vector(4 downto 0):=(others=>'0');
signal iesireMUX: std_logic_vector(4 downto 0):=(others=>'0');
signal Instr150: std_logic_vector(15 downto 0):=(others=>'0');

begin

Instr2016<=Instr(20 downto 16);
Instr1511<=Instr(15 downto 11);
func<=Instr(5 downto 0);
sa<=Instr(10 downto 6);
Instr150<=Instr(15 downto 0);

--proces mux
process(Instr2016, Instr1511, RedDest)
begin
    if RedDest='1' then
        iesireMUX<=Instr1511;
    --elsif RedDest='0' then
    else
        iesireMUX<=Instr2016;
    end if;
end process;

regFileComponent: reg_file port map(clk, Instr(25 downto 21), Instr(20 downto 16), iesireMUX, WD, RegWrite, RD1, RD2, EN);

process(Instr150, ExtOp)
begin
    if ExtOp='0' then
        Ext_Imm<=X"0000"&Instr150;
    --elsif ExtOp='1' then
    else 
        Ext_Imm(31 downto 16)<=(others=>Instr150(15));
        Ext_Imm(15 downto 0)<=Instr150;
     end if;
end process;

end Behavioral;
