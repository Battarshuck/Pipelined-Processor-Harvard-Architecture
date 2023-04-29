from typing import Dict, List, Set
#the opcodes dictionary
opCodes: Dict = {
    "NOP": "00000",
    "SETC": "00001",
    "CLRC": "00010",
    "NOT": "00011",
    "INC": "00100",
    "DEC": "00101",
    "MOV": "00111",
    "ADD": "01000",
    "SUB": "01001",
    "AND": "01010",
    "OR": "01011",
    "IN": "01100",
    "OUT": "01101",
    "PUSH": "01110",
    "POP": "01111",
    "CALL": "10000",
    "RET": "10001",
    "RTI": "10010",
    "LDD": "10011",
    "STD": "10100",
    "JZ": "10101",
    "JC": "10110",
    "JMP": "10111",
    "IADD": "11000",
    "LDM": "11001",

    ".ORG": "XXXXX"
}
#the set of all the zero operands instructions
zeroOperands: Set = {
    "NOP",
    "SETC",
    "CLRC",
    "RET",
    "RTI"
}
#the set of all the one operand instructions
oneOperand: Set = {
    "IN",
    "OUT",
    "PUSH",
    "POP",
    "CALL",
    "JZ",
    "JC",
    "JMP",
    ".ORG"
}
#the set of One operand instructions that the destination is not a Rdst register (Rs1)
OneOperandNotRdstOperands: Set = {
    "CALL",
    "JZ",
    "JC",
    "JMP",
    "OUT",
    "PUSH",
}
#the set of all the two operands instructions
twoOperands: Set = {
    "NOT",
    "INC",
    "DEC",
    "MOV",
    "LDD",
    "STD",
    "LDM"
}
#the set of all the three operands instructions
threeOperands: Set = {
    "IADD",
    "ADD",
    "SUB",
    "AND",
    "OR"
}
#the set of all the immediate operands instructions
immediateOperands: Set = {
    "LDM",
    "IADD",
}
#the set of all the instructions that have a different behavior when the operands are registers
diffrentBehaviorOperands: Set = {
    "LDD",
    "STD"
}
#the registers dictionary
registers: Dict = {
    "R0": "000",
    "R1": "001",
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}
#the hex digits set
hexDigits: Set = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}

#this function checks if a string is a hex number
def ishex(s):
    for c in s:
        if not c in hexDigits:
            return False
    return True

# this function get instruction string and returns all operands in this instrucion
# In r1, r2 --> ['IN', 'R1', 'R2']
def splitInstruction(instruction: str) -> List:
    # remove comments
    currentInstruction = instruction.split("#", 1)[0]
    currentInstruction = currentInstruction.strip()
    instructionAndOperands = currentInstruction.split(" ", 1)
    # handling one operand instructions
    if len(instructionAndOperands) == 1:
        return [instructionAndOperands[0].upper()]
    # split the operands
    remainingOperands: List = instructionAndOperands[1].split(",")
    # remove spaces and convert to upper case
    remainingOperands = [word.strip().upper()
                         for word in remainingOperands]
    # add the instruction to the operands list and return
    return [instructionAndOperands[0].upper()] + remainingOperands

# this function get instruction string and returns the number of operands in this instrucion
def expectedNumberOfOperands(instruction: str) -> int:
    if instruction in zeroOperands:
        return 0
    if instruction in oneOperand:
        return 1
    if instruction in twoOperands:
        return 2
    if instruction in threeOperands:
        return 3
# write the instruction code to the output file in mem format as requested for modelsim
def writeInFinaleFile(instructionCode: str, lineNumber: int, outputFile):
    outputFile.write(str(lineNumber)+": " + instructionCode + "\n")
    
