local Package = script.Parent.Parent.Parent

local deserialise = require(Package.Utilities.Luau.deserialise)

return function(bytecode: string)
    local luauObject = deserialise(bytecode)
    local luauDecompiledOutput = ""

    local function processProto(protoName, proto)
        luauDecompiledOutput ..= `.{protoName} {proto.debugname and `({proto.debugname or ""})`}:`

        for _, instruction in proto.code do
            if not instruction.opcode then
                continue
            end

            local opmode = instruction.opmode
            local kmode = instruction.kmode

            local line = ""

            if opmode == 1 then
                line ..= `{ instruction.opname } { instruction.A }`
            elseif opmode == 2 then
                line ..= `{ instruction.opname } { instruction.A } { instruction.B }`
            elseif opmode == 3 then
                line ..= `{ instruction.opname } { instruction.A } { instruction.B } { instruction.C }`
            elseif opmode == 4 then
                line ..= `{ instruction.opname } { instruction.A } { instruction.D }`
            elseif opmode == 5 then
                line ..= `{ instruction.opname } { instruction.E }`
            end

            if kmode == 4 then
                line ..= ` ["{instruction.K0}"]`
            elseif kmode ~= 0 then
                line ..= ` ["{instruction.K}"]`
            end

            luauDecompiledOutput ..= `\n\t{line}`
        end

        luauDecompiledOutput ..= `\n\n`
    end

    local function processProtoMetadata(proto)
        luauDecompiledOutput ..= `maxstacksize: {proto.maxstacksize}\n`
        luauDecompiledOutput ..= `sizecode: {proto.sizecode}\n`
        luauDecompiledOutput ..= `sizek: {proto.sizek}\n`
        luauDecompiledOutput ..= `sizep: {proto.sizek}\n`
        luauDecompiledOutput ..= `lineinfoenabled: {proto.lineinfoenabled}\n`
        luauDecompiledOutput ..= `instructionlineinfo: {table.concat(proto.instructionlineinfo, ", ")}\n`
        luauDecompiledOutput ..= `bytecodeid: {proto.bytecodeid}\n`

        luauDecompiledOutput ..= `\n--------\n\n`
    end
    
    processProtoMetadata(luauObject.mainProto)

    for protoIndex, protoData in luauObject.protoList do
        if protoIndex == #luauObject.protoList then
            continue
        end

        processProto(`PROTO_{protoIndex}`, protoData)
    end

    processProto(`MAIN`, luauObject.mainProto)

    return luauDecompiledOutput
end