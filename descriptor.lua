#!/usr/bin/env lua
local program = require("program")

function print_program(program)
  print("program = {")
  -- classes
  if #program.classes > 0 then
    print("  classes = {")
    for _, vclass in ipairs(program.classes) do
      print(string.format("%14s%s%s", "{ name = \"", vclass.name, "\","))
      if vclass.extends then
        print(string.format("%17s%s%s", "extends = \"", vclass.extends, "\","))
      else
        print(string.format("%16s%s%s", "extends = ", vclass.extends, ","))
      end
      print(string.format("%20s", "attributes = {"))
      for _, vattr in ipairs(vclass.attributes) do
        print(string.format("%20s%s%s%s%s", "{ name = \"", vattr.name,
                            "\", type = \"", vattr.tipo, "\" },"))
      end
      print(string.format("%8s", "},"))
      -- methods
      print(string.format("%17s", "methods = {"))
      for _, vmeth in ipairs(vclass.methods) do
        print(string.format("%18s%s%s", "{ name = \"", vmeth.name, "\","))
        print(string.format("%18s%s%s", "type = \"", vmeth.tipo, "\","))
        print(string.format("%20s", "params = {"))
        for _, vparam in ipairs(vmeth.params) do
          print(string.format("%22s%s%s%s%s", "{ name = \"", vparam.name,
                              "\", type = \"", vparam.tipo, "\" },"))
        end
        print(string.format("%12s", "},"))
        print(string.format("%18s", "body = {"))
        for _, vbody in ipairs(vmeth.body) do
          print(string.format("%12s%s%s", "\"", vbody, "\",", "\""))
        end
        print(string.format("%12s%10s", "}\n", "},"))
      end
      print("      }\n    },")
    end -- ipairs(program.classes)
  else
    print("  classes = { },")
  end

  -- program body
  print("  body = {")
  for k, v in ipairs(program.body) do
    print(string.format("%5s%s%s", "\"", v, "\","))
  end
  print(string.format("  }\n}"))
end

print_program(program)