# this function get the name of the input file and the name of the output file and compile the input file to the output file in binary
def compile(nameInputFile: str, outputFile):
    # the line number in the output file
    lineNumber: int = 0
    actualLineNumber: int = 0
    # open the input file
    with open(nameInputFile, "r") as inputFile:
        for line in inputFile:
            actualLineNumber += 1
            # initialize the instruction code
            instructionCode: str = ""
            # return the operands of the instruction
            currentOperands: List = splitInstruction(line)
            # if the line is empty or a comment line
            if currentOperands[0] == "" or currentOperands[0][0] == "#":
                continue
            # if the line is a HEX number
            if len(currentOperands)==1 and ishex(currentOperands[0]) and len(currentOperands[0]) < 5:
                #checks if the number of parameters is correct
                if len(currentOperands) != 1:
                    raise Exception(
                        "(NUMBER OF PARAMETERS) Syntax error at line number " + str(actualLineNumber))
                #converts the number to binary
                data = bin(int(currentOperands[0],16))[2:].zfill(16)
                #writes the number to the output file
                writeInFinaleFile(data, lineNumber, outputFile)
                #increases the line number
                lineNumber += 1
                continue

            # if the command is not found in the commands dictionary
            if currentOperands[0] not in opCodes:
                raise Exception(
                    "(COMMAND NOT FOUND) Syntax error at line number " + str(actualLineNumber))
            # if the command is found in the commands dictionary add the opcode to the instruction code
            instructionCode += opCodes[currentOperands[0]] #opcode
            # gets the number of operands that the command should have
            expectedNumOfOperands: int = expectedNumberOfOperands(currentOperands[0])
            # if the number of operands is not correct
            if expectedNumOfOperands != len(currentOperands) - 1:
                raise Exception(
                    "(CHECK NUM OF OPERANDS) Syntax error at line number " + str(actualLineNumber))

            # zero operands
            # if the command is a zero operand command pad with zeros after opCode
            if expectedNumOfOperands == 0:
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]

            # one operand
            if expectedNumOfOperands == 1:
                # Handles the Rdst and Rsrc operands (normal behavior)  
                if currentOperands[0] not in OneOperandNotRdstOperands:

                    #checking if it is an .ORG command that changes the line number
                    if currentOperands[0] == ".ORG":
                        address = currentOperands[1]
                        #checking if the address is a hex number and if it is less than 5 digits(as a string)
                        if  len(address) < 5 and ishex(address):  
                            addressNum = int(address,16) #converting the hex number to decimal
                            lineNumber = addressNum #changing the line number
                        else:
                            raise Exception(
                                "(WRONG VALUE OR NUMBER OF PARAMETERS) Syntax error at line number " + str(actualLineNumber))
                        continue #this command does not need to be written in the output file, so we continue to the next line
                    #if the register name is not found in the registers dictionary
                    if currentOperands[1] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                    #add Rdst to the instruction code then pad with zeros
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]
                else:# handles if The fist operand is not Rdst
                    #if the register name is not found in the registers dictionary
                    if currentOperands[1] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                    instructionCode += "000"
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]

            # two operands
            if expectedNumOfOperands == 2:
                # normal behavior operands not Load or Store or Immediate
                if currentOperands[0] not in diffrentBehaviorOperands and currentOperands[0] not in immediateOperands:
                    if currentOperands[1] not in registers or  currentOperands[2] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]            

            # diffrent behavior operands and num of operands is 3
            if expectedNumOfOperands == 3:
                # if the command is not immediate
                if currentOperands[0] not in immediateOperands:
                    # all registers are valid
                    if currentOperands[1] not in registers or  currentOperands[2] not in registers or  currentOperands[3] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += registers[currentOperands[3]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]

            # if the instruction is a load or store instruction
            if currentOperands[0] in diffrentBehaviorOperands:
                if currentOperands[1] not in registers or  currentOperands[2] not in registers:
                    raise Exception(
                        "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                
                if currentOperands[0] == "LDD":
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += "000"
                    instructionCode += registers[currentOperands[2]]
                elif currentOperands[0] == "STD":
                    instructionCode += "000"
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += registers[currentOperands[1]]
                # pad with zeros
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]


            # immediate instructions (to put values in 32 bits (2 consecutive instructions))
            if currentOperands[0] in immediateOperands :
                if currentOperands[1] not in registers:
                    raise Exception(
                        "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                instructionCode += registers[currentOperands[1]] #Rdst
                # if the command is IADD
                if expectedNumOfOperands == 3:
                    instructionCode += registers[currentOperands[2]] #Rsrc1
                #pad with zeros and the last bit is 1 to indicate that it is an immediate instruction
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:15]
                instructionCode += "1" 
                #getting the immediate value
                immediateValue = currentOperands[2] if expectedNumOfOperands == 2 else currentOperands[3]
                if len(immediateValue) > 4 or not ishex(immediateValue):
                    raise Exception(
                        "(WRONG IMMEDIATE VALUE) Syntax error at line number " + str(actualLineNumber)) 

                immediateValue = bin(int(immediateValue,16))[2:].zfill(16)

            #writing the instruction code in the output file
            writeInFinaleFile(instructionCode, lineNumber, outputFile)
            #if the instruction is immediate, we write the immediate value in the next line
            if currentOperands[0] in immediateOperands:
                lineNumber+=1
                writeInFinaleFile(immediateValue, lineNumber, outputFile)
            
            lineNumber += 1
                

            

   
#Creates the mem file
outputFile = open("outputFile.mem", "w")
# Data needed for modelsim
outputFile.write("// memory data file (do not edit the following line - required for mem load use)\n")
outputFile.write("// instance=/processor/fetchStage/instructionCache/ram\n")
outputFile.write("// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n")
# if the compilation was successful, we print a success message
try:
    compile("inputFile.txt", outputFile)
    print("Compilation finished successfully!")
except Exception as e:
    print(e)

outputFile.close()
