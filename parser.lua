#!/usr/bin/env lua
local program = require("program")
local methods = require("methods")
local vtable = {}
local static = {}

function print_program(program)
  io.write(string.format("#include <stdio.h>\n#include <stdlib.h>\n\n"))
  for _, class in ipairs(program.classes) do
    io.write(string.format("struct %s;\n", class.name))
  end
  if #program.classes > 0 then io.write("\n") end
  for _, class in ipairs(program.classes) do            -- structs
    vtable[class.name] = {}
    static[class.name] = {}
    io.write(string.format("struct %s {\n", class.name))
    if class.extends then                               -- inheritance
      for _, extclass in ipairs(program.classes) do
        if extclass.name == class.extends then
          for _, extclassattr in ipairs(extclass.attributes) do
            io.write(string.format("  int %s;\n", extclassattr.name))
          end
          for _, meth in ipairs(extclass.methods) do
            if meth.tipo == "dynamic" then
              vtable[class.name][#vtable[class.name] + 1] = meth
            end
          end
          break
        end
      end
    end
    for _, attr in ipairs(class.attributes) do          -- attributes
      io.write(string.format("  int %s;\n", attr.name))
    end
    for _, meth in ipairs(class.methods) do             -- methods
      if meth.tipo == "dynamic" then
        for k, v in ipairs(vtable[class.name]) do
          if v.name == meth.name then                   -- duplicate variables
            duplicate = true
            break
          end
        end
        if duplicate then
          vtable[class.name][k] = meth
        else
          vtable[class.name][#vtable[class.name] + 1] = meth
        end
      else
        static[class.name][#static[class.name] + 1] = meth
      end
    end
    if #vtable[class.name] > 0 then
      io.write(string.format("  struct vtable_%s *vtable;\n};\n\n", class.name))
      io.write(string.format("struct vtable_%s {\n", class.name))
      for _, v in ipairs(vtable[class.name]) do
        io.write(string.format("  int (*%s)(struct %s*", v.name, class.name))
        methods.parameters(class, v)
      end
    end
    io.write("};\n\n")
  end
  methods.prototype(program, vtable, static)            --** methods prototypes
  if #program.classes > 0 then io.write("\n") end
  for _, class in ipairs(program.classes) do            --** vtables
    if #vtable[class.name] > 0 then
      hasvtable = true
      io.write(string.format("struct vtable_%s vtable_%s;\n", class.name,
      class.name))
    end
  end
  if hasvtable then io.write("\n") end
  io.write(string.format("int main() {\n"))
  body(program.body, vtable, static)
  io.write("  return 0;\n}\n")
  methods.constructor(program, vtable)                  --** methods default constructor
  methods.definition(program, vtable, static)           --** methods definition
end

print_program(program)
