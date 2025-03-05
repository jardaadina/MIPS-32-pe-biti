library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity EX is
  Port (   RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           ALUSrc : in STD_LOGIC;
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           Pc_4 : in STD_LOGIC_VECTOR (31 downto 0);
           GTZ : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0));
end EX;

architecture Behavioral of EX is

signal ALUCtrl: std_logic_vector(2 downto 0):=(others=>'0');
signal A: std_logic_vector(31 downto 0):=(others=>'0');
signal B: std_logic_vector(31 downto 0):=(others=>'0');
signal C: std_logic_vector(31 downto 0):=(others=>'0');
signal Z: std_logic;
begin

process(AluOp, func)
begin
case AluOp is
when "10" =>
    case func is 
        when "100000" =>ALUCtrl<="000";
        when "100010" =>ALUCtrl<="100";
        when "000000" =>ALUCtrl<="011";
        when "000010" =>ALUCtrl<="101";
        when "100100" =>ALUCtrl<="001";
        when "100101" =>ALUCtrl<="010";
        when "100110" =>ALUCtrl<="110";
        when "000011" =>ALUCtrl<="111";
        when others =>ALUCtrl<="000";
    end case;
when "00" => ALUCtrl<="000";
when "01" => ALUCtrl<="100";
--am schimbat din 010 in 001
when "11" => ALUCtrl<="001";
when others =>ALUCtrl<=(others=>'X');
end case;
end process;

A<=RD1;

--process mux
process(RD2, ALUSrc, Ext_Imm)
begin
    if ALUSrc='0' then
        B<=RD2;
    else B<=Ext_Imm;
    end if;
end process;

process(A, B, ALUCtrl, sa)
begin

case ALUCtrl is 
    when "000" => C <= A+B;
    when "100" => C <= A-B;
    when "011" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));  
    when "101" => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); 
    when "111" => C <= to_stdlogicvector(to_bitvector(B) sra conv_integer(sa));  
    when "001" => C<=A and B;
    when "010" => C <= A or B;  
    when "110" => C <= A xor B;
    when others => C <= (others=> 'X');
end case;
end process;

    ALURes<=C;
    Z<='1' when C=X"0000" else '0';
    Zero<=Z;
    GTZ<=not(Z) and not(C(31));
    
    BranchAddress<=Pc_4 + (Ext_Imm(29 downto 0) & "00");

end Behavioral;
