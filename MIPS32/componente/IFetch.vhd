library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
Port(
 Jump: in std_logic;
 PcSrc: in std_logic;
 JumpAddress: in std_logic_vector(31 downto 0);
 BranchAddress: in std_logic_vector(31 downto 0);
 Instruction: out std_logic_vector(31 downto 0);
 NextAddress: out std_logic_vector(31 downto 0);
 clk: in std_logic;
 en: in std_logic;
 rst: in std_logic
 );
end IFetch;

architecture Behavioral of IFetch is

type memorie_rom is array (0 to 31) of std_logic_vector(31 downto 0);
signal rom : memorie_rom :=(
                            b"000000_00000_00000_00101_00000_100000",--00 X00002820  add $5 $0 $0 --initializez suma
                            b"001000_00000_00011_0000000000011000",--01 X20030018 addi $3 $0 24 --initializez adresa de start
                            b"001000_00000_00111_0000000000000101", --02 X20070005 addi $7,$0,5 --numarul de iteratii
                            b"001000_00000_01000_0000000000000000",--03 X20080000 addi $8,$0,0 --i contorul buclei
                            b"000100_00111_01000_0000000000000111",--04 X10E80007 beq $7,$8,7 --
                            b"100011_00011_00001_0000000000000000", --05 X8C610000  lw $1 0($3) --incarc in reg 1 ce am la adresa din reg 3
                            b"001100_00001_00100_0000000000000001", --06 X30240001  andi $4 $1 1 --adica $4=$1 and $1 verific daca numarul este impar
                            b"000100_00100_00000_0000000000000001", --07 X10800001  beq $4,$0, 1 --daca numarul este par dam skip 
                            b"000000_00101_00001_00101_00000_100000", --08 X00A12820  add $5 $5 $1 --adunam nr impar la suma
                            b"001000_00011_00011_0000000000000100", --09 X20630004   addi $3 $3 4 --trec la urmatorul element, adica incrementez cu 4  
                            b"001000_01000_01000_0000000000000001", --10 X21080001 addi $8 $8 1  --cresc contorul buclei
                            b"000010_00000000000000000000000100", --11 X08000004   j 4 --fac saltul la beq, practic e un for
                            b"101011_00000_00101_0000000000000000", --12 XAC050000 sw $5 0($0) stocam rezultatul in memorie la adresa 0 
                          others => X"00000000"
);

signal mux1:std_logic_vector(31 downto 0):=(others=>'0');
signal mux2:std_logic_vector(31 downto 0):=(others=>'0');
signal sum:std_logic_vector(31 downto 0):=(others=>'0');
signal q:std_logic_vector(31 downto 0):=(others=>'0');
begin

with Jump select mux1<=JumpAddress when '1',
                       mux2 when others;

with PcSrc select mux2<=BranchAddress when '1',
                       sum when others;

process(clk, rst)
begin
if rst ='1' then
    q<=x"00000000";
    elsif rising_edge(clk) then 
        if en='1' then 
            q<=mux1;
        end if;
end if;
end process;
sum<=q+4;        
NextAddress<=sum;
Instruction <= rom(conv_integer(q(6 downto 2)));
end Behavioral;
