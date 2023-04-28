from typing import Dict, List, Set

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

zeroOperands: Set = {
    "NOP",
    "SETC",
    "CLRC",
    "RET",
    "RTI"
}
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
twoOperands: Set = {
    "NOT",
    "INC",
    "DEC",
    "MOV",
    "LDD",
    "STD",
    "LDM"
}
threeOperands: Set = {
    "IADD",
    "ADD",
    "SUB",
    "AND",
    "OR"
}

immediateOperands: Set = {
    "LDM",
    "IADD",
}

diffrentBehaviorOperands: Set = {
    "LDD",
    "STD"
}

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

hexDigits: Set = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}


def ishex(s):
    for c in s:
        if not c in hexDigits:
            return False
    return True

# this function get instruction string and returns all operands in this instrucion
# In r1, r2 --> ['IN', 'R1', 'R2']
def splitInstruction(instruction: str) -> List:
    currentInstruction = instruction.strip()
    instructionAndOperands = currentInstruction.split(" ", 1)

    if len(instructionAndOperands) == 1:
        return [instructionAndOperands[0].upper()]

    remainingOperands: List = instructionAndOperands[1].split(",")

    remainingOperands = [word.strip().upper()
                         for word in remainingOperands]

    return [instructionAndOperands[0].upper()] + remainingOperands


def expectedNumberOfOperands(instruction: str) -> int:
    if instruction in zeroOperands:
        return 0
    if instruction in oneOperand:
        return 1
    if instruction in twoOperands:
        return 2
    if instruction in threeOperands:
        return 3

def writeInFinaleFile(instructionCode: str, lineNumber: int, outputFile):
    outputFile.write(str(lineNumber)+": " + instructionCode + "\n")
    

def compile(nameInputFile: str, outputFile):
    lineNumber: int = 0
    actualLineNumber: int = 1
    with open(nameInputFile, "r") as inputFile:
        for line in inputFile:
            instructionCode: str = ""
            currentOperands: List = splitInstruction(line)

            if currentOperands[0] == "" or currentOperands[0][0] == "#":
                actualLineNumber += 1
                continue


            if currentOperands[0] not in opCodes:
                raise Exception(
                    "(COMMAND NOT FOUND) Syntax error at line number " + str(actualLineNumber))

            instructionCode += opCodes[currentOperands[0]] #opcode

            expectedNumOfOperands: int = expectedNumberOfOperands(currentOperands[0])

            if expectedNumOfOperands != len(currentOperands) - 1:
                raise Exception(
                    "(CHECK NUM OF OPERANDS) Syntax error at line number " + str(actualLineNumber))

            # zero operands
            if expectedNumOfOperands == 0:
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]

            # one operand
            if expectedNumOfOperands == 1:
                #checking if it is an .ORG command that changes the line number
                if currentOperands[0] == ".ORG":
                    address = currentOperands[1]
                    #checiing if the address is a hex number and if it is less than 5 digits(as a string)
                    if  len(address) < 5 and ishex(address):  
                        addressNum = int(address,16) #converting the hex number to decimal
                        lineNumber = addressNum #changing the line number
                    else:
                        raise Exception(
                            "(WRONG VALUE OR NUMBER OF PARAMETERS) Syntax error at line number " + str(actualLineNumber))
                    actualLineNumber += 1
                    continue #this command does not need to be written in the output file, so we continue to the next line

                if currentOperands[1] not in registers:
                    raise Exception(
                        "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                instructionCode += registers[currentOperands[1]]
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]

            # two operands
            if expectedNumOfOperands == 2:
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
                if currentOperands[0] not in immediateOperands:
                    if currentOperands[1] not in registers or  currentOperands[2] not in registers or  currentOperands[3] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += registers[currentOperands[3]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]


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

                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]


            # immediate operands
            if currentOperands[0] in immediateOperands :
                if currentOperands[1] not in registers:
                    raise Exception(
                        "(REG NAME NOT FOUND) Syntax error at line number " + str(actualLineNumber))
                instructionCode += registers[currentOperands[1]] #Rdst

                if expectedNumOfOperands == 3:
                    instructionCode += registers[currentOperands[2]] #Rsrc1
                
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:15]
                instructionCode += "1" 

                immediateValue = currentOperands[2] if expectedNumOfOperands == 2 else currentOperands[3]
                if len(immediateValue) > 4 or not ishex(immediateValue):
                    raise Exception(
                        "(WRONG IMMEDIATE VALUE) Syntax error at line number " + str(actualLineNumber)) 

                immediateValue = bin(int(immediateValue,16))[2:].zfill(16)


            writeInFinaleFile(instructionCode, lineNumber, outputFile)
            if currentOperands[0] in immediateOperands:
                lineNumber+=1
                writeInFinaleFile(immediateValue, lineNumber, outputFile)

            lineNumber += 1
            actualLineNumber += 1
                

            

   

outputFile = open("outputFile.mem", "w")
outputFile.write("// memory data file (do not edit the following line - required for mem load use)\n")
outputFile.write("// instance=/processor/fetchStage/instructionCache/ram\n")
outputFile.write("// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n")

try:
    compile("inputFile.txt", outputFile)
    print("Compilation finished successfully!")
except Exception as e:
    print(e)

outputFile.close()
