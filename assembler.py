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
    "LD": "10011",
    "STD": "10100",
    "JZ": "10101",
    "JC": "10110",
    "JMP": "10111",
    "IADD": "11000",
    "LDM": "11001"
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
    "JMP"
}
twoOperands: Set = {
    "NOT",
    "INC",
    "DEC",
    "MOV",
    "LD",
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
    "LD",
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


def compile(nameInputFile: str, nameOutputFIle: str):
    outputFile = open(nameOutputFIle, "w")
    lineNumber: int = 0
    with open(nameInputFile, "r") as inputFile:
        for line in inputFile:
            instructionCode: str = ""
            lineNumber += 1
            currentOperands: List = splitInstruction(line)

            if currentOperands[0] not in opCodes:
                raise Exception(
                    "(COMMAND NOT FOUND) Syntax error at line number " + str(lineNumber))

            instructionCode += opCodes[currentOperands[0]]

            expectedNumOfOperands: int = expectedNumberOfOperands(
                currentOperands[0])

            if expectedNumOfOperands != len(currentOperands) - 1:
                raise Exception(
                    "(CHECK NUM OF OPERANDS) Syntax error at line number " + str(lineNumber))


            if expectedNumOfOperands == 1:
                if currentOperands[1] not in registers:
                    raise Exception(
                        "(REG NAME NOT FOUND) Syntax error at line number " + str(lineNumber))
                instructionCode += registers[currentOperands[1]]
                instructionCode += "000000000000000000"
                instructionCode = instructionCode[0:16]


            if expectedNumOfOperands == 2:
                if currentOperands[0] not in diffrentBehaviorOperands and currentOperands[0] not in immediateOperands:
                    if currentOperands[1] not in registers or  currentOperands[2] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(lineNumber))
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]

            if expectedNumOfOperands == 3:
                if currentOperands[0] not in immediateOperands:
                    if currentOperands[1] not in registers or  currentOperands[2] not in registers or  currentOperands[3] not in registers:
                        raise Exception(
                            "(REG NAME NOT FOUND) Syntax error at line number " + str(lineNumber))
                    instructionCode += registers[currentOperands[1]]
                    instructionCode += registers[currentOperands[2]]
                    instructionCode += registers[currentOperands[3]]
                    instructionCode += "000000000000000000"
                    instructionCode = instructionCode[0:16]
            

    outputFile.close()


try:
    compile("inputFile.txt", "outputFile.txt")
except Exception as e:
    print(e)
