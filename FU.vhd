LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--this file is the forwarding unit

-- -- not done phase 2
ENTITY FU IS
     PORT (
        --register source 1 and 2 at decode stage to compare if they are 
        --equal to the register destination at execute stage or memory stage
        -- 1 or memory stage 2
         Rs1,Rs2: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
         --write back signals from all buffers after execute stage
         WriteBackOutEM,WriteBackOutMM,WriteBackMWB: IN STD_LOGIC;
         --We need forwarding for store operations as STR RS2,RS1 example
         --Add R1,R3,R4
         --Add R2,R6,R7
         --STR R1,R2 ---> R2 is data register and R1 is the address register (holds the address of store)
         --R1 value is the addres that needs forwarding for the store operation
         --register destination at execute stage or memory stage 1 or memory stage 2
         RdEM,RdMM,RdMWB: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         --output is a signal to the mux at execute stage to select the correct input for the alu
         OP1Sel,OP2Sel,OP3Sel: OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END ENTITY FU;

ARCHITECTURE fuArch OF FU IS
BEGIN
--operand 1 will be selected 
        --forward first operand value
OP1Sel<="01" when (Rs1=RdEM and (WriteBackOutEM='1' )) else
        "10" when (Rs1=RdMM and (WriteBackOutMM='1')) else
        "11" when (Rs1=RdMWB and (WriteBackMWB='1')) else
        "00";
        --forward second operand value
OP2Sel<="01" when (Rs2=RdEM and WriteBackOutEM='1') else
        "10" when (Rs2=RdMM and WriteBackOutMM='1') else
        "11" when (Rs2=RdMWB and WriteBackMWB='1') else
        "00";
        --for store operations OP3 to forward the address
OP3Sel<="01" when (Rs2=RdEM and WriteBackOutEM='1') else
        "10" when (Rs2=RdMM and WriteBackOutMM='1') else
        "11" when (Rs2=RdMWB and WriteBackMWB='1') else
        "00";
END fuArch;