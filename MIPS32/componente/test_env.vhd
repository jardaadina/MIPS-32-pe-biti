library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
 Port (btn: in std_logic_vector(4 downto 0);
       sw: in std_logic_vector(15 downto 0);
       clk: in std_logic;
       cat: out std_logic_vector(6 downto 0);
       an: out std_logic_vector(7 downto 0);
       led: out std_logic_vector(15 downto 0) );
end test_env;

architecture Behavioral of test_env is

component IFetch
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
end component;

component MPG
Port (enable : out STD_LOGIC;
      btn : in STD_LOGIC;
      clk : in STD_LOGIC);
end component;

component SSD
Port (clk : in STD_LOGIC;
      digits : in STD_LOGIC_VECTOR(31 downto 0);
      an : out STD_LOGIC_VECTOR(7 downto 0);
      cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component MEM 
 Port (MemWrite: in std_logic;
        ALUResIn: in std_logic_vector(31 downto 0);
        RD2: in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en: in std_logic;
        MemData: out std_logic_vector(31 downto 0);
        ALUResOut: out std_logic_vector(31 downto 0));
end component;

component ID
 Port (RegWrite: in std_logic;
         clk: in std_logic;
        Instr: in std_logic_vector(25 downto 0);
        RedDest: in std_logic;
        EN: in std_logic;
        ExtOp: in std_logic;
        WD: in std_logic_vector(31 downto 0);
        RD1: out std_logic_vector(31 downto 0); 
        RD2: out std_logic_vector(31 downto 0);
        Ext_Imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0)
       );
end component;

component UC       
    Port ( 
    Instr : in std_logic_vector(5 downto 0);
    RegDst : out std_logic;
    ExtOp : out std_logic;
    ALUSrc : out std_logic;
    Branch : out std_logic;
    Branch_gtz : out std_logic;
    Jump : out std_logic;
    ALUOp : out std_logic_vector(1 downto 0);
    MemWrite : out std_logic;
    MemtoReg : out std_logic;
    RegWrite : out std_logic
  );
         
end component;

component EX
 Port ( RD1 : in STD_LOGIC_VECTOR (31 downto 0);
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
end component;

signal en: std_logic;
signal instr: std_logic_vector(31 downto 0) :=(others=>'0');
signal PC_4: std_logic_vector(31 downto 0):=(others=>'0');
signal iesireMUX: std_logic_vector(31 downto 0):=(others=>'0');

--semnale ID
signal RegDest: std_logic;
signal ExtOp: std_logic;

--semnale EX
signal RD1: std_logic_vector(31 downto 0) :=(others=>'0');
signal RD2: std_logic_vector(31 downto 0) :=(others=>'0');
signal Ext_Imm: std_logic_vector(31 downto 0) :=(others=>'0');
signal func: std_logic_vector(5 downto 0) :=(others=>'0');
signal sa: std_logic_vector(4 downto 0) :=(others=>'0');
signal Zero: std_logic;
signal BranchAddress: std_logic_vector(31 downto 0) :=(others=>'0');
signal ALURes: std_logic_vector(31 downto 0) :=(others=>'0');

--semnale MEM
signal ALUResOut: std_logic_vector(31 downto 0) :=(others=>'0');
signal MemData: std_logic_vector(31 downto 0) :=(others=>'0');

--semnale UC
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal ALUOp: std_logic_vector(1 downto 0) :=(others=>'0');
signal MemWrite: std_logic;
signal MemtoReg: std_logic;
signal RegWrite: std_logic;
signal BR_gtz: std_logic;

--iesire mux mare
signal iesireMux2: std_logic_vector(31 downto 0) :=(others=>'0');

--semnal pt pcsrc
signal pcSrcIntrare: std_logic;
signal JumpAddress: std_logic_vector(31 downto 0) :=(others=>'0');
signal gtz: std_logic;
begin

pcSrcIntrare<=Branch and Zero;
JumpAddress<=PC_4(31 downto 28) & (Instr(25 downto 0) & "00");

mpgComponent: MPG port map(en, btn(0),clk);
iFetchComponent: IFetch port map(Jump, pcSrcIntrare, JumpAddress, BranchAddress, instr, PC_4, clk, en, btn(1));
ssdComponent: SSD port map(clk, iesireMUX2, an, cat);

IDComponent: ID port map(RegWrite, clk, instr(25 downto 0), RegDest, en, ExtOp, iesireMUX, RD1, RD2, Ext_Imm, func, sa);
EXCopmponent: Ex port map(RD1, ALUSrc, RD2, Ext_Imm, sa, func, ALUOp, PC_4, gtz, Zero, ALURes, BranchAddress);
MEMComponent: MEM port map(MemWrite, ALURes, RD2, clk, en, MemData, ALUResOut);
UCComponent: UC port map(instr(31 downto 26), RegDest, ExtOp, ALUSrc, Branch, BR_gtz, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

--mux mare
process(instr, pc_4, RD1, RD2, Ext_Imm, ALURes, MemData, iesireMUX, sw(7 downto 5))
begin
case sw(7 downto 5) is
when "000" => iesireMUX2<=instr;
when "001" => iesireMUX2<=pc_4;
when "010" => iesireMUX2<=RD1;
when "011" => iesireMUX2<=RD2;
when "100" => iesireMUX2<=Ext_Imm;
when "101" => iesireMUX2<=ALURes;
when "110" => iesireMUX2<=MemData;
when others=> iesireMUX2<=iesireMUX;
end case;
end process;

--mux mic
process(ALUResOut, MemData, MemtoReg)
begin
if MemtoReg='0' then 
    iesireMUX<=ALUResOut;
else iesireMUX<=MemData;
end if;
end process;

led <= instr(31 downto 26) & RegDest & ExtOp & ALUSrc & Branch & BR_gtz & Jump & ALUOp & MemWrite & MemtoReg;-- & RegWrite

end Behavioral;