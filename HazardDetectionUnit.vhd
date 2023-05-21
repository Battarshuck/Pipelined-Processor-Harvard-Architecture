LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
--this file is the forwarding unit

-- -- not done phase 2

ENTITY HazardDetectionUnit IS
    PORT (
        --register source 1 and 2 at F/D buffer if it is equal to one of the registers 
        --at D/E buffer & E/M buffer
        Rs1FD, Rs2FD, RdDE, RdEM : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        memoryReadSigEM, memoryReadSigDE, memoryWriteSigEM, memoryWriteSigDE : IN STD_LOGIC;
        writeBackEM, writeBackDE : IN STD_LOGIC;
        -- --register destination at execute stage or memory stage 1 or memory stage 2
        -- --output is a signal to the mux at execute stage to select the correct input for the alu
        bubblingSignalDataHazard, bubblingSignalStructuralHazard : OUT STD_LOGIC
    );
END ENTITY HazardDetectionUnit;

ARCHITECTURE HazardDetectionUnitArch OF HazardDetectionUnit IS
BEGIN
    bubblingSignalDataHazard <= '1' WHEN (((Rs1FD = RdDE) OR (Rs2FD = RdDE)) AND (memoryReadSigDE = '1') AND (writeBackDE = '1')) ELSE
        '1' WHEN (((Rs1FD = RdEM) OR (Rs2FD = RdEM)) AND (memoryReadSigEM = '1') AND (writeBackEM = '1')) ELSE
        '0';
        
    bubblingSignalStructuralHazard <= '1' WHEN ((memoryReadSigEM = '1' OR memoryWriteSigEM = '1') AND (memoryReadSigDE = '1' OR memoryWriteSigDE = '1')) ELSE
        '0';

END HazardDetectionUnitArch;