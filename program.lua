#!/usr/bin/env lua
program = { classes = {}, body = {} }

local function main()
  local doolprog = arg[1]
  cprog = arg[2]
  if not doolprog then
    print("Missing DOOL program!")
    os.exit(1)
  end
  if not cprog then
    print("Missing C output file!")
    os.exit(1)
  end
  io.input(doolprog)
  io.output(cprog)
  local file = io.lines()
  for line in file do
    if string.match(line, "class") then                   -- class found
      local id = string.match(line, "%s*class%s+(%a+)")
      program.classes[#program.classes + 1] = {
      name = id, extends = nil, attributes = {}, methods = {}}
      if string.match(line, "extends") then
        local id = string.match(line, "%s*class%s+%a+%s+extends%s+(%a+)")
        program.classes[#program.classes].extends = id
      end
      for lineclass in file do
        if string.match(lineclass, "end") then break
        elseif string.match(lineclass, "attribute") then  -- attribute found
          local id, number = string.match(lineclass,
          "%s*attribute%s+(%a+)%s*:%s*(%a+)")
          attr = program.classes[#program.classes].attributes
          attr[#attr + 1] = {name = id, tipo = number}
        elseif string.match(lineclass, "def") then        -- method found
          local methtype, id = string.match(lineclass, "%s*def%s+(%a+)%s+(%a+)")
          meths = program.classes[#program.classes].methods
          meths[#meths + 1] = {name = id, tipo = methtype, params = {}, body = {} }
          for linemeth in file do
            if string.match(linemeth, ":") then           -- parameter found
              local id, paramtype = string.match(linemeth, "%s*(%a+)%s*:%s*(%a+)")
              methparams = meths[#meths].params
              methparams[#methparams + 1] = {name = id, tipo = paramtype}
            elseif string.match(linemeth, "begin") then
              for methbody in file do
                if string.match(methbody, "end") then break end
                meths[#meths].body[#meths[#meths].body + 1] = methbody
              end
              break
            end
          end
        end
      end
    elseif string.match(line, "program") then             -- program found
      for progbody in file do
        if string.match(progbody, "end") then break end
        program.body[#program.body + 1] = progbody
      end
    end
  end
end

main()

return program
